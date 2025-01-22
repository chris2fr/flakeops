flake-check:
	nix flake check

flake-build:
	nix build .

switch-flake:
	git checkout origin resdigidell
	git pull
	# git commit -am "Building new system"
	# git push
	sudo nixos-rebuild switch --upgrade --flake ./#nixos
