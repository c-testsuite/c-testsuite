# c-testsuite

This project aims to be a collaborative database of C compiler test cases,
minimal test runners, and public test results. The general idea is that
the various test suites here adhere to well defined, simple interfaces and projects can contribute
tests back that match those interfaces, or use those tests by implementing runner scripts matching
the specifications.

There are a number of tools, which include
1. C compilers,
2. Transpilers, 
3. Interpreters and emulators.
so we should seek to agree on simple easy test interfaces, and implement
those interfaces for a variety of tools.

results are published daily to https://c-testsuite.github.io/


# Test suites

The top level test-suite runners output https://testanything.org output.

## single-exec suite

entry point is ```./single-exec```

### runners/single-exec/*

The runner will be invoked as:

```
$ ./runners/single-exec/$NAME test/single-exec/case.c
```

The runner is free to output any data it wants, but must return
nonzero on failure.

The runner will be considered a failure if it takes more than 5 minutes.

### tests/single-exec/*

- Single .c file tests.
- 'main' is the entry point.
- The file $t.c.expected must match stdout+stderr of
  the test.
- The test programs exit with 0 on success.

C standard, Portability, preprocessor and libc requirements
are specified via tags that can be filtered against using
search queries, that can generate skip lists.

### Example:

```$ ./single-exec gcc-x86_64 ```


# Skipping tests

Try to skip a test if your compiler platform can NEVER pass it, the test is not appropriate.
In that case, there is only one mechanism, add a command that prints a list of tests to skip
on stdout named:

```
./runners/*/$TOOL.skip
```

# Search and query

All tests have a matching $t.tags file. This file specifies attributes
of the test that can be filtered and queried.

The query language is based off of https://github.com/oniony/TMSU tags.

The query language grammar is shown here:

https://github.com/oniony/TMSU/blob/master/misc/ebnf/query.ebnf

Support tags are currently

```
suite={single-exec, ...}
portable
	The test should be portable C.
arch-x86_64
	The test should pass on x86_64
c89
c99
c11
needs-cpp
    Test relies on the preprocessor
needs-libc
    Test relies on libc
```

Implicit tags:

c89 implies c99 and c11
c99 implies c11

example query:
```
$ ./scripts/make-search-index
$ ./scripts/search-tests "c99 suite=single-exec (portable or arch-amd64)"
```

These queries can be used to generate skip lists.

# otags files

otag files are intended to allow
a tests origin to be discovered. They contain the following fields.

```
org=$DOMAINNAME
repository=$SRCURL
version=$UNIQUE_VERSION
path=$TEST_PATH_IN_REPOSITORY
```

# Dependencies

Running tests

- posix sh
- python3
- coreutils
- tool under test

Querying tests:

Currently test search is based on

https://github.com/oniony/TMSU

We are sympathetic to those who do not wish to deal with
installing a lesser known third party tool, so will think of
ways to ease the burden in the future.

# Tips

## Naming test cases

The names are not stable for now, so if you 
refer to a test case in your issue tracker, it is best to 
name it something like ```c-testsuite/$CTESTGITCOMMIT/path/to/test```.

## Getting a summary from the command line

./single-exec $runner | ./scripts/tapsummary | head

## The full TAP test suites report can be viewed or 'curl'ed

For example:

- https://c-testsuite.github.io/gcc-x86_64_report.html
- https://c-testsuite.github.io/gcc-x86_64-single-exec_report.tap
- https://c-testsuite.github.io/gcc-x86_64-single-exec_report.tap.txt
