# to load this with nixos-rebuild, NIX_PATH has to contain the correct paths, use `sudo -E nixos-rebuild switch`
# to use it with nix-env, removing extraneous/old packages run `nix-env -f ./packages.nix -ir`
with (import <nixpkgs> {}).pkgs;
[
  nix

  # base utilities
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

  # dev
  fish
  python
  python3
  gnumake
  emacs
  ghc.ghc784
  gradle
  bazaar
  mercurial
  git
  gitAndTools.hub
  clang
  haskellPackages.yesodBin
  haskellngPackages.cabal-install
  androidsdk_4_4
  ansible
  nixops
  redis
  leiningen
  scala
  gist
  # mono # will conflict with smuxi
  lua
  luajit

  # pentest
  nmap
  net_snmp
] ++
(with (import <nixtrunk> {});
[
  python34Packages.pew
  haskellPackages.hoogleLocal
  haskellngPackages.cabal2nix
  iojs
])
