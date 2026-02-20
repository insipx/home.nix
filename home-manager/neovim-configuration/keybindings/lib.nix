let
  toUpper = builtins.replaceStrings
    [ "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m"
      "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z" ]
    [ "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
      "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" ];

  capitalize = s:
    let len = builtins.stringLength s;
    in if len == 0 then ""
       else toUpper (builtins.substring 0 1 s)
            + builtins.substring 1 (len - 1) s;

  hyphenToCamel = str:
    let
      parts = builtins.filter builtins.isString (builtins.split "-" str);
    in
      if builtins.length parts <= 1 then str
      else builtins.head parts
           + builtins.concatStringsSep "" (map capitalize (builtins.tail parts));

  stripNixExt = name:
    builtins.substring 0 (builtins.stringLength name - 4) name;

  shouldInclude = name: type:
    builtins.match "\\..*" name == null
    && name != "default.nix"
    && name != "lib.nix"
    && (type == "directory"
        || (type == "regular" && builtins.match ".*\\.nix" name != null));

  attrName = name: type:
    hyphenToCamel (if type == "directory" then name else stripNixExt name);

  extractAll = v: if builtins.isAttrs v then v.all else v;

in {
  autoDiscover = dir:
    let
      entries = builtins.readDir dir;
      names = builtins.filter
        (n: shouldInclude n entries.${n})
        (builtins.attrNames entries);

      namedAttrs = builtins.listToAttrs (map (n: {
        name = attrName n entries.${n};
        value = import (dir + "/${n}");
      }) names);

      all = builtins.concatLists (
        map (k: extractAll namedAttrs.${k})
          (builtins.attrNames namedAttrs)
      );
    in
      namedAttrs // { inherit all; };
}
