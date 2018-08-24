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

test -d && rm -rf ./output_html
mkdir output_html

cat <<EOF > ./output_html/index.html
<html>
<header><title>c-test-suite</title></header>
<body>
EOF

echo "<a href=\"/$testrunname.txt\">$testrunname</a>" >> ./output_html/index.html
cp $results9cc ./output_html/$testrunname.txt

cat <<EOF >> ./output_html/index.html
</body>
</html>
EOF


set +x
umask 077
gpg2 --batch --passphrase "$DEPLOY_SSH_KEY_PASSWORD" --decrypt ./ci/deploy_key.gpg > ./ci/deploy_key
set -x
export GIT_SSH_COMMAND="ssh -i $(pwd)/ci/deploy_key"
cd ./output_html
git init
git remote add origin git@github.com:c-testsuite/c-testsuite.github.io.git
git add *
git commit -m "automated commit" -a
git push -f --set-upstream origin master