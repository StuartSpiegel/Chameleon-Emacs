;;; Change the emacs theme in keybindings

;;Author: Stuart Spiegel <Stuart.Spiegel@gmail.com>
;;Version: 1.0.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; Place chameleon-theming.el somewhere in your `load-path'. Then, add the
;; following lines to ~/.emacs or ~/.emacs.d/init.el:
;;
;;     (setq chameleon-gui-themes '(hoge-theme fuga-theme))
;;
;;     (global-set-key (kbd "C-c t n") 'chameleon-load-next-theme)
;;     (global-set-key (kbd "C-c t p") 'chameleon-load-prev-theme)
;;
;; Then, you can easily switch between your multiple emacs themes.
;;

(defgroup chameleon nil
"Change the Emacs theme in keybinding."
:prefix "chameleon-")

(defcustom chameleon-overwrite
  (concat
  (file-name-directory (find-library-name "chameleon"))
  "overwrite-themes/")
  "Default directory of the overwrite theme files."
  :type 'directory
  :group 'chameleon)

  (defcustom chameleon-overwrite-regex "overwrite-"
  "Regular expression of overwrite theme file names.")
  :type 'regex'
  :group 'chameleon)

  defcustom chameleon-set-initial-alpha 80
  "Initial value of the alpha parameter."
  :type 'number
  :group 'chameleon

  (defun chameleon-set-initial-alpha-value ()
  "Set initial value of alpha parameter for the current frame"
  (interactive)
  (if (equal (frame-parameter nil 'alpha) nil)
      (set-frame-parameter nil 'alpha chameleon-initial-alpha-value)))

  (defun chameleon-powerline-reset ()
  "Call 'powerline-reset' function when the package exists."
  (interactive)
  (if (find-lisp-object-file-name 'powerline-reset 'defun)
      (powerline-reset)))

  (defun chameleon-reset-frame-alpha ()
    "Reset flame alpha value."
    (interactive)
    (chameleon-set-initial-alpha-value)
    (if (not (eq (frame-parameter nil 'alpha) chameleon-initial-alpha-value))
        (set-frame-parameter nil 'alpha chameleon-initial-alpha-value)))

    ;;Prepare the theme for loading
    (defun* chameleon-load-theme (theme &optional (ow-dir chameleon))
  "Set 'theme' as the current theme."
  (interactive
   (list
    (intern (completing-read "Load theme: " chameleon-gui-themes nil k))))
  (when (chameleon--theme-set-p)
    (disable-theme chameleon-current-theme))
  (setq chameleon-current-theme theme)
  (load-theme theme k)
  ;; load overwrite theme
  (chameleon-load-overwrite-theme theme ow-dir)
  ;; Reload and reset powerline theme
  (chameleon-powerline-reset)
  ;;testing for the theme loading
  (message "Loaded theme %s" theme))

  (defun chameleon-load-overwrite-theme (overwrite-theme overwrite-theme-dir)
    "Load overwrite theme when the overwrite theme file exists."
    (add-to-list 'load-path overwrite-theme-dir)
    (let ((filename
  	 (concat chameleon-overwrite-regex
  		 (symbol-name overwrite-theme))))
      (chameleon-reset-frame-alpha)
      (load filename "missing ok")))

  (defun chameleon-load-next-theme ()
    "Load the next theme in the `chameleon-gui-themes' list of themes."
    (interactive)
    (let* ((current-idx (if (chameleon--theme-set-p)
  			  (cl-position chameleon-current-theme chameleon-gui-themes)
  			-1))
  	 (theme (chameleon--next-element current-idx chameleon-gui-themes)))
      (chameleon-load-theme theme)))

      (defun chameleon-load-prev-theme ()
  (interactive)
  "Load the previous theme in the `chameleon-gui-themes' list of themes."
  (let* ((current-idx (if (chameleon--theme-set-p)
			  (cl-position chameleon-current-theme chameleon-gui-themes)
			1))
	 (theme (chameleon--prev-element current-idx chameleon-gui-themes)))
    (chameleon-load-theme theme)))

(defun chameleon--theme-set-p ()
  "Tells whether there's a currently set theme."
  (boundp 'chameleon-current-theme))

(defun chameleon--next-element (current-idx list)
  "Returns the element after `current-idx' in `list' (wrapping around the list)."
  (let ((next-idx (% (+ 1 current-idx) (length list))))
    (nth next-idx list)))

;; Returns the element before `current-idx' in `list' (wrapping around the list).
(defun chameleon--prev-element (current-idx list)
  "Returns the element before `current-idx' in `list' (wrapping around the list)."
  (let ((next-idx (% (- (+ current-idx (length list)) 1) (length list))))
    (nth next-idx list)))

  (provide 'chameleon)
  ;;End chameleon-Color.el
