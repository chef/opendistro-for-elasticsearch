pkg_name=kibana-odfe
KIBANA_VERSION="6.8.6"
KIBANA_PKG_URL="https://artifacts.elastic.co/downloads/kibana/kibana-oss-$KIBANA_VERSION-linux-x86_64.tar.gz"
pkg_version="0.10.0.4"
opendistro_version="0.10.1.2"
nvm_version="0.35.3"
pkg_origin=open-distro
pkg_license=('Apache-2.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Kibana is a browser based analytics and search dashboard for Elasticsearch."
# Kibana has the undesirable behaviour of using an unconfigarable temp dir that's relative to its package path.
# This resolves to $pkg_path/optimize and is not writable by anyone other than root
pkg_svc_user="root"
pkg_build_deps=(
  core/coreutils
  core/git
  core/gnupg
  core/jq-static
  core/maven
  core/node
  core/openjdk11
  core/openssl
  core/zip
)
pkg_deps=(
  core/bash
  core/rsync
)
pkg_exports=(
  [port]=kibana_yaml.server.port
)
pkg_exposes=(port)
pkg_binds_optional=(
  [elasticsearch-odfe]="http-port"
)
pkg_bin_dirs=(bin)

do_download() {
  wget -O $HAB_CACHE_SRC_PATH/kibana-oss-$KIBANA_VERSION.tar.gz $KIBANA_PKG_URL
  rm -rf $HAB_CACHE_SRC_PATH/deprecated-security-parent
  git clone https://github.com/opendistro-for-elasticsearch/deprecated-security-parent.git $HAB_CACHE_SRC_PATH/deprecated-security-parent
  rm -rf $HAB_CACHE_SRC_PATH/security-kibana-plugin
  git clone https://github.com/opendistro-for-elasticsearch/security-kibana-plugin.git $HAB_CACHE_SRC_PATH/security-kibana-plugin
}

do_unpack() {
  if [[ -d $HAB_CACHE_SRC_PATH/kibana-$KIBANA_VERSION-linux-x86_64 ]]
  then
    rm -rf $HAB_CACHE_SRC_PATH/kibana-$KIBANA_VERSION-linux-x86_64
  fi
  tar -xzf $HAB_CACHE_SRC_PATH/kibana-oss-$KIBANA_VERSION.tar.gz -C $HAB_CACHE_SRC_PATH/
}

do_build() {

  # The Kibana build scripts need nvm, as well as the non-standard NVM_HOME var.
  rm -rf /root/.nvm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh | bash
  export NVM_HOME=$HOME/.nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  export JAVA_HOME=$(hab pkg path core/openjdk11)
  export MAVEN_HOME=$(hab pkg path core/maven)

  # The 6.8 version of this plugin deps on the now deprecated security-parent plugin.
  # This can be removed once we go to 7.X
  pushd /hab/cache/src/deprecated-security-parent>/dev/null || exit 1
  git checkout tags/v${pkg_version}
  mvn compile -Dmaven.test.skip=true
  mvn package -Dmaven.test.skip=true
  mvn install -Dmaven.test.skip=true
  popd || exit 1

  # Build the Kibana plugin itself. We're using opendistro 0.10.0.6, but 0.10.0.4 is as close as exists for kibana
  pushd /hab/cache/src/security-kibana-plugin>/dev/null || exit 1
  git checkout tags/v${pkg_version}

  # Swap the hardcoded 6.8.1 version for 6.8.6
  sed -i 's/6.8.1/6.8.6/g' package.json

  # This will fail, but sets up enough of an environment to not fail again
  ./build.sh ${KIBANA_VERSION} ${opendistro_version} install || true

  ./build.sh ${KIBANA_VERSION} ${opendistro_version} install

  # This effectively installs the plugin in the source path
  unzip -o -q $HAB_CACHE_SRC_PATH/security-kibana-plugin/target/releases/opendistro_security_kibana_plugin-$pkg_version.zip -d $HAB_CACHE_SRC_PATH
  mv $HAB_CACHE_SRC_PATH/kibana/opendistro_security_kibana_plugin-$opendistro_version $HAB_CACHE_SRC_PATH/kibana-$KIBANA_VERSION-linux-x86_64/plugins/opendistro_security_kibana_plugin

  popd || exit 1

}

do_install() {
  install -vDm644 $HAB_CACHE_SRC_PATH/kibana-$KIBANA_VERSION-linux-x86_64/README.txt "${pkg_prefix}/README.txt"
  install -vDm644 $HAB_CACHE_SRC_PATH/kibana-$KIBANA_VERSION-linux-x86_64/LICENSE.txt "${pkg_prefix}/LICENSE.txt"
  install -vDm644 $HAB_CACHE_SRC_PATH/kibana-$KIBANA_VERSION-linux-x86_64/NOTICE.txt "${pkg_prefix}/NOTICE.txt"

  cp -a $HAB_CACHE_SRC_PATH/kibana-$KIBANA_VERSION-linux-x86_64/* "${pkg_prefix}/"
  fix_interpreter "${pkg_prefix}/bin/*" core/bash bin/sh
}

do_strip() {
  return 0
}

