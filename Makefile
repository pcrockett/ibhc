.PHONY: default lint

default:
	./run.sh

lint:
	shellcheck *.sh bin/* targets/*.sh lib.d/*.sh
