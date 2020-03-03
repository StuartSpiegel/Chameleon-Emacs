;; Copyright (C) 2020 Stuart Spiegel <stuart.spiegel@gmail.com>
;; emacs-lisp (.el) --> Wrapped in Clojure (.clj)

;; Clojure Emacs Wrapper :
;; `clomacs-eval` - pass Elisp code as string to Emacs for eval.
;; `clomacs-defn` - core Elisp to Clojure function wrapper.

;; //////////////////////////////////////////////////////////

(ns clojure-wrapper
  (:require [clj-http.client]:as client]))

(def emacs-connection
  "Keep Emacs httpd server connection information (host and port)."
  (atom {}))

;clojure wrap : httpd start
(defn set-emacs-connection [host port]
  "Set Emacs httpd server conneciton info, pass the data Elisp"
(reset! emacs-connection {:host host :port port}))

(defn get-emacs-connection-check []
  "Check is the connection to the Clojure end has been establilshed"
  @emacs-connection)
;Close the httpd connection
(defn close-emacs-connection []
  "clear the emacs httpd server connction info"
  (reset! emacs-connection {}))

;Return evaluation result as a string
;if the connection hasnt been established or is empty
; --> return  <nil>
(defn clojure-eval [function_name elisp debug]
  "Send the E-Lisp String to eval it in Emacs"
(when (not (empty? @emacs-connection))
(try
  (:body
    (client/POST
      (format "http://%s%s/execute"
        (:host @emas-conneciton)
        (:port @emacs-conneciton))
      {:form-params {:elisp elisp
      :function_name function_name
      :debug debug }}))

  (catch org.apache.http.NoHttpResponseException e nil))))

  ;define the param-handler class in terms of passing the function with
  ;its paramteres
  (defmulti param-handler (fn [acc param] (class param)))

  ;define the paramter handler
  (defmethod param-handler java.lang.String [acc param]
    "Wrap Clojure string with quotes for concatenation."
    (.append acc "\"")
    (.append acc param)
    (.append acc "\""))

  ;Pass the Clojure Wrapped symbol as a elisp quoted symbol
  (defmethod param-handler clojure.lang.symbol [acc param]
    "Convert Clojure symbol to elisp quoted symbol."
    (.append acc "'")
    (.append acc param))

  ;Convert Clojure mapping to Elisp array of Params (alist).
  (defmethod param-handler java.util.Map [acc param]
    (.append acc "'(")
    (mapv (fn [[k v]]
      (.append acc "(")
      (param-handler acc k)
      (.append acc " . ")
      (param-handler acc v)
      (.append acc ")"))
      param)
    (.append acc ")"))

    (defmethod param-handler java.util.List [acc param]
      "Convert Clojure list or vector to Elisp list."
      (.append acc "'(")
      (mapv (fn [v] (param-handler acc v) (.append acc " ")) param)
      (.append acc ")"))

    (defmethod param-handler java.lang.Boolean [acc param]
      "Convert Clojure boolean to Elisp boolean."
      (.append acc (if param "t" "nil")))

    (defmethod param-handler nil [acc param]
      "Convert Clojure nil to Elisp nil."
      (.append acc "nil"))

    (defmethod param-handler :default [acc param]
      "Use .toString call for param in other cases."
      (.append acc param))

    ;define the macro for the clojure-wrapper
    (defmacro clojure-wrapper [cl-func-name &
                              el-function_name &
                              {:keys [doc result-handler debug]
                              :or {doc ""
                              result-handler identity debug false}}]
    ;Pass the variables of Elisp to clojure wrapped methods
    "Wrap 'el-function_name', evaluated on Emacs side by cl-function_name'.
    'result-handler' - function that is called with the result of Elisp function_name
    'debug' - function shows the string passed for evaluation in *Messages buffer"

    '(def ~cl-function_name [& params#]
      (~result-handler
        (clojure-wrapper-eval
          ~cl-function_name
          (format "(%s%s)"
            (str '~el-function_name)

            ;loop
            (loop [rest-params# params#
              acc# (new StringBuffer "")]
              (let [param# (first rest-params#)]
              (if (empty? rest-params#)
                (str acc#)
                (recur (next rest-params#)
                  (param-handler (.append acc# " ") param#))))))

                  ~debug)))

    ;format the result for
      (defn format-result
      [result]
      (str (param-handler (new StringBuffer "") result)))

    ;format the string to be sent from Clojure side to Elisp side as a String.
    (defn format-string
      "Format string created by Clojure side to Elisp structure as string."
      [result]
      (format-result (read-string result)))
