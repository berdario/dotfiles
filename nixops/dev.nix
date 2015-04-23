{
    network.description = "dev";

    devmachine = { config, pkgs, ... }:
    {
        environment.systemPackages = with pkgs; [
          git
          fish
          zip
          unzip
          wget
        ];

        users.extraUsers = {
          dario = {
            name = "dario";
            group = "users";
            extraGroups = ["wheel"];
            uid = 1000;
            createHome = true;
            home = "/home/dario";
            shell = "/run/current-system/sw/bin/fish";
          };
        };

        services.xserver = {
          enable = true;
          displayManager.kdm.enable = true;
          desktopManager.kde5.enable = true;
        };

        deployment.targetEnv = "virtualbox";
        deployment.virtualbox.memorySize = 2000; # megabytes
        networking.interfaces.eth1.ip4 = [ { address = "192.168.56.102"; prefixLength = 24; } ];
    } ;
}
