#! /usr/bin/env bash

set -x
set -e
set -u

testrundate="$(date +%Y-%m-%d)"

scratchdir=$(mktemp -d)
cleanup () {
  rm -rf $scratchdir
}
trap cleanup EXIT

if ! test -d 9cc-git
then
    git clone https://github.com/rui314/9cc 9cc-git
    cd 9cc-git
else
    cd 9cc-git
    git fetch --all
    git reset --hard origin/master
fi

commit9cc=$(git rev-parse HEAD)

git clean -fxd
if ! make
then
    echo "warning, 9cc build failed"
fi
export PATH="$(pwd)":$PATH
cd ..

results9cc="$scratchdir"/9cc-simple-exec-"$testrundate"-"$commit9cc".tap
./simple-exec 9cc | tee "$results9cc"

