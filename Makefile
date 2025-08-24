gitup:
	git pull
	sudo nixos-rebuild switch  --flake ./#nixos

gitupup:
	git pull
	sudo nix-channel --list
	sudo nix-channel --update
	sudo nixos-rebuild switch -v --upgrade --flake ./#nixos

check:
	nix flake check