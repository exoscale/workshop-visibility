# Riemann

*Riemann monitors distributed systems*

<style>
img { background-color: black }
</style>
![riemann](http://riemann.io/images/riemann-arch-diagram.png)

[riemann](http://riemann.io)

## What does riemann do ?

> Riemann aggregates events from your servers and applications with a
> powerful stream processing language. Send an email for every
> exception raised by your code. Track the latency distribution of
> your web app. See the top processes on any host, by memory and
> CPU. Combine statistics from every Riak node in your cluster and
> forward to Graphite. Send alerts when a key process fails to check
> in. Know how many users signed up right this second.

## A typical riemann config

```
(logging/init {:file "riemann.log" :console true})

(tcp-server {:tls? false
             :key "test/data/tls/server.pkcs8"
             :cert "test/data/tls/server.crt"
             :ca-cert "test/data/tls/demoCA/cacert.pem"})

(instrumentation {:interval 1})

(udp-server)
(ws-server)
(repl-server)

(periodically-expire 1)

(let [index (default :ttl 3 (index))]
  (streams
    (expired #(prn "Expired" %))
    (where (not (service #"^riemann "))
           index)))
```
