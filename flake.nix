{
  description = "Configuração Global do NixOS - Gabriel";

  inputs = {
    # =======================================================================
    # 1. FONTES E REPOSITÓRIOS (Inputs)
    # =======================================================================
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    
    home-manager = { 
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Patch do SpotX para o Spotify sem anúncios
    spotx-nix = {
      url = "github:SpotX-Official/SpotX-Nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia-shell (branch cachix para binários pré-compilados)
    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
  };

  outputs = { self, nixpkgs, home-manager, spotx-nix, noctalia, ... } @ inputs: 
  let
    # =======================================================================
    # 2. VARIÁVEIS GLOBAIS DA MÁQUINA
    # =======================================================================
    system   = "x86_64-linux";
    hostName = "nixos-btw";
    userName = "Gabriel";
  in 
  {
    # =======================================================================
    # 3. CONSTRUÇÃO DO SISTEMA (Outputs)
    # =======================================================================
    nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {
      inherit system;

      # Passa todos os "inputs" para os módulos
      specialArgs = { inherit inputs; };

      modules = [
        # --- Overlays Globais (Ex: SpotX para Spotify) ---
        {
          nixpkgs.overlays = [ spotx-nix.overlays.default ];
        }

        # --- Configuração Base do Sistema ---
        ./configuration.nix
        
        # --- Configuração do Usuário (Home Manager) ---
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            
            # Importa o arquivo home.nix injetando a variável do usuário
            users.${userName} = import ./home.nix;
          };
        }
      ];
    };
  };
}
