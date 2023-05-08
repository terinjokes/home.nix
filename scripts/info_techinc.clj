(require '[babashka.curl :as curl])

(defn format-color [color]
  (str "%{F" color "}"))
(defn format-underline [color]
  (str "%{u" color "}"))
(defn icon [code-point]
  (str "%{T4}" code-point "%{T-}"))

(let [state (:body (curl/get "https://techinc.nl/space/spacestate" {:headers ["User-Agent" "member/terinjokes"]}))]
  (cond (= state "closed") (println (format-color "#BF616A") (format-underline "#BF616A") "%{+u}" (icon "\ue335") "Closed" "%{-u}")
        (= state "open") (println (format-color "#A3BE8C") (format-underline "#A3Be8C") "%{+u}" (icon "\ue335") "Open" "%{-u}")))
