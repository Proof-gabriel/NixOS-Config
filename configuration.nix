{ config, pkgs, ... }:

{
  # ===========================================================================
  # 0.scrip
  # ==========================================================================
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
  ];

  # ===========================================================================
  # 2. RECURSOS DO NIX E FLAKES
  # ===========================================================================
  # Garante que o suporte a Flakes funcione nativamente em todo o sistema
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Permite a instalação de pacotes proprietários (não-livres)
  # nixpkgs.config.allowUnfree = true;

  # ===========================================================================
  # 3. BOOT E KERNEL
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Servidor de Áudio (Essencial para Wayland, Niri e Fones Bluetooth)
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
      # Atalhos do Eza (substituindo o ls)
      ls = "eza --icons=always --group-directories-first";
      ll = "eza -alF --icons=always --group-directories-first";
      la = "eza -a --icons=always --group-directories-first";
      lt = "eza --tree --level=2 --icons=always";
      
      # Outros utilitários
      cat = "bat";
      c = "clear";
      
      # Atalho direto para rebuild da máquina
      update = "sudo nixos-rebuild switch --flake /etc/nixos#nixos-btw"; 
    };
  };

  # ===========================================================================
  # 8. INTERFACE GRÁFICA (Niri + DankMaterialShell)
  # ===========================================================================
  programs.niri.enable = true;

  programs.dms-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
  };

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
  };

  # Suporte a configurações GTK/Dconf no Wayland
  programs.dconf.enable = true;

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
    NIXOS_OZONE_WL = "1"; # Força apps Electron (Brave, VS Code, etc) a rodarem nativos em Wayland
  };

  # ===========================================================================
  # 10. PACOTES GLOBAIS DO SISTEMA
  # ===========================================================================
  environment.systemPackages = with pkgs; [
    # Navegador, Terminal e editor
    brave
    ghostty
       
    # Ferramentas do Terminal (CLI)
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
    # Visualização de Mídia e Arquivos
    yazi
    imv

    # Dependências do Yazi (Capas/Miniaturas)
    ffmpegthumbnailer
    imagemagick
    poppler-utils
    gnome-epub-thumbnailer

    # Aparência e Sistema
    cups-pk-helper
    starship
    whitesur-icon-theme
    whitesur-cursors
  ];

  # ===========================================================================
  # 11. VERSÃO DO NIXOS
  # ===========================================================================
  system.stateVersion = "26.05";
}
