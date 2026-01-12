workshop
{
  lib,
  stdenv,
  fetchurl,
  apacheHttpd,
  autoPatchelfHook,
  gzip,
  gnutar,
}:
stdenv.mkDerivation rec {
  pname = "mod_auth_openidc";
  version = "2.4.15"; # Update to the latest version

  src = fetchurl {
    url = "https://github.com/OpenIDC/mod_auth_openidc/releases/download/v${version}/mod_auth_openidc-${version}.tar.gz";
    sha256 = "sha256-1lAifqKaPDxmQh368O/CHY7TWluj9aWGzR4BI8gr2Xw="; # Replace with actual hash
  };

  nativeBuildInputs = [
    autoPatchelfHook # Automatically fix binary dependencies
    gzip
    gnutar
  ];

  buildInputs = [
    apacheHttpd
    # Add other library dependencies if needed
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    # Extract the .so file from the tarball
    tar -xzf $src
    mkdir -p $out/modules

    # The compiled .so is typically in the .libs directory
    cp mod_auth_openidc-${version}/.libs/mod_auth_openidc.so $out/modules/

    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenID Connect Relying Party implementation for Apache HTTP Server 2.x";
    homepage = "https://github.com/OpenIDC/mod_auth_openidc";
    license = licenses.asl20;
    platforms = ["x86_64-linux"];
    maintainers = ["Chris Mann"];
  };
}
