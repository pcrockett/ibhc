.PHONY: default lint

default:
	./run.sh

lint:
	shellcheck *.sh
	shellcheck bin/*
	shellcheck targets/*.sh
