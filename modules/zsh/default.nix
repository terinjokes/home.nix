{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    history = {
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
    };
    shellAliases = { ls = "ls --color"; };
    initExtra = ''
      . ${./zinput}
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      PROMPT='%2~ » '
    '';
  };
}
