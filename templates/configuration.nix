################################################################################
# █▄░█ █ ▀▄▀ █▀█ █▀ ▄▄ █░█ █▀█
# █░▀█ █ █░█ █▄█ ▄█ ░░ █▄█ █▀▀
#
# 🚀 This NixOS installation brought to you by nixos-up! 🚀
# Please consider supporting the project (https://github.com/samuela/nixos-up)
# and the NixOS Foundation (https://opencollective.com/nixos)!
################################################################################
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  config,
  pkgs,
  ...
}: let
  home-manager = fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
in {
  # Your home-manager configuration! Check out https://rycee.gitlab.io/home-manager/ for all possible options.
  home-manager.users.{{username}} = {pkgs, ...}: {
    home.packages = with pkgs; [hello];
    programs.starship.enable = true;
  };

  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Include the home-manager nixos module
    "${home-manager}/nixos"
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  {% if efi -%}
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  {% else -%}
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/{{selected_disk_name}}";
  {% endif -%}

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "{{timezone}}";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  {% if graphical -%}
  services.xserver.enable = true;
  # See https://nixos.wiki/wiki/GNOME.
  services.xserver.desktopManager.gnome.enable = true;
  {% else -%}
  # services.xserver.enable = true;
  {% endif -%}


  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  {% if graphical -%}
  services.printing.enable = true;
  {% else -%}
  # services.printing.enable = true;
  {% endif -%}

  # Enable sound.
  {% if graphical -%}
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  {% else -%}
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
  {% endif -%}

  # Enable touchpad support (enabled default in most desktopManager).
  {% if graphical -%}
  services.xserver.libinput.enable = true;
  {% else -%}
  # services.xserver.libinput.enable = true;
  {% endif -%}

  users.mutableUsers = false;
  users.users.{{username}} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    passwordFile = "/etc/passwordFile-{{username}}";
    {% if ssh -%}
    openssh.authorizedKeys.keys = [
      {%- for key in ssh_keys -%}
      "{{key}}"
      {%- endfor -%}
    ];
    {% endif -%}
  };

  # Disable password-based login for root.
  users.users.root.hashedPassword = "!";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # This setups a SSH server. Very important if you're setting up a headless system.
  services.openssh = {
    {% if ssh -%}
    enable = true;
    {% else -%}
    enable = false;
    {% endif -%}
    # Forbid root login through SSH.
    permitRootLogin = "no";
    # Use keys only. Remove if you want to SSH using password (not recommended)
    passwordAuthentication = false;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # Configure swap file. Sizes are in megabytes. Default swap is
  # max(1GB, sqrt(RAM)) = 1024. If you want to use hibernation with
  # this device, then it's recommended that you use
  # RAM + max(1GB, sqrt(RAM)) = {{hibernation_swap_mb}}.
  swapDevices = [
    {
      device = "/swapfile";
      size = {{swap_mb}};
    }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
