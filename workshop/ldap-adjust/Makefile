run:
	./.venv/bin/python ./ldap-adust.py

env:
	source ./.venv/bin/activate

buildenv:
	python -m venv .venv
	# source ./.venv/bin/activate
	./.venv/bin/python -m ensurepip --upgrade
	./.venv/bin/pip install -r requirements.txt
