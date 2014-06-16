{:user
 {:plugins [[lein-ritz "0.7.0"]
            [lein-midje "3.0.0"]
            [lein-kibit "0.0.8"]
            [lein-try "0.3.0"]
            [lein-marginalia "0.7.1"]
            [cider/cider-nrepl "0.7.0-SNAPSHOT"]]
  :dependencies [[ritz/ritz-nrepl-middleware "0.7.0"]
                 [ritz/ritz-debugger "0.7.0"]
                 [ritz/ritz-repl-utils "0.7.0"]
                 [org.clojure/tools.namespace "0.2.4"]]
  :repl-options {:nrepl-middleware
                 [ritz.nrepl.middleware.javadoc/wrap-javadoc
                  ritz.nrepl.middleware.simple-complete/wrap-simple-complete]
                 :init (require '[clojure.tools.namespace.repl :refer [refresh]])}}
 :hooks
 [ritz.add-sources]}
