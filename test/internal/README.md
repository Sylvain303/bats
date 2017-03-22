# bats internal unittest

bats fonctional testing are done in `../bats.bats`, not here.

Here we do unit testing of bats internal.

## Goal

Proof of Concept: bats can test itself.

Having a good code coverage, so starting hacking bats itself will be very easy
and safe.

At the end bats internal will be "documented" in unittests.

## Status

Partial draft.

## How it works

`*.bats` file names reflect tests to `../../libexec/` matching filename.
`*_unit.bats` reflect internal unit tests.
`test_*.sh` external helpers to gain bash sub-script isolation.

Some file may be generated or left in this folder after test run.

We perform small changes in bats `libexec/*` so a single script can be sourced
as lib of function, in order to test it.

### Files already modified

* ~~bats~~
* ~~bats-exec-suite~~
* ~~bats-exec-test~~ - in progress See: mybats-exec-test
* ~~bats-format-tap-stream~~
* bats-preprocess - **OK**

## Files
* `bats-exec-test_unit.bats`
* `bats-preprocess.bats` - functionnal internal tool hacking test
* `bats-preprocess_unit.bats`
* `lineno.txt` - helper input to test internal function
* `Makefile` - code generator rules (work in progress)
* `mybats-exec-test` - handcrafted rewrite of bats-exec-test script (in
  progress)
* `README.md` - this file
* `test_mybats_exit_trap1.sh` - external file for testing named function (bash
  code isolation)

## Run

### Build

Building some symetrical rewring of bats internal script in order to test them.

Not working yet.
```
# make mybats-exec-test
```

### Run tests
use a normal bats installation code to test itself:

```
cd test/internal
bats .
```

must also works with this branch modified bats code:

```
cd test/internal
../../libexec/bats .
```
