{
  description = "Shared CLI tools and dotfiles for macOS and Linux";

  inputs = {
    # Use a matched release pair. 25.11 also supports Intel Macs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aster = {
      url = "github:yawnbo/aster/a434655398ed38239c2442729247eb353aa89f3b";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lorri = {
      # Native hooks plus Kovari's atomic-save and virtual-source watcher fixes.
      url = "github:kovari-industries/lorri/9c013fd89ac63c1fd9d2dbf8ff189324c8da42aa";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tpm-src = {
      url = "github:tmux-plugins/tpm";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, aster, lorri, tpm-src, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in {
      packages = forAllSystems (system: {
        aster = aster.packages.${system}.aster;
        lorri = lorri.packages.${system}.default;
        home-manager = home-manager.packages.${system}.home-manager;
      });

      homeConfigurations = builtins.listToAttrs (map (system: {
        name = "yawnbo-${system}";
        value = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = {
            aster = aster.packages.${system}.aster;
            lorri = lorri.packages.${system}.default;
            inherit tpm-src;
          };
          modules = [
            ./home/default.nix
            {
              home.username = "yawnbo";
              home.homeDirectory =
                if nixpkgs.lib.hasSuffix "-darwin" system
                then "/Users/yawnbo"
                else "/home/yawnbo";
            }
          ];
        };
      }) systems);
    };
}
