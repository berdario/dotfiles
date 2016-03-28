{
  packageOverrides = pkgs: let self = pkgs.pkgs; in {
    libpcap = pkgs.stdenv.lib.overrideDerivation pkgs.libpcap (oldAttrs: {
      # workaround for bug https://github.com/nmap/nmap/issues/34
      src = pkgs.fetchurl {
        url = "http://www.tcpdump.org/release/libpcap-1.3.0.tar.gz";
        sha256 = "41cbd9ed68383afd9f1fda279cb78427d36879d9e34ee707e31a16a1afd872b9";
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
        keybase
        rpcbind
        ncftp
        iotop
        iptraf
        iftop
        samba
        youtube-dl
        self.socat
        dos2unix
        smem
        fdupes
      ];
    };
    generic_dev = buildEnv {
      name = "generic_dev";
      paths = [
        fish
        gnumake
        emacs
        neovim
        bazaar
        mercurial
        git
        gitAndTools.hub
        ansible
        nixops
        redis
        jq
        phantomjs
        cloc
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
        (haskellPackages.ghcWithPackages (hpkgs: with hpkgs; [
          cabal-install.env
        ]))
        haskellPackages.stack
        haskellPackages.ghc
        haskellPackages.hoogle
        haskellngPackages.cabal2nix
        haskellPackages.yesod
        haskellPackages.cabal-install
        haskellPackages.hlint
        haskellPackages.stylish-haskell
      ];
    };
    dev = buildEnv {
      name = "dev"; # watch out for conflicts...
      paths = [
        # gradle # unused
        # androidsdk_4_4 # unused
        ant
        leiningen
        scala
        gist
        nodejs
        lua
        luajit
        go
        jruby
      ];
    };
    huge_dev = buildEnv {
      name = "huge_dev"; #slow to build
      paths = [
        #clang
        #gcc
        fsharp
        rustc
        # mono # will conflict with smuxi
      ];
      ignoreCollisions = true;
    };
    niche_dev = buildEnv {
      name = "niche_dev";
      paths = [
        j
        haskellPackages.elm-repl
        haskellPackages.elm-compiler
      ];
    };
    pentest = buildEnv {
      name = "pentest";
      paths = [
        self.nmap
        net_snmp
        hping
        tcpflow
        john
        zap
      ];
    };
    bleeding_edge = pkgs.buildEnv {
      name = "bleeding_edge";
      paths = (with (import <nixtrunk> {}); [
        # woot, nothing here for now
      ]);
    };
    devstuff = pkgs.buildEnv {
      name = "devstuff";
      paths = [
        self.base_tools
        self.system_tools
        self.generic_dev
        # self.python_dev # no advantage and conflicts... should focus on project profiles
        # self.haskell_dev
        self.dev
        # self.niche_dev # broken
        self.pentest
        self.bleeding_edge
      ];
    };
  });
}
