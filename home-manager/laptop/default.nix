{
  config,
  pkgs,
  inputs,
  user,
  lib,
  host,
  system,
  ...
}:

let
  # Flake stuff
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;

  # Custom pkgs
  rofi-copyq = pkgs.callPackage ../../external/pkgs/rofi-copyq { };
  noita-worlds = pkgs.callPackage ../../external/pkgs/noita-worlds { };
  path-planner = pkgs.callPackage ../../external/pkgs/pathplanner { };
  utils = import ../modules/utils.nix {
    inherit
      lib
      pkgs
      inputs
      config
      ;
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  imports = [
    ../modules/hypr/hyprland.nix
    ../modules/hypr/hyprlock.nix
    ../modules/alacritty
    ../modules/rofi
    ../modules/eww
    ../modules/dunst
    ../modules/vscode

    # Flakes
    inputs.spicetify-nix.homeManagerModules.default
    inputs.nix-colors.homeManagerModule
    inputs.sops-nix.homeManagerModule
  ];

  config = {
    # System theme
    # Use custom themes customThemes.[theme] (defined in themes/custom.nix) or inputs.nix-colors.colorSchemes.[theme] themes list at https://github.com/tinted-theming/base16-schemes
    colorScheme = utils.customThemes.material-ocean;
    font = "FiraCode Nerd Font";

    cursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 16;
    };

    home.username = user;
    home.homeDirectory = "/home/${user}";

    # Unfree stuff/Insecure
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [ "qtwebkit-5.212.0-alpha4" ];

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = with pkgs; [
      # Apps
      gimp
      spotify
      qFlipper
      prismlauncher
      firefox-devedition
      element-desktop
      vesktop
      zoom-us
      ghidra

      pulseview
      gthumb
      wl-screenrec
      clapper
      ffmpeg
      killall
      utils.print-colors
      nautilus
      postman
      obs-studio
      nomacs
      qbittorrent
      # virt-manager
      slack
      freecad-wayland

      #Terminal Apps/Config
      zsh-powerlevel10k
      file
      playerctl
      base16-builder
      tree

      #Utils
      jq
      socat
      #      nvtop
      glxinfo
      bat
      openal
      qt5.full
      wget
      rofi-copyq
      gammastep
  

      #Customization
      swww

      # Scripts
      python3
      nodejs
      gcc

      # IDEs
      #     jetbrains.clion
      jetbrains.idea-ultimate

      # Game utils
      #    lutris
      wineWowPackages.waylandFull
      #   gamescope    
      winetricks
      mangohud
      gamemode
      noita-worlds
      protonplus
      # inputs.nix-gaming.packages.${pkgs.system}.wine-discord-ipc-bridge

      # Screenshot
      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
      slurp

      # Clipboard
      copyq

      # Virt
      distrobox

      # Fonts
      font-awesome
    ];

    programs.spicetify = {
      enable = false;
      theme = spicePkgs.themes.Ziro;
      colorScheme = "ziro";

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle
        hidePodcasts
        songStats
        powerBar
      ];
    };

    services.kdeconnect = {
      enable = true;
    };

    services.spotifyd.enable = true;

    dconf.settings = {

    };

    gtk.theme = {
      package = pkgs.lavanda-gtk-theme;
      name = "Lavanda-Dark";
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "${pkgs.hyprlock}/bin/hyprlock";
        };

        listener = [
          {
            timeout = 120;
            on-timeout = "kill $(pgrep eww)";
            on-resume = " ${pkgs.eww}/bin/eww open laptopMain";
          }
          {
            timeout = 500;
            on-timeout = "${pkgs.hyprlock}/bin/hyprlock";
          }
          {
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];

      };
    };

    
    # Random files

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
