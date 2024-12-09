{pkgs ? import ../locked.nix}: let
    lib = pkgs.lib;

    inherit (builtins) filter length genList elemAt map head tail readFile all elem foldl';
    inherit (lib.strings) trim splitString toInt;
    inherit (lib.lists) last flatten take zipListsWith;

    isCorrect = rules: first: rest: rules
        |> filter (rule: elemAt rule 0 == first)
        |> map (rule: elemAt rule 1)
        |> (r: all (item: elem item r) rest);

    isCorrectOrder = rules: list: let
        recurse = rules: list: let
            first = head list;
            rest = tail list;
            firstIsCorrect = isCorrect rules first rest;
        in
            if rest == [] then firstIsCorrect
            else if firstIsCorrect then recurse rules rest
            else false;
    in
        recurse rules list;

    prepareInput = useRules: text: text
        |> trim
        |> splitString "\n\n"
        |> (input: let
            rules = head input
                |> splitString "\n"
                |> map (splitString "|");
            pageNumbers = last input
                |> splitString "\n"
                |> map (splitString ",");
        in
            pageNumbers
            |> map (isCorrectOrder rules)
            |> zipListsWith (list: correct: {inherit list correct;}) pageNumbers
            |> useRules rules
        );

    getMiddle = list: let
        len = length list - 1;
    in (l: elemAt l (len / 2)) list;

    part0 = text: text
        |> prepareInput (rules: list: list)
        |> filter (x: x.correct)
        |> map (x: x.list)
        |> map getMiddle
        |> map toInt
        |> foldl' (a: b: a + b) 0;

    swap = indexA: indexB: list: list
        |> length
        |> genList (i:
            if i == indexA then elemAt list indexB
            else if i == indexB then elemAt list indexA
            else elemAt list i
        );

    sortByRules = rules: list: let
        recurse = rules: list: let
            rest = tail list;
            first = head list;
            firstIsCorrect = isCorrect rules first rest;
        in
            if firstIsCorrect then
                if rest == [] then list # all were correct
                else [first] ++ recurse rules rest # first was correct, check the rest
            else
                genList (i: swap 0 i list) (length list) # swap first with every item
                |> filter (l: isCorrect rules (head l) (tail l)) # filter out incorrect lists
                |> take 1
                |> flatten
                |> recurse rules # check the rest
        ;
    in recurse rules list;

    part1 = text: prepareInput
        (rules: list: list
            |> filter (x: !x.correct)
            |> map (x: x.list)
            |> map (sortByRules rules)
            |> map getMiddle
            |> map toInt
            |> foldl' (a: b: a + b) 0
        ) text;

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
