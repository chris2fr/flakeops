gitup:
	git pull
	sudo nixos-rebuild switch  --flake ./#hetzner005

gitupup:
	git pull
	sudo nix-channel --list
	sudo nix-channel --update
	sudo nixos-rebuild switch -v --upgrade --flake ./#hetzner005

check:
	nix flake check

rollback:
	sudo nixos-rebuild switch --rollback --flake ./#hetzner005