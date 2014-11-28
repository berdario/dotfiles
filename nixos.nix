# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      <nixpkgs/nixos/modules/programs/virtualbox.nix>
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";
  
  nixpkgs.config.virtualbox.enableExtensionPack = true;

  
  security.initialRootPassword = "!"; # disable root password login

  networking.hostName = "curie"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "uk";
    defaultLocale = "en_US.UTF-8";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  services.udev.extraRules = ''KERNEL=="vboxnetctl", OWNER="root", GROUP="vboxusers",      MODE="0660", TAG+="systemd"'';

  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "uk";
  services.xserver.xkbOptions = "eurosign:e";

  services.xserver.synaptics = {
    enable = true;
    tapButtons = false;
    twoFingerScroll = true;
    vertEdgeScroll = false;
  };
  

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.kdm.enable = true;
  services.xserver.desktopManager.kde4.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers = {
    dario = {
      name = "dario";
      group = "users";
      extraGroups = ["wheel" "vboxusers"];
      uid = 1000;
      createHome = true;
      home = "/home/dario";
      shell = "/nix/var/nix/profiles/default/bin/fish";
    };
  };
  
  # List packages installed in system profile. To search by name, run:
  # -env -qaP | grep wget
  environment.systemPackages = with pkgs; [
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
    socat

    # dev
    fish
    python
    python3
    ruby2
    python27Packages.virtualenv
    gcc
    gnumake
    emacs
    ghc.ghc782
    haskellPackages.hoogle
    gradle
    bazaar
    mercurial
    git
    gitAndTools.hub
    docker
    vagrant
    openjdk
    gradle
    nodePackages.npm
    
    # networking
    openvpn

    # applications
    xpdf
    kde4.kvirc
    # kde4.kwallet # I probably don't need this
    kde4.kdiff3
    firefox

    ## these are only in the unstable channel, atm
    #ideas.idea_community_1302
  ];

}
