# bats internal unittest

`bats` functional testing are done in `../bats.bats`, not here.

Here, we do unit testing of bats internal.

## Goal

Proof of Concept: bats can tests itself, at unit-test level.

Having a good code coverage, so starting hacking bats itself will be very easy
and safe.

When unittest will be written, bats internal will be "documented" in unittests.

## Status

Partial draft.

internal scripts under test:

* bats-exec-test - **OK**
* bats-preprocess - **OK**

## How it works

`*.bats` file names reflect tests to `../../libexec/` matching filename.
`*_unit.bats` reflect internal unit tests.
`test_*.sh` external helpers to gain bash sub-script isolation.

Some files may be generated or left in this folder after test run.

We perform small changes in bats `libexec/*` so a single script can be sourced
as lib of function, in order to test it.

ie:

```bash
# will not execute main code, only load functions
source libexec/bats-exec-test
```

## Unit test concept

Unittesting is testing at each function level. So we directly test internal API.
It means that if a function API changes, related unittest need to be changed. It
is diffrent from functionnal testing, where the external behavior is tested.

In consequence, internal API change will need unittest to be changed or removed.

### Bats files already modified

* ~~bats~~
* ~~bats-exec-suite~~
* bats-exec-test - **OK**
* ~~bats-format-tap-stream~~
* bats-preprocess - **OK**

## Files
* `bats-exec-test_unit.bats`
* `bats-preprocess.bats` - functionnal internal tool hacking test
* `bats-preprocess_unit.bats`
* `lineno.txt` - helper input to test internal function
* `Makefile` - code generator (built results are commited)
* `mybats-exec-test` - See Makefile
* `README.md` - this file
* `test_mybats_*.sh` - external file for testing named function (bash code isolation)
* `test_helper.sh` - common helepers for external code
* `tools.bats` - tests `rewrite_bats_to_mybats.sh`

## Run

In order to run thoses tests:

### Build

Building some symetrical rewriting of bats internal script:

when bats-exec-test is modified, you can rebuild it.

```
make mybats-exec-test
```

### Run tests
Use a normal bats installation code to test itself:

(for now it runs only in its own folder)

```
cd test/internal
bats .
```

It must also work with this branch modified bats code:

```
cd test/internal
../../libexec/bats .
```
