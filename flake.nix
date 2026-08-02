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
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs: 
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

      # Passa todos os "inputs" para os módulos (muito útil para projetos futuros)
      specialArgs = { inherit inputs; };

      modules = [
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
