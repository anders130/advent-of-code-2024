{pkgs ? import ../locked.nix}: let
    lib = pkgs.lib;

    inherit (builtins) filter length genList elemAt sort lessThan map foldl';
    inherit (lib) mod strings lists;

    prepareInput = text: text
        |> strings.splitString "\n"
        |> filter (x: x != "")
        |> map (strings.splitString "   ")
        |> lists.flatten
        |> map strings.toInt;

    getSortedList = predicate: list:
        list
            |> length
            |> genList (x: x)
            |> filter predicate
            |> map (x: elemAt list x)
            |> sort lessThan;

    abs = x: if x < 0 then -x else x;

    getLeft = getSortedList (x: mod x 2 == 0);
    getRight = getSortedList (x: mod x 2 != 0);

    part0 = text: let
        input = prepareInput text;
        left = getLeft input;
        right = getRight input;
    in
        genList (x: x) (length left)
        |> map (x: abs (elemAt left x - elemAt right x))
        |> foldl' (x: y: x + y) 0;

    part1 = text: let
        input = prepareInput text;
        left = getLeft input;
        right = getRight input;
    in
        left
        |> map (x: x * (lib.lists.count (y: y == x) right))
        |> foldl' (x: y: x + y) 0;

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
