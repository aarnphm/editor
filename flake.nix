{
  description = "aarnphm's neovim config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    neovim-nightly-overlay,
  }: let
    systems = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system:
        f (import nixpkgs {
          inherit system;
          overlays = [neovim-nightly-overlay.overlays.default];
        }));
  in {
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          bashInteractive
          fd
          git
          lua-language-server
          neovim
          ripgrep
          selene
          shellcheck
          stylua
          yq-go
        ];
      };
    });

    checks = forAllSystems (pkgs: {
      default =
        pkgs.runCommand "nvim-config-checks" {
          nativeBuildInputs = with pkgs; [
            bash
            selene
            shellcheck
            stylua
          ];
          src = self;
        } ''
          cp -R "$src" source
          chmod -R u+w source
          cd source

          stylua --check .
          selene .
          bash -n scripts/update_markdown_frontmatter.sh
          shellcheck scripts/update_markdown_frontmatter.sh

          touch "$out"
        '';
    });

    apps = forAllSystems (_pkgs: {
      update-markdown-frontmatter = {
        type = "app";
        program = "${self}/scripts/update_markdown_frontmatter.sh";
      };
    });
  };
}
