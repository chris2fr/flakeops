{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = [ 
    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFhMZvVw9XmqlqsN7OkxQwmick74uPEwPFE3221SbShBnjq4uPqtKWzKQkV06gABvpyMEUHkM4ZaboAwKA8BR5jrO848MdDtkVVUjTAEcXndjB5eigotSeygsa3Ym+1Bt2OVornEJlN0C09UdwOQv9Jc1KgAt/mQIySi9hNF28Z0h1DA5NhECX0jyPaRVtApx1DkP8pqFx4UqOtiXPXi1XiJxcbWKmj9Z54+grf708bOXe5qYa1Ls3wYwIkgWsvyfNPEtCTiBqEyheXu5AkFz/b6jhoUM0cZATx4r1N9s47fhiu8dLrvsfe1Ujis98s8kb231lkUbf+MQnAvtzIch83OLylOmKQmGt1+jrLHnxcXJc9qsc4TyzCF/hfaASZbYjX3XGs4PG9HzVt/wD8bkWionO49rrnC09NlwujTfoALqHN2oQX5O5RTfiPwgYd+QoILFVjdE7eWVA/TA4csHTAOxZ/I6pzWPT3ZgHFcWgA+pzmfedOKeIqLRNmoSKuhE= mannchri@mannchri"
  ];
in {
  users.users = { 
    mannchri = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = mannchriRsaPublic;
      extraGroups = [ "wheel" "networkmanager" ];
    };
    admin = {
      isNormalUser = true;
      description = "admin";
      extraGroups = [ "networkmanager" "wheel" ];
      openssh.authorizedKeys.keys = mannchriRsaPublic;
    };
    nfsuser = {
      isNormalUser = true;
      description = "User nor NFS Shares";
      extraGroups = [ "users" ];
      openssh.authorizedKeys.keys = mannchriRsaPublic;
    };
  };
}
