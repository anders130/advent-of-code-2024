{pkgs ? import ../locked.nix}: let
    lib = pkgs.lib;

    inherit (builtins) filter length genList elemAt map head tail groupBy attrValues readFile all elem;
    inherit (lib.strings) trim splitString toInt;
    inherit (lib.lists) imap0 last flatten take;
    inherit (lib) filterAttrs;

    isCorrectOrder = rules: list: let
        first = head list;
        rest = tail list;
    in
        rules
        |> lib.debug.traceSeq { inherit first rest; }
        |> filter (rule: elemAt rule 0 == first)
        |> map (rule: elemAt rule 1)
        |> (ruleItems: rest
            |> all (item: elem item ruleItems)
        )
    ;

    part0 = text: text
        |> trim
        |> splitString "\n\n"
        |> (input: let
            rules = head input
                |> splitString "\n"
                |> map (splitString "|")
            ;
            # pageNumbers = last input
            pageNumbers = "47,75,61\n75,47,13\n13,53"
                |> splitString "\n"
                |> map (splitString ",")
            ;
        in
            # { inherit rules pageNumbers; }
            pageNumbers
            # |> tail
            # |> take 1
            |> map (isCorrectOrder rules)
        )
    ;

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
