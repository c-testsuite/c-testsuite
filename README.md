# c-testsuite

This project aims to be a collaborative database of C compiler test cases,
minimal test runners, and public test results. The general idea is that
the various test suites here adhere to well defined, simple interfaces and projects can contribute
tests back that match those interfaces, or use those tests by implementing runner scripts matching
the specifications.

There are many tools that may benefit such as C compilers, transpilers, interpreters and emulators, so we should seek to agree on simple easy test interfaces, and implement
those interfaces for a variety of tools.

results are published daily to https://c-testsuite.github.io/

# Runner

The top level test-suite runners output https://testanything.org output.

# Test suites

## tests/simple-exec/*

- Single .c file tests.
- These tests must not require a preprocessor.
- They are linked against libc.
- If the file $t.c.expected exists, stdout of test must match this.

The drivers for simple-exec must live at ```runners/simple-exec/$COMPILER```

The driver will be invoked as:

```
$ ./runners/simple-exec/$COMPILER test/simple-exec/case.c
```

The runner is free to output any data it wants, but must return
nonzero on failure.

The runner will be considered a failure if it takes more than 5 minutes.

The runner is responsible for checking output and running the binary. This
allows for emulators and other configuration.

### Example:

```$ ./simple-exec 9cc ```


# Skipping tests

Only skip a test if your compiler platform can NEVER pass it, the test is not appropriate.
In that case, there is only one mechanism, add the test as a single line to the file:

```
/runners/*/$COMPILER.skip
```

# Tips

## Getting a summary from the command line

./simple-exec gcc | ./scripts/tapsummary | head

## The full TAP test suites report can be viewed or 'curl'ed

https://c-testsuite.github.io/gcc_report.html
https://c-testsuite.github.io/gcc-simple-exec_report.tap
https://c-testsuite.github.io/gcc-simple-exec_report.tap.txt



# TODO

- Come up with a reliable installation and running method. The nix package manager or docker are good candidates.
- Factor runners to reduce duplication.
- Split runners by arch and platform.
- Add emulated runners.
- Split tests by C standard somehow.
- Add error tests, where the compiler is expected to fail.
- Add zero dependency program test runners... programs like cat/sort/w.e. we can compile like cc *.c then stress test.
- A csmith suite + runners, where the whole suite itself is generated randomly first.

# Maybe

- Come up with a test tagging system, and use it to generate skip lists automatically based on features.
- C reduce minimal test cases.
- Remove naming tests at all, refer to them by shasum.
- Have some sort of test fingerprinter to detect duplicate or similar tests.
- Compiler code coverage hooks.