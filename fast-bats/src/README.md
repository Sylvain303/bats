# fast-bats C++ version

## build

```
make bats-preprocess
```

## run

```
diff -u \
 <(../../libexec/bats-preprocess  < ../../test/internal/bats-preprocess.bats) \
 <(./bats-preprocess preprocess < ../../test/internal/bats-preprocess.bats)
```
