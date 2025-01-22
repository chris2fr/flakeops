flake-check:
	nix flake check

switch-flake:
	git pull
	# git commit -am "Building new system"
	# git push
	sudo nixos-rebuild switch --upgrade --flake ./#nixos
