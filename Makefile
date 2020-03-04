.DEFAULT_GOAL := prepare

prepare: format ameba test docs

format:
	crystal tool format $(only)

ameba:
	ameba

test:
	crystal spec --error-trace -t -Dpreview_mt $(spec)

docs:
	crystal docs
