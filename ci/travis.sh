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

testrunname="9cc-simple-exec-$testrundate-$commit9cc.tap"
results9cc="$scratchdir/$testrunname"
./simple-exec 9cc | tee "$results9cc"

test -d output_html || mkdir output_html

cat <<EOF > ./output_html/index.html
<html>
<header><title>c-test-suite</title></header>
<body>
EOF

echo "<a href=\"/$testrunname\">$testrunname</a>" >> ./output_html/index.html
cp $results9cc ./output_html/$testrunname

cat <<EOF >> ./output_html/index.html
</body>
</html>
EOF