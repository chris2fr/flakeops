gitup:
	git pull
	sudo nixos-rebuild switch  --flake ./#nixos

check:
	nix flake check