export ZIP_ENTRY ?= dist/pex_uwsgi_demo-0.1.0.zip

zip: clean
	@bash zipack.sh

UWSGI_BIN ?= /Users/reorx/.venv/packaging-test/bin/uwsgi

run-amod:
	PYTHONPATH="$$ZIP_ENTRY" $(UWSGI_BIN) \
		--module amod.wsgi:application \
		--master --workers 1 \
		--http :8000

run-bmod:
	PYTHONPATH="$$ZIP_ENTRY" $(UWSGI_BIN) \
		--module bmod.wsgi:application \
		--master --workers 1 \
		--http :8001

.PHONY: build
build:
	python setup.py build

clean:
	rm -rf build dist *.egg-info
