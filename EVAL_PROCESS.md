In order to better understand what you can and can't do outside of `@test` blocks and `setup` or `teardown` functions, it's important to know how Bats processes test files.

Below is a walkthrough by Sam:

1. First, each test file is preprocessed. This essentially amounts to replacing lines like
`@test "first test" {`

with

`test_first_test() { bats_begin_test "first test";`

i.e. turning each `@test` block into a test function.

1. Then, each test file is executed n+1 times, where n is the number of test cases in the file.

The first run evaluates the file without running any test functions, counting all the test cases in the file. If you invoke bats with `-c`, execution ends here; otherwise, the first run prints out the TAP header `(1..n)`, then iterates over the test cases and executes each one in a new child process.

Each individual run again evaluates the entire test file, then invokes the setup function, if defined, then invokes the specified test function, and finally invokes teardown. An exit trap is responsible for printing the TAP status `(1 ok first test, 2 not ok second test)`.

If you call `exit` during the first run, the first run will not have a chance to invoke any test cases. That's a good way to fail fast if a dependency is missing. If you want to display an error message, though, you must take care to preserve the TAP stream written to `stdout`, since the runner may depend on it.

Anything written to `stdout` or `stderr` in `setup`, `teardown`, or a `test` function is captured by Bats. If the test case fails, the error trap prints the output to the TAP stream as a comment. Outside a test case, though, `stdout` is the TAP stream, so you'll want to specifically redirect any output to `stderr`.
