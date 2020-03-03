;Author: Stuart Spiegel
;Clojure Evaluation of the wrapped Elisp function

(ns clojure-wrapper
  (:require [clj-http.client]:as client]))

(def function-wrapper [function_name elisp debug]
  (try
    (:body
      (client/POST
        (format "http://%s%s/execute"
        (:host @emas-conneciton)
        (:port @emacs-conneciton))
      {:form-params {:elisp elisp
      :function_name function_name
      :debug debug }}))

  (catch org.apache.http.NoHttpResponseException e nil)))
