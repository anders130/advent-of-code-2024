{pkgs ? import ../locked.nix}: let
    lib = pkgs.lib;

    inherit (builtins) filter length genList elemAt sort lessThan map foldl';
    inherit (lib) mod strings lists;

    part0 = text: "TODO P1";

    part1 = text: "TODO P2";

    solve = filePath: let
        text = builtins.readFile filePath;
    in {
        "0" = part0 text;
        "1" = part1 text;
    };
in {
    example = solve ./in.example;
    real = solve ./in;
}
