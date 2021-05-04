{ openssh }:

(openssh.overrideAttrs
  (old: rec { patches = old.patches ++ [ ./override_term.patch ]; }))
