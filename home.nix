{ config, pkgs, inputs, ... }:

{
  # ===========================================================================
  # 0. IMPORTS
  # ===========================================================================
  imports = [
    inputs.helium.homeModules.helium
  ];

  # ===========================================================================
  # 1. INFORMAÇÕES BÁSICAS
  # ===========================================================================
  home.username = "Gabriel";
  home.homeDirectory = "/home/Gabriel";
  home.stateVersion = "26.05"; 

  # ===========================================================================
  # 2. PACOTES DO USUÁRIO
  # ===========================================================================
  home.packages = with pkgs; [
    brave
    ghostty
    zed-editor
    zathura
    proton-vpn

    wl-clipboard     
    grim             
    slurp            

    texlive.combined.scheme-full 
    texlab
    nixd      
    nixfmt

    imv
    ffmpegthumbnailer
    imagemagick
    poppler-utils
    gnome-epub-thumbnailer

    whitesur-icon-theme
    whitesur-cursors
  ];

  # ===========================================================================
  # 3. CONFIGURAÇÃO DE PROGRAMAS (DOTFILES)
  # ===========================================================================
  programs = {
    
    # --- HELIUM BROWSER ---
    helium = {
      enable = true;
      defaultBrowser = true;
      extraFlags = [
        "--ozone-platform-hint=auto"
        "--enable-features=WaylandWindowDecorations"
        "--enable-wayland-ime"
      ];
      preferences = {
        browser.show_home_button = false;
      };
    };

    fish = {
      enable = true;
      
      functions = {
        y = ''
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
          yazi $argv --cwd-file="$tmp"
          if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
          end
          rm -f -- "$tmp"
        '';
      };

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

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        plugin = {
          prepend_previewers = [
            { mime = "application/epub+zip"; run = "epub"; }
          ];
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    helix = {
      enable = true;
      defaultEditor = true;
    };

    git = {
      enable = true;
      
      userName = "Proof-gabriel";
      userEmail = "Proof_gabriel@proton.me";

      aliases = {
        st = "status";
        co = "checkout";
        br = "branch";
        cm = "commit -m";
        lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %s %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      };
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "hx";
      };
    };

    mpv = {
      enable = true;
      config = {
        keep-open = "yes";
      };
    };
    
  }; # <--- CHAVE RESTAURADA AQUI PARA FECHAR O BLOCO "programs = {"

  # ===========================================================================
  # 4. ARQUIVOS DE CONFIGURAÇÃO (XDG / PLUGINS)
  # ===========================================================================
  xdg.configFile."niri/config.kdl".source = ./modules/niri.kdl;
  xdg.configFile."starship.toml".source = ./starship.toml;

  xdg.configFile."yazi/plugins/epub.yazi/main.lua".text = ''
    local M = {}
    function M:peek(job)
      local cache = ya.file_cache(job)
      if not cache then return end
      if M:preload(job) == 1 then
        ya.image_show(cache, job.area)
        ya.preview_widget(job, {})
      end
    end
    function M:seek() end
    function M:preload(job)
      local cache = ya.file_cache(job)
      if not cache or fs.cha(cache) then return 1 end
      local size = math.min(rt.preview.max_width, rt.preview.max_height)
      local child, code = Command("epub-thumbnailer")
          :arg(tostring(job.file.url)):arg(tostring(cache)):arg(tostring(size)):spawn()
      if not child then
        child, code = Command("gnome-epub-thumbnailer")
            :arg(tostring(job.file.url)):arg(tostring(cache)):spawn()
        if not child then
          ya.err("spawn `gnome-epub-thumbnailer` command returns " .. tostring(code))
          return 0
        end
      end
      local status = child:wait()
      return status and status.success and 1 or 2
    end
    return M
  '';

  # ===========================================================================
  # 5. ORGANIZAÇÃO DE DADOS (SYMLINKS PARA O VAULT)
  # ===========================================================================
  home.file."Downloads".source = config.lib.file.mkOutOfStoreSymlink "/mnt/vault/Gabriel/Downloads";
  home.file."Documentos".source = config.lib.file.mkOutOfStoreSymlink "/mnt/vault/Gabriel/Documentos";
  home.file."Imagens".source = config.lib.file.mkOutOfStoreSymlink "/mnt/vault/Gabriel/Imagens";
  home.file."Vídeos".source = config.lib.file.mkOutOfStoreSymlink "/mnt/vault/Gabriel/Vídeos";
  home.file."Música".source = config.lib.file.mkOutOfStoreSymlink "/mnt/vault/Gabriel/Música";
  home.file."Estudos".source = config.lib.file.mkOutOfStoreSymlink "/mnt/vault/Gabriel/Estudos";

  # ===========================================================================
  # 6. VARIÁVEIS DE SESSÃO DO USUÁRIO
  # ===========================================================================
  home.sessionVariables = {
    XCURSOR_THEME = "WhiteSur-cursors";
    XCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
  };
}
