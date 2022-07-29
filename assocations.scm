(assoc
 #:pattern "^https?://.*(cfdata.org|cfplat.com|cfops.it).*"
 #:program "firefox -P cloudflare %f")

(assoc
 #:pattern ".*"
 #:program "/run/current-system/sw/bin/xdg-open %f")
