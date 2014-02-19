# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <nixpkgs/nixos/modules/programs/virtualbox.nix>
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";
  # boot.loader.gummiboot.enable = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "it";
    defaultLocale = "en_US.UTF-8";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  security.initialRootPassword = "!"; # disable root password login

  services.udev.extraRules = ''KERNEL=="vboxnetctl", OWNER="root", GROUP="vboxusers",      MODE="0660", TAG+="systemd"'';

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "it";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.kdm.enable = true;
  services.xserver.desktopManager.kde4.enable = true;

  users.extraUsers = {
      dario = {
	createHome = true;
	description = "Dario Bertini";
	extraGroups = ["wheel" "vboxusers"];
	group = "users";
	home = "/home/dario";
	uid = 1000;
      };
  };

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
    unzip

    # dev
    fish
    python
    python3
    ruby2
    python27Packages.virtualenv
    gcc
    gnumake
    emacs
    gradle
    bazaar
    mercurial
    git
    openjdk
    gradle

    # applications
    xpdf
    kde4.kvirc
    # kde4.kwallet # I probably don't need this
    kde4.kdiff3
    firefox

    ## these are only in the unstable channel, atm
    #ideas.idea_community_1302
    #vagrant
  ];
}
