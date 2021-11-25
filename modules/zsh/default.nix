{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    history = {
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
    };
    shellAliases = {
      ls = "ls --color";
      git = "git-branchless wrap";
    };
    initExtra = ''
      . ${./zinput}
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      PROMPT='%2~ » '
    '';
  };
}
