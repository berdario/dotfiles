{
  packageOverrides = pkgs: rec {
    libpcap = pkgs.stdenv.lib.overrideDerivation pkgs.libpcap (oldAttrs: {
      # workaround for bug https://github.com/nmap/nmap/issues/34
      src = pkgs.fetchurl {
        url = "http://www.tcpdump.org/release/libpcap-1.4.0.tar.gz";
        sha256 = "7c6a2a4f71e8ab09804e6b4fb3aff998c5583108ac42c0e2967eee8e1dbc7406";
      };
    });
    socat = pkgs.stdenv.lib.overrideDerivation pkgs.socat (oldAttrs: {
      # add readline support
      nativeBuildInputs = [pkgs.openssl pkgs.readline ];
    });
    devstuff = with pkgs; buildEnv {
      name = "devstuff";
      paths = [
        rlwrap
        pinentry
        gnupg
        ack
        p7zip
        socat
        jwhois
        tree
        btrfsProgs
        pv

        # tools
        pdftk
        unetbootin
        openvpn
        nfs-utils
        nethogs
        sshpass
        graphviz
        binwalk
        nix-repl
        pwgen
        sshuttle
        iodine
        keybase-node-client
        rpcbind
        ncftp
        iotop
        iptraf
        iftop

        # dev
        fish
        python
        python3
        python32
        python33
        python34Packages.pew
        gnumake
        emacs
        ghc.ghc784
        gradle
        bazaar
        mercurial
        git
        gitAndTools.hub
        clang
        gcc
        haskellPackages.hoogleLocal
        haskellPackages.yesodBin
        haskellngPackages.cabal-install
        androidsdk_4_4
        ansible
        nixops
        redis
        leiningen
        fsharp
        scala
        gist
        # mono # will conflict with smuxi
        iojs
        lua
        luajit
        go
        rustc
        jruby165
        j
        haskellPackages.elmRepl
        haskellPackages.elmCompiler

        # pentest
        nmap
        net_snmp
        hping
      ];
      ignoreCollisions = true;
    };
    bleeding_edge = pkgs.buildEnv {
      name = "bleeding_edge";
      paths = (with (import <nixtrunk> {}); [
        haskellngPackages.cabal2nix
      ]);
    };
  };
}
