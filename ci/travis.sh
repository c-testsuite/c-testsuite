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
(cd 9cc_git && git rev-parse HEAD) > 9cc_version.txt

# Setup gcc
# XXX parse gcc --version shitshow
echo "unspecified" > gcc_version.txt

# Run tests for each, generating html
test -d && rm -rf ./output_html
mkdir output_html


cat <<EOF > ./output_html/index.html
<html>
<header><title>ctest suite</title></header>
<body>
<h1>ctest-suite daily runner</h1>
See <a href="https://github.com/c-testsuite/c-testsuite">here</a> for more info.
<br>
<br>
<a href="https://github.com/rui314/9cc">9cc</a>
<a href="/9cc_latest.html">latest test results</a>
<br>
<a href="http://gcc.gnu.org/">gcc</a>
<a href="/gcc_latest.html">latest test results</a>
<br>

<br>
last updated: $testrundate
</body>
</html>
EOF

for compiler in 9cc gcc
do
    version="$(cat ${compiler}_version.txt)"
    htmlfile="./output_html/${compiler}_latest.html"

    cat <<EOF > "$htmlfile"
    <html>
    <header><title>$compiler latest</title></header>
    <body>
EOF

    echo "<h2>$compiler</h2>" >> "$htmlfile"

    for testsuite in simple-exec
    do
        testrunname="$compiler-$testsuite"
        results="$scratchdir/$testrunname.tap"
        ./$testsuite $compiler | tee "$results"

        echo "<h3>$testsuite</h3>" >> "$htmlfile"
        echo "<br>" >> "$htmlfile"
        cp $results "./output_html/${testrunname}_latest.tap.txt"
        cp $results "./output_html/${testrunname}_latest.tap"
        echo "<pre>" >> "$htmlfile"
        ./scripts/tapsummary < "$results" | ./scripts/htmlescape >> "$htmlfile"
        echo "</pre>" >> "$htmlfile"
        echo "<br>" >> "$htmlfile"
        echo "<a href=\"/${testrunname}_latest.tap\">raw TAP data</a> <a href=\"/${testrunname}_latest.tap.txt\">(.txt)</a>" >> "$htmlfile"
        echo "<br>" >> "$htmlfile"
    done
    echo "test date: $testrundate" >> "$htmlfile"
    echo "<br>" >> "$htmlfile"
    echo "$compiler version: $version" >> "$htmlfile"
    echo "<br>" >> "$htmlfile"
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