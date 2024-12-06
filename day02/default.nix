{pkgs ? import ../locked.nix}: let
    lib = pkgs.lib;

    inherit (builtins) map head tail all;
    inherit (lib.strings) trim splitString toInt;
    inherit (lib.lists) zipListsWith last count;

    abs = x: if x < 0 then -x else x;

    isSafe = list: let
        allIncreasing = all (pair: head pair > last pair);
        allDecreasing = all (pair: head pair < last pair);
        pairs = zipListsWith (x: y: [x y]) list (tail list);
        inRange = all (pair: pair
            |> (p: abs (head p - last p))
            |> (x: x >= 1 && x <= 3)
        );
    in
        inRange pairs && (allIncreasing pairs || allDecreasing pairs);

    part0 = text: text
        |> trim
        |> splitString "\n"
        |> map (row: row
            |> splitString " "
            |> map toInt
        )
        |> count isSafe;

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
