#!/bin/bash
set -euo pipefail
set nullglob

rm -rf relaypoolsrv-*-*

export GOPATH="$(pwd)/Godeps/_workspace:$GOPATH"

build() {
	export GOOS="$1"
	export GOARCH="$2"
	target="relaypoolsrv-$GOOS-$GOARCH"
	go build -i -v -ldflags -w
	mkdir "$target"
	if [ -f relaypoolsrv ] ; then
		mv relaypoolsrv "$target"
		tar zcvf "$target.tar.gz" "$target"
		rm -r "$target"
	fi
	if [ -f relaypoolsrv.exe ] ; then
		mv relaypoolsrv.exe "$target"
		zip -r "$target.zip" "$target"
		rm -r "$target"
	fi
}

go generate ./...

for goos in linux darwin windows freebsd openbsd netbsd solaris ; do
	build "$goos" amd64
done
for goos in linux windows freebsd openbsd netbsd ; do
	build "$goos" 386
done
build linux arm

# Hack used because we run as root under Docker
if [[ ${CHOWN_USER:-} != "" ]] ; then
	chown -R $CHOWN_USER .
fi
