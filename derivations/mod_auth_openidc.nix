{ lib, stdenv, fetchurl, apacheHttpd, openssl, curl, cjose, pkg-config }:

stdenv.mkDerivation rec {
  pname = "mod_auth_openidc";
  version = "2.4.15"; # Update to latest version

  src = fetchurl {
    url = "https://github.com/OpenIDC/mod_auth_openidc/releases/download/v${version}/mod_auth_openidc-${version}.tar.gz";
    sha256 = ""; # Update with actual hash
  };

  buildInputs = [ apacheHttpd openssl curl cjose pkg-config ];

  configureFlags = [
    "--with-apxs2=${apacheHttpd}/bin/apxs"
    "--with-curl=${curl.dev}"
    "--with-cjose=${cjose}"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/modules
    cp .libs/mod_auth_openidc.so $out/modules/
    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenID Connect Relying Party implementation for Apache HTTP Server 2.x";
    homepage = "https://github.com/OpenIDC/mod_auth_openidc";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}