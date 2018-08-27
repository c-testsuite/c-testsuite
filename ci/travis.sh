#! /usr/bin/env bash

set -x
set -e
set -u

testrundate="$(date +%Y-%m-%d)"

if test "$TRAVIS" = "true"
then
    curl https://nixos.org/nix/install | sh
    . "$HOME"/.nix-profile/etc/profile.d/nix.sh
fi

scratchdir=$(mktemp -d)
cleanup () {
  rm -rf $scratchdir
}
trap cleanup EXIT

# Get latest 9cc version.
if ! test -d 9cc_git
then
    git clone --depth 20 https://github.com/rui314/9cc 9cc_git
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

# install ccgo
nix-env -i go
# remove all the travis ci preset variables.
# they just break everything go related.
unset $(go env | cut  -f 1-1 -d'=')
go env
go get -v -u github.com/cznic/ccgo/v2/...
go get -v -u github.com/cznic/crt
export PATH=$HOME/go/bin:$PATH
(cd $HOME/go/src/github.com/cznic/ccgo/ && git rev-parse HEAD) > ccgo_version.txt

# install tcc
nix-env -i tcc
tcc -version > tcc_version.txt

# install compcert
NIXPKGS_ALLOW_UNFREE=1  nix-env -i compcert
ccomp --version > compcert_version.txt

# install gcc 
# ideally each runner just gets its own nix environment
# XXX we just use what travis offers for now.
gcc --version | head -n 1 > gcc_version.txt

# install clang
# XXX we just use what travis offers for now.
clang --version | head -n 1 > clang_version.txt

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
<a href="/9cc-x86_64_report.html">test report</a>
<br>
<a href="https://github.com/cznic/ccgo/tree/master/v2">ccgo</a>
<a href="/ccgo_report.html">test report</a>
<br>
<a href="https://clang.llvm.org/">clang</a>
<a href="/clang-x86_64_report.html">test report</a>
<br>
<a href="http://gcc.gnu.org/">gcc</a>
<a href="/gcc-x86_64_report.html">test report</a>
<br>
<a href="https://bellard.org/tcc/">tcc</a>
<a href="/tcc-x86_64_report.html">test report</a>
<br>
<a href="http://compcert.inria.fr/">compcert</a>
<a href="/compcert-x86_64_report.html">test report</a>
<br>

<br>
<a href="https://travis-ci.org/c-testsuite/c-testsuite">ci job history here</a>
<br>
last updated: $testrundate
</body>
</html>
EOF

for compiler in 9cc-x86_64 ccgo gcc-x86_64 clang-x86_64 tcc-x86_64 compcert-x86_64
do
    htmlfile="./output_html/${compiler}_report.html"

    cat <<EOF > "$htmlfile"
    <html>
    <header><title>$compiler report</title></header>
    <body>
EOF

    echo "<h2>$compiler</h2>" >> "$htmlfile"
    echo "<br>" >> "$htmlfile"
    echo "$compiler version:" >> "$htmlfile"
    echo "<br>" >> "$htmlfile"
    cat "${compiler}_version.txt" | ./scripts/htmlescape >> "$htmlfile"
    echo "<br>" >> "$htmlfile"
    echo "test date: $testrundate" >> "$htmlfile"


    for testsuite in single-exec
    do
        testrunname="$compiler-$testsuite"
        results="$scratchdir/$testrunname.tap"
        ./$testsuite $compiler | tee "$results"

        echo "<h3>$testsuite</h3>" >> "$htmlfile"
        echo "<br>" >> "$htmlfile"
        cp $results "./output_html/${testrunname}_report.tap.txt"
        cp $results "./output_html/${testrunname}_report.tap"
        echo "<pre>" >> "$htmlfile"
        ./scripts/tapsummary < "$results" | ./scripts/htmlescape >> "$htmlfile"
        echo "</pre>" >> "$htmlfile"
        echo "<br>" >> "$htmlfile"
        echo "<a href=\"/${testrunname}_report.tap\">raw TAP data</a> <a href=\"/${testrunname}_report.tap.txt\">(.txt)</a>" >> "$htmlfile"
        echo "<br>" >> "$htmlfile"
    done
    cat <<EOF >> "$htmlfile"
    </body>
    </html>
EOF

done

if test "$TRAVIS" = "true"
then
    # only deploy the site from main branch
    if test "$TRAVIS_PULL_REQUEST" = "false" 
    then
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
    fi
fi
