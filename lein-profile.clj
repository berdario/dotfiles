{:user
 {:plugins [[lein-ritz "0.7.0"]
            [lein-midje "3.0.0"]
            [lein-kibit "0.0.8"]
            [lein-try "0.3.0"]
            [lein-marginalia "0.7.1"]]
  :dependencies [[ritz/ritz-nrepl-middleware "0.7.0"]
                 [ritz/ritz-debugger "0.7.0"]
                 [ritz/ritz-repl-utils "0.7.0"]]
  :repl-options {:nrepl-middleware
                 [ritz.nrepl.middleware.javadoc/wrap-javadoc
                  ritz.nrepl.middleware.simple-complete/wrap-simple-complete]}}
 :hooks
 [ritz.add-sources]}
