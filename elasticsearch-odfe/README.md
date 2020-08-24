# elasticsearch-odfe

## Maintainers

* The Habitat Maintainers: <humans@habitat.sh>

## Type of Package

Service package

## Usage

Install the package, and load the service:

```bash
hab pkg install core/elasticsearch-odfe
hab svc load core/elasticsearch-odfe
```

## Bindings

Services consuming elasticsearch-odfe can bind via:

```
hab svc load origin/package --bind elasticsearch:elasticsearch-odfe.default
```

Elasticsearch's contract presents the following ports to bind to:

- `http-port`
- `transport-port`

## Topologies

Currently this plan supports standalone topology.

## Update Strategies

No update strategy or at-once update strategy works fine in a single-node installation.

### Configuration Updates
