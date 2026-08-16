{ config, pkgs, lib, inputs, ... }:

{
  # ===========================================================================
  # 0. GC / LIMPEZA DO NIX
  # ===========================================================================
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ===========================================================================
  # 1. IMPORTS
  # ===========================================================================
  imports = [
    ./hardware-configuration.nix
    inputs.noctalia.nixosModules.default
  ];

  # ===========================================================================
  # 2. RECURSOS DO NIX, FLAKES E CACHIX DO NOCTALIA
  # ===========================================================================
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };
  
  nixpkgs.config.allowUnfree = true;

  # ===========================================================================
  # 3. BOOT E KERNEL
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" "exfat" "vfat" ];

  # ===========================================================================
  # 4. REDE E HOSTNAME
  # ===========================================================================
  networking.hostName = "nixos-btw"; 
  networking.networkmanager.enable = true;

  # ===========================================================================
  # 5. HARDWARE, BLUETOOTH E ÁUDIO
  # ===========================================================================
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ===========================================================================
  # 6. LOCALIZAÇÃO E IDIOMA
  # ===========================================================================
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # ===========================================================================
  # 7. USUÁRIO DO SISTEMA E SHELL GLOBAL
  # ===========================================================================
  users.users.Gabriel = {
    isNormalUser = true;
    description = "Gabriel";
    extraGroups = [ "networkmanager" "wheel" "input" "video" "audio" ];
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      ls = "eza --icons=always --group-directories-first";
      ll = "eza -alF --icons=always --group-directories-first";
      la = "eza -a --icons=always --group-directories-first";
      lt = "eza --tree --level=2 --icons=always";
      cat = "bat";
      c = "clear";
      update = "sudo nixos-rebuild switch --flake /etc/nixos#nixos-btw"; 
    };
  };

  # ===========================================================================
  # 8. INTERFACE GRÁFICA (Niri + Noctalia Shell Stack)
  # ===========================================================================
  programs.niri.enable = true;
  services.displayManager.ly.enable = true;

  # Noctalia Shell configurado com serviços recomendados e systemd ativado
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
    systemd.enable = true; 
  };

  programs.dconf.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  security.polkit.enable = true;

  # ===========================================================================
  # 9. QT, IMPRESSÃO E VARIÁVEIS DE SESSÃO
  # ===========================================================================
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "breeze";
  };

  services.printing.enable = true;

  environment.sessionVariables = {
    XCURSOR_THEME = "WhiteSur-cursors";
    XCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
  };

  # ===========================================================================
  # 10. PACOTES GLOBAIS DO SISTEMA
  # ===========================================================================
  environment.systemPackages = with pkgs; [
    brave
    ghostty
    spotify-spotx  

    xwayland-satellite
    
    git
    curl
    wget
    bat
    eza
    fd
    ripgrep
    fzf
    zoxide
    p7zip
    fastfetchMinimal
    bitwarden-cli
    prismlauncher

    nautilus
    polkit_gnome
    
    yazi
    imv

    ffmpegthumbnailer
    imagemagick
    poppler-utils
    gnome-epub-thumbnailer

    cups-pk-helper
    starship
    whitesur-icon-theme
    whitesur-cursors
  ];

  # ===========================================================================
  # 11. FONTES
  # ===========================================================================
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.symbols-only
   ];

  # ===========================================================================
  # 12. JOGOS / STEAM
  # ===========================================================================
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Patch do SLSsteam injetado no ambiente da Steam
    package = pkgs.steam.override {
      extraEnv = {
        LD_AUDIT = "${inputs.sls-steam.packages.${pkgs.stdenv.hostPlatform.system}.sls-steam}/library-inject.so:${inputs.sls-steam.packages.${pkgs.stdenv.hostPlatform.system}.sls-steam}/SLSsteam.so";
      };
     };
     };

  programs.xwayland.enable = true;

services.gvfs.enable = true;
services.udisks2.enable = true;   
  
  # ===========================================================================
  # 13. VERSÃO DO NIXOS
  # ===========================================================================
  system.stateVersion = "26.05";
}
