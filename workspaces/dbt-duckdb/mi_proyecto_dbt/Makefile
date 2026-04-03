PY ?= python3
VENV ?= .venv
PIP := $(VENV)/bin/pip
DBT := $(VENV)/bin/dbt

.PHONY: install venv clean run compile debug build test

venv:
	@test -d $(VENV) || $(PY) -m venv $(VENV)

install: venv requirements.txt
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	@echo
	@echo "Installed into $(VENV). Activate with: source $(VENV)/bin/activate"

clean:
	rm -rf $(VENV)
	# Optional: remove build/test artifacts
	rm -rf target logs dbt_packages
	find . -type d -name "__pycache__" -prune -exec rm -rf {} +

run: install
	$(DBT) run --profiles-dir .

compile: install
	$(DBT) compile --profiles-dir .

debug: install
	$(DBT) debug --profiles-dir .

build: install
	$(DBT) build --profiles-dir .

test: install
	$(DBT) test --profiles-dir .
