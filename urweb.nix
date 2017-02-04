{ pkgs ? import <nixpkgs> {} , debug ? false }:

with pkgs;

stdenv.mkDerivation rec {
  basename = "urweb-${version}";
  name = basename + (pkgs.lib.optionalString debug "-debug");
  version = "20161022";

  src = fetchurl {
    url = "http://www.impredicative.com/ur/${basename}.tgz";
    sha256 = "060682ad4f2andi9z7liw5z8c2nz7h6k8gd32fm3781qp49i60ks";
  };

  buildInputs = [ openssl mlton mysql.client postgresql sqlite ];

  prePatch = ''
    sed -e 's@/usr/bin/file@${file}/bin/file@g' -i configure
  '';

  configureFlags = "--with-openssl=${openssl.dev}";

  preConfigure = ''
    ${if debug then "export CFLAGS='-g -O0';" else ""}
    export PGHEADER="${postgresql}/include/libpq-fe.h";
    export MSHEADER="${lib.getDev mysql.client}/include/mysql/mysql.h";
    export SQHEADER="${sqlite.dev}/include/sqlite3.h";

    export CCARGS="-I$out/include \
                   -L${lib.getLib mysql.client}/lib/mysql \
                   -L${postgresql.lib}/lib \
                   -L${sqlite.out}/lib";
  '';

  # Be sure to keep the statically linked libraries
  dontDisableStatic = true;

  dontStrip = debug;

  meta = {
    description = "Advanced purely-functional web programming language";
    homepage    = "http://www.impredicative.com/ur/";
    license     = stdenv.lib.licenses.bsd3;
    platforms   = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.thoughtpolice ];
  };
}
