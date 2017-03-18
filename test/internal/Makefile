BPP=../../libexec/bats-preprocess

out: bats-preprocess.bats
	${BPP} < bats-preprocess.bats > out


BATS_EXEC=../../libexec/bats-exec-test
mybats-exec-test: ${BATS_EXEC}
	sed -e 's/bats_/mybats_/g' \
	    -e 's/BATS_/MYBATS_/g' \
	    -e 's/\<setup\>/mysetup/g' \
	    -e 's/\<skip\>/myskip/g' \
	    -e 's/\<run\>/myrun/g' \
	    -e 's/\<teardown\>/myteardown/g' \
	      ${BATS_EXEC} > $@
