# to load this with nixos-rebuild, NIX_PATH has to contain the correct paths, use `sudo -E nixos-rebuild switch`
# to use it with nix-env, removing extraneous/old packages run `nix-env -f ./packages.nix -ir`
with (import <nixpkgs> {}).pkgs;
[
  # base utilities
  which
  file
  rlwrap
  bc
  xsel
  pinentry
  gnupg
  ack
  openssl
  zip
  unzip
  p7zip
  socat
  jwhois
  tree
  gptfdisk
  btrfsProgs

  # tools
  pdftk
  unetbootin
  wget
  openvpn
  tigervnc
  glxinfo
  nfsUtils
  nethogs
  bind
  sshpass
  graphviz
  binwalk
  nix-repl
  pwgen

  # dev
  fish
  python
  python3
  ruby_2_1
  python27Packages.virtualenv
  gnumake
  emacs
  ghc.ghc783
  gradle
  bazaar
  mercurial
  git
  gitAndTools.hub
  docker
  vagrant
  openjdk
  gradle
  clang
  qemu
  haskellPackages.yesodBin
  haskellngPackages.cabal-install
  idea.idea-community
  androidsdk_4_4
  ansible
  nixops
  redis
  leiningen
  scala
 
  # applications
  xpdf
  kde4.kvirc
  kde4.kdiff3
  kde4.ark
  firefox
  thunderbird
  inkscape
  chromium
  libreoffice

  # pentest
  nmap
  telnet
  net_snmp
] ++
(with (import <nixtrunk> {});
[
  haskellPackages.hoogleLocal
  haskellngPackages.cabal2nix
  iojs
  iojsPackages.npm
])
