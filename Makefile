switch-flake:
	git pull origin t330roses.lesgrandsvoisins.com
	sudo nixos-rebuild switch --upgrade --flake ./#nixos
