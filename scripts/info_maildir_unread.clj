(require '[babashka.process :refer [pipeline pb]])
(require '[babashka.fs :as fs])
(require '[clojure.string :as str])

(defn icon [code-point]
  (str "%{T4}" code-point "%{T-}"))

(defn remove-empty [x]
  (remove empty? x))

(let [mail-count (-> (pipeline (pb "mdirs -a" (fs/expand-home "~/Maildir"))
                               (pb "mlist -s"))
                     last :out slurp
                     str/split-lines
                     remove-empty
                     count)]
  (cond
    (> mail-count 0) (println (icon "\uf18a") (str mail-count))
    :else (println)))
