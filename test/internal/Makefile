BPP=../../libexec/bats-preprocess

ALL: out mybats-exec-test

out: bats-preprocess.bats
	${BPP} < bats-preprocess.bats > out


BATS_EXEC=../../libexec/bats-exec-test
mybats-exec-test: ${BATS_EXEC}
	./rewrite_bats_to_mybats.sh ${BATS_EXEC} > $@


clean:
	rm -f out mybats-exec-test
