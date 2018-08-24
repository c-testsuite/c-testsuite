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

# Get latest 9cc version.
if ! test -d 9cc_git
then
    git clone https://github.com/rui314/9cc 9cc_git
    cd 9cc_git
else
    cd 9cc_git
    git fetch --all
    git reset --hard origin/master
fi

git clean -fxd
if ! make
then
    echo "warning, 9cc build failed"
fi
export PATH="$(pwd)":$PATH
cd ..

# Run tests for each, generating html
test -d && rm -rf ./output_html
mkdir output_html


cat <<EOF > ./output_html/index.html
<html>
<header><title>ctest suite</title></header>
<body>
<h1>ctest-suite daily runner</h1>
<a href="https://github.com/rui314/9cc">9cc</a>
<a href="/9cc_latest.html">latest test results</a>
<br>
<a href="TODO">scc</a>
<a href="/scc_latest.html">latest test results</a>
last updated: $testrundate
<br>
</body>
</html>
EOF

for compiler in 9cc
do
    commit="$(cd ${compiler}_git && git rev-parse HEAD)"
    testrunname="$compiler-simple-exec-$testrundate-$commit.tap"
    results="$scratchdir/$testrunname"
    ./simple-exec 9cc | tee "$results"

    htmlfile="./output_html/${compiler}_latest.html"

    cat <<EOF > "$htmlfile"
    <html>
    <header><title>c-test-suite</title></header>
    <body>
EOF
    echo "<h2>$testrunname</h2>" >> "$htmlfile"
    echo "<a href=\"/${compiler}_latest.tap.txt\">$testrunname</a>" >> "$htmlfile"
    cp $results "./output_html/$testrunname.txt"
    echo "<pre>" >> "$htmlfile"
    ./scripts/tapsummary < $results >> "$htmlfile"
    echo "</pre>" >> "$htmlfile"

    cat <<EOF >> "$htmlfile"
    </body>
    </html>
EOF

done


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