# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./local.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  security.initialRootPassword = "!"; # disable root password login
  security.sudo.extraConfig = ''
    Defaults        secure_path="/run/current-system/sw/bin/"
    '';

  networking.wireless.enable = true;  # Enables wireless.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "uk";
    defaultLocale = "en_GB.UTF-8";
  };

  time.timeZone = "GMT";

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.udev.extraRules = ''KERNEL=="vboxnetctl", OWNER="root", GROUP="vboxusers", MODE="0660", TAG+="systemd"'';

  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "gb";
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

  services.virtualboxHost.enable = true;
  nixpkgs.config.virtualbox.enableExtensionPack = true;

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
  environment.systemPackages = (with pkgs; [
    # TODO, think about moving out these packages, to make the system config more minimal
  
    # base utilities/software missing only on nixos systems
    which
    file
    bc
    sel
    openssl
    zip
    unzip
    gptfdisk
    wget
    tigervnc
    bind # for dig
    telnet
    ruby_2_2 # still need to rely on rbenv on other distros
  
    # software that relies on global libraries/stuff to be available (kernel modules, ui libraries)
    # and is thus installed only on nixos systems (non-nixos will use the native package manager for them)
    ## dev
    glxinfo
    vagrant
    qemu # maybe it would be ok on Ubuntu?
    openjdk # Apps on Ubuntu are often broken, also issues with jayatana
    idea.idea-community
    docker # requires the service running
   
    ## applications
    xpdf
    kde4.kvirc
    kde4.kdiff3
    kde4.ark
    firefox
    thunderbird
    inkscape
    chromium
    libreoffice

    # software that would cause collision with nix-env, and is thus outside of <common>
    gcc
  ]);

}
