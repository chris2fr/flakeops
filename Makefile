switch-flake:
	git pull
	# git commit -am "Building new system"
	# git push
	sudo nix-channel --update
	sudo nixos-rebuild switch --upgrade --flake ./#nixos

flake-check:
	nix flake check
	