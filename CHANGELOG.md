# Changelog

## v1.0.8

* Fix issue where java throwable was not correctly passed to the Lucee listener on onError event

## v1.0.7

* Fix `getResponse()` returning an empty struct (and the close handler silently failing) under Java 11+ / JPMS: the response is a `jdk.internal.net.http.HttpResponseImpl`, which lucee cannot reflect on because `java.net.http` does not open its internal package. Status/uri/headers are now read via the public `java.net.http.HttpResponse` interface so no `--add-opens` is required
* Fix blocking `start()` hanging forever when the close handler errored: the completion flag is now always set (via `finally`) and `start()` uses the `isRunning()` exit with a bounded grace window, so a failing/slow close handler can never wedge the caller
* Guard a null response in the close handler (request completed exceptionally, e.g. a connection reset) instead of throwing a swallowed NPE
* Flush a trailing SSE event that is not terminated by a final blank line before the stream closes (common on error/aborted responses) instead of silently discarding it
* Fix dangling `else` in `stop()` so a not-yet-done future is cancelled correctly

## v1.0.6

* Add a basic test suite
* Add compat for jakarta based environments (e.g. Lucee 7)

## v1.0.5

* [#1](https://github.com/pixl8/lucee-sse-client/issues/1) Fix issue with non SSE based response body being lost

## v1.0.1

* Change interface for listeners: remove 'required' from all arguments as they may or may not be present
* Change data type for the SSE ID field - it does not need to be an integer
* Fix error when setting an http body
* Update README "Docs" to reflect changes

## 1.0.0

* Initial alpha release
