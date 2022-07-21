.PHONY: default lint

default:
	./run.sh

lint:
	shellcheck *.sh bin/* targets/*.sh targets/lib/*.sh targets/examples/*.sh lib.d/*.sh
