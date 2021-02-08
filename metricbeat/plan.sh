pkg_name=metricbeat
pkg_origin="ff"
pkg_version=7.9.1
pkg_maintainer="Chef Software Inc. <support@chef.io>"
pkg_license=("Apache-2.0")
pkg_deps=(core/glibc)
pkg_build_deps=(
  core/go
  core/git
  core/make
  core/gcc
)
pkg_bin_dirs=(bin)
pkg_svc_user=root
pkg_svc_group=root
pkg_description="Metricbeat is a lightweight shipper for metrics with Elasticsearch."
pkg_upstream_url="https://elastic.co/products/beats/metricbeat"

do_download() {
  GOPATH="$(dirname "${HAB_CACHE_SRC_PATH}")"
  export GOPATH
  n=0
  until [ "$n" -ge 3 ]
  do
    go get github.com/elastic/beats/metricbeat && break
    n=$((n+1))
    sleep 1
  done
  pushd "${HAB_CACHE_SRC_PATH}/github.com/elastic/beats/metricbeat" > /dev/null || exit 1
  git checkout "v${pkg_version}"
  popd > /dev/null || exit 1
}

do_unpack() {
  return 0
}

do_build() {
  pushd "${HAB_CACHE_SRC_PATH}/github.com/elastic/beats/metricbeat" > /dev/null || exit 1
  make
  popd > /dev/null || exit 1
}

do_install() {
  install -D "${HAB_CACHE_SRC_PATH}/github.com/elastic/beats/metricbeat/${pkg_name}" "${pkg_prefix}/bin/${pkg_name}"
}
