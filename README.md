Note on building journalbeat and metricbeat:

Version 6.8.x of these beats contain incompatible or non-existing dependencies. Fortunately, we do not use these dependencies. The missing dependencies include:

- Goja is a library used in preprocessors for Elasticsearch. We do not use this functionality.

https://www.elastic.co/guide/en/elasticsearch/reference/master/ingest.html

```
/hab/cache/src/github.com/elastic/beats/libbeat/processors/script/javascript/session.go:267:14: s.Runtime().RegisterSimpleMapType undefined (type *goja.Runtime has no field or method RegisterSimpleMapType)
```

- Aerospike is a Go client library for connecting to the aerospike nosql database. We do not use this functionality.

https://www.aerospike.com/docs/client/go/examples.html

/hab/cache/src/github.com/elastic/beats/metricbeat/module/aerospike/namespace/namespace.go:85:17: undefined: "github.com/aerospike/aerospike-client-go".RequestNodeInfo