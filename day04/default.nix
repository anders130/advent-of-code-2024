{pkgs ? import ../locked.nix}: let
    lib = pkgs.lib;

    inherit (builtins) filter length genList elemAt map head tail groupBy attrValues readFile;
    inherit (lib.strings) trim splitString;
    inherit (lib.lists) imap0 last flatten;
    inherit (lib) filterAttrs;

    toMatrix = text: text
        |> trim
        |> splitString "\n"
        |> map (row: row
            |> splitString ""
            |> filter (char: char != "")
        );

    getChar = x: y: matrix: matrix
        |> (mat: elemAt mat y)
        |> (row: elemAt row x);

    addCoords = c1: c2: [
        (head c1 + head c2)
        (last c1 + last c2)
    ];

    validCoords = mat: coords: let
        x = head coords;
        y = last coords;
        lenX = length (elemAt mat 0);
        lenY = length mat;
    in
        x >= 0 && x < lenX && y >= 0 && y < lenY;

    cardinalDirs = [[1 0] [1 1] [0 1] [(-1) 1] [(-1) 0] [(-1) (-1)] [0 (-1)] [1 (-1)]];
    diagonalDirs = [[1 1] [(-1) 1] [(-1) (-1)] [1 (-1)]];

    dirList = genList (i: elemAt cardinalDirs i) 8;
    diagDirList = genList (i: elemAt diagonalDirs i) 4;

    check = coords: mat: dir: sequence: let
        recurse = c: dir: sequence:
            if !(validCoords mat c) then false
            else let
                char = getChar (head c) (last c) mat;
                restSeq = tail sequence;
                success = char == (head sequence);
                nextCoords = addCoords c dir;
            in
                if success then
                    if restSeq == [] then true
                    else recurse nextCoords dir restSeq
                else false;
    in
        recurse coords dir sequence;

    checkMatrix = checkFunc: mat:
        imap0 (y: row:
            imap0 (x: _:
                checkFunc [x y] mat
            ) row
        ) mat;

    part0 = text: text
        |> toMatrix
        |> checkMatrix (c: mat: map (dir: check c mat dir ["X" "M" "A" "S"]) dirList)
        |> flatten
        |> filter (x: x)
        |> length;

    part1 = text: text
        |> toMatrix
        |> checkMatrix (c: mat: diagDirList
            |> map (dir: {
                inherit c dir;
                found = check c mat dir ["M" "A" "S"];
            })
            |> filter (x: x.found)
        )
        |> flatten
        |> groupBy (x: let
            middle = addCoords x.c x.dir;
        in toString middle)
        |> filterAttrs (_: items: length items > 1)
        |> attrValues
        |> length;

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
