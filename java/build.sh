#!/bin/bash

rm ../lib/*.jar

# Build javax version
cd lucee-javax
rm -rf artifacts
mkdir -p artifacts
mvn package || exit 1
cp target/luceesseclient-1.0.0-jar-with-dependencies.jar artifacts/luceesseclient-javax.jar
cd artifacts
unzip -q luceesseclient-javax.jar
echo "Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: Lucee SSE Http Client
Bundle-SymbolicName: org.pixl8.luceesseclient
Bundle-Version: 1.0.0
Export-Package: org.pixl8.luceesseclient,com.lupcode.HTTP.sse,com.lupcode.HTTP.sse.extensions
" > META-INF/MANIFEST.MF
rm luceesseclient-javax.jar
zip -rq luceesseclient-javax.jar *

cp luceesseclient-javax.jar ../../../lib/luceesseclient-javax.jar

# Build jakarta version
cd ../../lucee-jakarta
rm -rf artifacts
mkdir -p artifacts
mvn package || exit 1
cp target/luceesseclient-jakarta-1.0.0-jar-with-dependencies.jar artifacts/luceesseclient-jakarta.jar
cd artifacts
unzip -q luceesseclient-jakarta.jar
echo "Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: Lucee SSE Http Client
Bundle-SymbolicName: org.pixl8.luceesseclient
Bundle-Version: 1.0.0
Export-Package: org.pixl8.luceesseclient,com.lupcode.HTTP.sse,com.lupcode.HTTP.sse.extensions
" > META-INF/MANIFEST.MF
rm luceesseclient-jakarta.jar
zip -rq luceesseclient-jakarta.jar *

cp luceesseclient-jakarta.jar ../../../lib/luceesseclient-jakarta.jar