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
  } // (with pkgs; {
    base_tools = buildEnv {
      name = "base_tools";
      paths = [
        rlwrap
        pinentry
        gnupg
        ack
        p7zip
        jwhois
        tree
        btrfsProgs
        pv
      ];
    };
    system_tools = buildEnv {
      name = "system_tools";
      paths = [
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
        samba
        youtube-dl
      ];
    };
    generic_dev = buildEnv {
      name = "generic_dev";
      paths = [
        fish
        gnumake
        emacs
        bazaar
        mercurial
        git
        gitAndTools.hub
        ansible
        nixops
        redis
      ];
    };
    python_dev = buildEnv {
      name = "python_dev";
      paths = [
        python
        python3
        python32
        python33
        python34Packages.pew
      ];
      ignoreCollisions = true;
    };
    haskell_dev = buildEnv {
      name = "haskell_dev";
      paths = [
        ghc.ghc784
        haskellPackages.hoogleLocal
        haskellPackages.yesodBin
        haskellngPackages.cabal-install
      ];
    };
    dev = buildEnv {
      name = "dev";
      paths = [
        gradle
        clang
        gcc
        androidsdk_4_4
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
      ];
      ignoreCollisions = true;
    };
    niche_dev = buildEnv {
      name = "niche_dev";
      paths = [
        j
        haskellPackages.elmRepl
        haskellPackages.elmCompiler
      ];
    };
    pentest = buildEnv {
      name = "pentest";
      paths = [
        nmap
        net_snmp
        hping
        tcpflow
        john
      ];
    };
    bleeding_edge = pkgs.buildEnv {
      name = "bleeding_edge";
      paths = (with (import <nixtrunk> {}); [
        haskellngPackages.cabal2nix
      ]);
    };
  });
}
# nix-env -f '<nixpkgs>' -iA base_tools system_tools generic_dev python_dev haskell_dev dev niche_dev pentest bleeding_edge
