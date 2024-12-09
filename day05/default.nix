{pkgs ? import ../locked.nix}: let
    lib = pkgs.lib;

    inherit (builtins) filter length genList elemAt map head tail groupBy attrValues readFile all elem foldl';
    inherit (lib.strings) trim splitString toInt;
    inherit (lib.lists) imap0 last flatten take zipListsWith sublist;
    inherit (lib) filterAttrs;

    isCorrectOrder = rules: list: let
        recurse = rules: list: let
            first = head list;
            rest = tail list;

            firstIsCorrect = rules
                |> filter (rule: elemAt rule 0 == first)
                |> map (rule: elemAt rule 1)
                |> (ruleItems: rest
                    |> all (item: elem item ruleItems)
                );
        in
            if rest == [] then firstIsCorrect
            else if firstIsCorrect then recurse rules rest
            else false
        ;
    in
        recurse rules list
    ;

    getMiddle = list: let
        len = length list - 1;
        middle = len / 2;
    in list
        |> (l: elemAt l middle)
    ;

    part0 = text: text
        |> trim
        |> splitString "\n\n"
        |> (input: let
            rules = head input
                |> splitString "\n"
                |> map (splitString "|")
            ;
            pageNumbers = last input
                |> splitString "\n"
                |> map (splitString ",")
            ;
        in
            pageNumbers
            |> map (isCorrectOrder rules)
            |> zipListsWith (list: correct: {inherit list correct;}) pageNumbers
            |> filter (x: x.correct)
            |> map (x: x.list)
            # |> (l: lib.debug.traceSeq {inherit l;} l)
            |> map getMiddle
            |> map toInt
            |> foldl' (a: b: a + b) 0
        )
    ;

    part1 = text: "TODO P2";

    solve = filePath: let
        text = readFile filePath;
    in {
        "0" = part0 text;
        "1" = part1 text;
    };
in {
    example = solve ./in.example;
    real = solve ./in;
}
