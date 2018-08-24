# c-testsuite
A public database of simple C compiler test cases, minimal test runners, and public test results.

results are published daily to https://c-testsuite.github.io/

# runner

The top level test-suite runners output https://testanything.org output.

# test suites

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