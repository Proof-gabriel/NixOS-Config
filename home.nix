{ config, pkgs, ... }:

{
  # ===========================================================================
  # 1. INFORMAÇÕES BÁSICAS
  # ===========================================================================
  home.username = "Gabriel";
  home.homeDirectory = "/home/Gabriel";
  home.stateVersion = "26.05"; 

  # ===========================================================================
  # 2. PACOTES GLOBAIS DO USUÁRIO
  # ===========================================================================
  home.packages = with pkgs; [
    texlive.combined.scheme-full 
    texlab
    zathura
    zed-editor
    nixd            
    nixfmt

    protonvpn-gui
    proton-vpn-cli                
  ];

  # ===========================================================================
  # 3. CONFIGURAÇÃO DE PROGRAMAS (DOTFILES)
  # ===========================================================================
  programs = {
    
    # --- Shell Principal (Fish) ---
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

    # --- Starship (Tema Tokyo Night Convertido para Nix) ---
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    # --- Yazi (Gerenciador de Arquivos) ---
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

    # --- Automação de Ambientes Virtuais ---
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # --- Editor de Texto ---
    helix = {
      enable = true;
      defaultEditor = true;
    };

    # --- Controle de Versão (Git) ---
    git = {
      enable = true;
      
      # Identificação Básica
      userName = "Proof-gabriel";
      userEmail = "Proof_gabriel@proton.me";

      # Atalhos e Comportamentos Extras
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

    # --- Reprodutor de Mídia ---
    mpv = {
      enable = true;
      config = {
        keep-open = "yes";
      };
    };
    
  }; # <-- Fim do bloco principal "programs"

  # ===========================================================================
  # 4. ARQUIVOS DE CONFIGURAÇÃO (XDG / PLUGINS)
  # ===========================================================================
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

    home.sessionVariables = { };
}
