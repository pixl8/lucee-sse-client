#!/bin/bash

rm -rf artifacts/*
mvn package || exit 1
cd artifacts
unzip luceesseclient-1.0.0.jar
echo "Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: Lucee SSE Http Client
Bundle-SymbolicName: org.pixl8.luceesseclient
Bundle-Version: 1.0.0
" > META-INF/MANIFEST.MF
rm luceesseclient-1.0.0.jar
zip -rq luceesseclient-1.0.0.jar *

cp luceesseclient-1.0.0.jar ../../lib/
