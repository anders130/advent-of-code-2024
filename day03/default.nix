{pkgs ? import ../locked.nix}: let
    lib = pkgs.lib;

    inherit (builtins) map foldl' readFile tail head;
    inherit (lib.strings) trim splitString toInt removePrefix removeSuffix;

    prepareInput = getInput: filePath:
        filePath
        |> getInput
        |> readFile
        |> trim
        |> splitString "\n";

    evalMulStr = str:
        str
        |> removePrefix "mul("
        |> removeSuffix ")"
        |> splitString ","
        |> map toInt
        |> foldl' (a: b: a * b) 1;

    callRg = filePath: pkgs.runCommandLocal "call-rg" {} ''
        ${pkgs.ripgrep}/bin/rg --only-matching --no-line-number "mul\((\d{1,3}),(\d{1,3})\)" ${filePath} > $out
    '';

    part0 = filePath:
        filePath
        |> prepareInput callRg
        |> map evalMulStr
        |> foldl' (a: b: a + b) 0;

    callRg2 = filePath: pkgs.runCommandLocal "call-rg" {} ''
        ${pkgs.ripgrep}/bin/rg --only-matching --no-line-number "(mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\))" ${filePath} > $out
    '';

    filterList = list: let
        recurse = {list, include, acc}: if list == [] then acc else
            let
                first = head list;
                rest = tail list;
            in
                if first == "do()" then recurse {
                    list = rest;
                    include = true;
                    inherit acc;
                }
                else if first == "don't()" then recurse {
                    list = rest;
                    include = false;
                    inherit acc;
                }
                else if include then recurse {
                    list = rest;
                    inherit include;
                    acc = acc ++ [first];
                }
                else recurse {
                    list = rest;
                    inherit include acc;
                };
    in
        recurse {list = list; include = true; acc = [];};

    part1 = filePath:
        filePath
        |> prepareInput callRg2
        |> filterList
        |> map evalMulStr
        |> foldl' (a: b: a + b) 0;

    solve = filePath: {
        "0" = part0 filePath;
        "1" = part1 filePath;
    };
in {
    example = solve ./in.example;
    real = solve ./in;
}
