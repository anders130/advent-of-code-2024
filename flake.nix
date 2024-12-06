{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = inputs:
        inputs.flake-utils.lib.eachDefaultSystem (
            system: let
                pkgs = import inputs.nixpkgs {inherit system;};
                initDay = pkgs.callPackage ./initDay.nix {};
                runDay = pkgs.callPackage ./runDay.nix {};
            in {
                devShells.default = pkgs.mkShell {
                    buildInputs = [
                        initDay
                        runDay
                        pkgs.just
                    ];
                };
            }
        );
}
