{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    history = {
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
    };
    initExtra = ''
      . ${./zinput}
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      PROMPT='%2~ » '
    '';
  };
}
