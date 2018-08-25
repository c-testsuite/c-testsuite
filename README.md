# c-testsuite

This project aims to be a collaborative database of C compiler test cases,
minimal test runners, and public test results. The general idea is that
the various test suites here adhere to well defined, simple interfaces and projects can contribute
tests back that match those interfaces, or use those tests by implementing runner scripts matching
the specifications.

There are many tools that may benefit such as C compilers, transpilers, interpreters and emulators, so we should seek to agree on simple easy test interfaces, and implement
those interfaces for a variety of tools.

results are published daily to https://c-testsuite.github.io/


# Test suites

The top level test-suite runners output https://testanything.org output.

## simple-exec suite

entry point is ```./simple-exec```

### runners/simple-exec/*

The runner will be invoked as:

```
$ ./runners/simple-exec/$NAME test/simple-exec/case.c
```

The runner is free to output any data it wants, but must return
nonzero on failure.

The runner will be considered a failure if it takes more than 5 minutes.

### tests/simple-exec/*

- Single .c file tests.
- 'main' is the entry point.
- These tests must not require a preprocessor.
- They are not linked against any libraries.
- If the file $t.c.expected exists, stdout of test must match this.

### Example:

```$ ./simple-exec gcc ```

## output-exec suite

entry point is ```./output-exec```

### runners/output-exec/*

The runner will be invoked as:

```
$ ./runners/output-exec/$NAME test/output-exec/case.c
```

The runner is free to output any data it wants, but must return
nonzero on failure.

The runner will be considered a failure if it takes more than 5 minutes.

The runner is responsible for checking output and running the binary. This
allows for emulators and other configuration.

### tests/output-exec/*

- Single .c file tests.
- 'main' is the entry point.
- These tests must not require a preprocessor.
- They may use 'exit, abort, printf' calls.
- If the file $t.c.expected exists, stdout+stderr of test must match this.


### Example:

```$ ./output-exec gcc ```


# Skipping tests

Only skip a test if your compiler platform can NEVER pass it, the test is not appropriate.
In that case, there is only one mechanism, add the test as a single line to the file:

```
./runners/*/$COMPILER.skip
```

# Dependencies

- posix sh
- python3
- coreutils
- tool under test

# Tips

## Getting a summary from the command line

./simple-exec gcc | ./scripts/tapsummary | head

## The full TAP test suites report can be viewed or 'curl'ed

For example:

- https://c-testsuite.github.io/gcc_report.html
- https://c-testsuite.github.io/gcc-simple-exec_report.tap
- https://c-testsuite.github.io/gcc-simple-exec_report.tap.txt
