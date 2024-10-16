{
  description = "Python program to display media information and album art on waybar";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        app = pkgs.python3Packages.buildPythonApplication {
          pname = "waybar-mediaplayer";
          version = "1.0";
          src = ./.;
          nativeBuildInputs = [
            pkgs.gobject-introspection
            pkgs.wrapGAppsHook
          ];
          propagatedBuildInputs = with pkgs.python3Packages; [
            pkgs.playerctl
            pillow
            pycairo
            pygobject3
            syncedlyrics
          ];
          postPatch = ''
            substituteInPlace src/mediaplayer \
              --replace "fp = Path(sys.argv[0]).parent.resolve() / \"config.json\"" \
              "fp = Path(GLib.get_user_config_dir()) / \"waybar-mediaplayer.json\""
          '';
          preFixup = ''
            makeWrapperArgs+=(--prefix PATH : ${pkgs.lib.makeBinPath [
              pkgs.playerctl
            ]})
          '';
          meta.mainProgram = "mediaplayer";
        };
      in {
        packages = {
          waybar-mediaplayer = app;
          default = self.packages.${system}.waybar-mediaplayer;
        };
        devShells.default = {
        };
      }
    );
}
