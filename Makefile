default:
	./run.sh
.PHONY: default

lint:
	shellcheck *.sh bin/* targets/*.sh targets/lib/*.sh targets/examples/*.sh lib.d/*.sh
.PHONY: lint
