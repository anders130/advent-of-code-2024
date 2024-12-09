{pkgs ? import ../locked.nix}: let
    lib = pkgs.lib;

    inherit (builtins) filter length genList elemAt map head tail groupBy attrValues readFile all elem foldl' listToAttrs;
    inherit (lib.strings) trim splitString toInt;
    inherit (lib.lists) imap0 last flatten take zipListsWith sublist sort;
    inherit (lib) filterAttrs;

    isCorrect = rules: first: rest: rules
        |> filter (rule: elemAt rule 0 == first)
        |> map (rule: elemAt rule 1)
        |> (r: all (item: elem item r) rest)
    ;

    isCorrectOrder = rules: list: let
        recurse = rules: list: let
            first = head list;
            rest = tail list;

            firstIsCorrect = isCorrect rules first rest;
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

    mkEvaluatedList = useRules: text: text
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
            |> useRules rules
        );

    part0 = text: text
        |> mkEvaluatedList (rules: list: list)
        |> filter (x: x.correct)
        |> map (x: x.list)
        |> map getMiddle
        |> map toInt
        |> foldl' (a: b: a + b) 0
    ;

    sortByRules = rules: list: let
        recurse = rules: list: let
            firstIsCorrect = isCorrect rules (head list) (tail list);
            swap = indexA: indexB: list: list
                |> length
                |> genList (i:
                    if i == indexA then elemAt list indexB
                    else if i == indexB then elemAt list indexA
                    else elemAt list i
                );
        in
            lib.debug.traceSeq {inherit firstIsCorrect list;}
            (
            if firstIsCorrect then
                list
            else
                swap 0 1 list
        )
        ;
    in
        lib.debug.traceSeq {inherit list;} (
        recurse rules list
            )
    ;

    part1 = text: mkEvaluatedList
        (rules: list: list
            |> filter (x: !x.correct)
            |> map (x: x.list)
            |> take 1
            |> map (sortByRules rules)
            # |> map (map toInt)
            # |> map (sort (a: b: a > b))
            # |> map (isCorrectOrder rules)
        ) text
    ;

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
