{
  packageOverrides = pkgs: rec {
    libpcap = pkgs.stdenv.lib.overrideDerivation pkgs.libpcap (oldAttrs: {
      src = pkgs.fetchurl {
        url = "http://www.tcpdump.org/release/libpcap-1.4.0.tar.gz";
        sha256 = "7c6a2a4f71e8ab09804e6b4fb3aff998c5583108ac42c0e2967eee8e1dbc7406";
      };
    });
  };
}