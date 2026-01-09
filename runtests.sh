#!/bin/bash

cd `dirname $0`

box install

exitcode=0

box stop name="lucee-sse-client-tests"
box start directory="./tests/" serverConfigFile="./tests/server.json"
box testbox run verbose=true || exitcode=1
box stop name="lucee-sse-client-tests"

exit $exitcode


