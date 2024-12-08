{ config, pkgs, lib, ... }:
{
    home.packages = with pkgs; [ 
      python311
      python311Packages.pillow
      python311Packages.gunicorn
      python311Packages.pip
      libjpeg
      zlib
      libtiff
      freetype
      python311Packages.venvShellHook
    ];
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
}
