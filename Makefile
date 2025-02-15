SHELL=/bin/bash
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
.ONESHELL:

.PHONY: clean build setup update test

clean:
	@echo "Cleaning up..."
	deactivate 2>/dev/null || true; rm -rf ./.venv
	conda deactivate 2>/dev/null || true; rm -rf ./.poetry

build:
	@echo "Building environment..."
	. $$(conda info --base)/etc/profile.d/conda.sh
	[[ -d "./.poetry" ]] || conda create -y -p ./.poetry
	conda activate ./.poetry
	conda install -y openssl poetry jq yq
	conda update --all -y && conda list --explicit > ./environment.yaml
	cat > ./poetry.toml <<EOF
	[virtualenvs]
	in-project = true
	path = ".venv"
	create = false
	EOF
	[[ -d "./.venv" ]] || python -m venv ./.venv
	source ./.venv/bin/activate
	pip install --upgrade pip poetry
	rm -f ./pyproject.toml ./poetry.lock
	poetry env use python3.11
	poetry init -n
	poetry add ansible-core ansible-compat askpass dnspython jinja2 jinja2-ansible-filters jmespath netaddr passlib pywinrm
	poetry add --group=dev ansible-lint ansible-runner ansible-bender molecule molecule-vagrant autopep8 black build flake8 installer mypy pylint pytest pytest-testinfra pytest-xdist setuptools six wheel 
	poetry update && poetry lock

setup:
	@echo "Setting up environment..."
	. $$(conda info --base)/etc/profile.d/conda.sh
	[[ -d "./.poetry" ]] || conda create --file ./environment.yaml -p ./.poetry
	conda activate ./.poetry 
	[[ -d "./.venv" ]] || python -m venv ./.venv

update:
	@echo "Updating dependencies..."
	. $$(conda info --base)/etc/profile.d/conda.sh	
	conda activate ./.poetry
	conda update --all -y && conda list --explicit > ./environment.yaml
	source ./.venv/bin/activate
	poetry update && poetry lock
	ansible-galaxy collection install -r requirements.yaml
	ansible-galaxy role       install -r requirements.yaml

test:
