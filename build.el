(require 'org)
(require 'ox-publish)
(require 'ox-html)
(require 'ox)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)))

(defconst studio-root
  (file-name-directory load-file-name))

(defconst studio-public
  (expand-file-name "public/" studio-root))


(defun studio-site-banner (_info)
  "Return the shared site banner as HTML."
  "<header class=\"site-banner\"><a href=\"/index.html\">Serf Blood Studio</a></header>")

;; --------------------------------------------------
;; DEVLOG METADATA FILTER
;; --------------------------------------------------

(defun studio-insert-devlog-meta (output backend info)
  "Insert the author and date immediately after the HTML title."
  (if (and (eq backend 'html)
           (string-match "</h1>" output))
      (let* ((author (plist-get info :author))
             (date (plist-get info :date))
             (author (if author
                         (org-export-data author info)
                       ""))
             (date (if date
                       (org-export-data date info)
                     "")))
        (replace-match
         (concat
          "</h1>\n"
          "<p class=\"post-meta\">"
          author " · " date
          "</p>\n")
         t t output))
    output))


;; --------------------------------------------------
;; CUSTOM DEVLOG PUBLISHER
;; --------------------------------------------------

(defun studio-publish-devlog-to-html (plist filename pub-dir)
  "Publish devlog HTML with metadata beneath the title."
  (let ((org-export-filter-final-output-functions
         (cons #'studio-insert-devlog-meta
               org-export-filter-final-output-functions)))
    (org-html-publish-to-html plist filename pub-dir)))

;; --------------------------------------------------
;; PUBLISHING PROJECTS
;; --------------------------------------------------

(setq org-publish-project-alist
      `(
        ;; Main site
        ("studio"
         :base-directory ,studio-root
         :base-extension "org"
         :exclude "devlog/.*"
         :publishing-directory ,studio-public
         :recursive nil
         :publishing-function org-html-publish-to-html

         :html-head "<link rel=\"stylesheet\" href=\"style.css\">"
         :html-head-include-default-style nil

         :with-author nil
         :with-creator nil
         :with-date nil
         :with-toc nil
         :section-numbers nil
         :html-preamble "<header class=\"site-banner\"><a href=\"/index.html\">Serf Blood Studio</a></header>"
         :html-postamble nil)

        ;; Devlog
        ("devlog"
	 :base-directory ,(expand-file-name "devlog/" studio-root)
	 :base-extension "org"
	 :publishing-directory ,(expand-file-name "devlog/" studio-public)
	 :recursive nil
	 :publishing-function studio-publish-devlog-to-html

	 :html-head "<link rel=\"stylesheet\" href=\"../style.css\">"
	 :html-head-include-default-style nil

	 :with-author t
	 :with-creator nil
	 :with-date t
	 :with-toc t
	 :section-numbers nil
	 :html-preamble "<header class=\"site-banner\"><a href=\"/index.html\">Serf Blood Studio</a></header>"
	 :html-postamble nil)

        ;; CSS
        ("css"
         :base-directory ,studio-root
         :base-extension "css"
         :publishing-directory ,studio-public
         :recursive nil
         :publishing-function org-publish-attachment)

        ;; Images, fonts, etc.
        ("assets"
         :base-directory ,(expand-file-name "assets/" studio-root)
         :base-extension "png\\|jpg\\|jpeg\\|gif\\|svg\\|webp\\|woff\\|woff2\\|ttf\\|otf"
         :publishing-directory ,(expand-file-name "assets/" studio-public)
         :recursive t
         :publishing-function org-publish-attachment)

        ;; Everything
        ("site"
         :components ("studio" "devlog" "css" "assets"))))


;; --------------------------------------------------
;; BUILD
;; --------------------------------------------------

(defun studio-publish ()
  "Build the complete studio website."
  (interactive)
  (org-publish-project "site" t)
  (message "SITE BUILT. THE BOMB CONTINUES TO FALL."))


(provide 'build)

;; ----------------------------------------------------------------------------------------------------

;; (require 'org)
;; (require 'ox-publish)

;; (org-babel-do-load-languages
;;  'org-babel-load-languages
;;  '((emacs-lisp . t)))


;; (defconst studio-root
;;   (file-name-directory load-file-name))

;; (defconst studio-public
;;   (expand-file-name "public/" studio-root))

;; (setq org-publish-project-alist
;;       `(

;;         ;; Main site
;;         ("studio"
;;          :base-directory ,studio-root
;;          :base-extension "org"
;;          :exclude "devlog/.*"
;;          :publishing-directory ,studio-public
;;          :recursive nil
;;          :publishing-function org-html-publish-to-html

;;          ;; Don't let Org generate its enormous default CSS.
;;          :html-head "<link rel=\"stylesheet\" href=\"style.css\">"
;;          :html-head-include-default-style nil

;;          ;; :with-author nil
;;          ;; :with-creator nil
;;          ;; :with-date nil
;;          ;; :with-toc nil
;;          ;; :section-numbers nil
;;          :html-preamble nil
;;          :html-postamble nil
;; 	 )

;;         ;; Devlog
;;         ("devlog"
;;          :base-directory ,(expand-file-name "devlog/" studio-root)
;;          :base-extension "org"
;;          :publishing-directory ,(expand-file-name "devlog/" studio-public)
;;          :recursive nil
;;          :publishing-function org-html-publish-to-html

;;          :html-head "<link rel=\"stylesheet\" href=\"../style.css\">"
;;          :html-head-include-default-style nil
;; 	 :html-preamble studio-devlog-preamble
	 
;;         :with-author t
;; 	:with-creator nil
;; 	:with-date t
;; 	:with-toc t
;; 	:section-numbers nil
;; 	:html-postamble nil
;; 	 )

;;         ;; CSS
;;         ("css"
;;          :base-directory ,studio-root
;;          :base-extension "css"
;;          :publishing-directory ,studio-public
;;          :recursive nil
;;          :publishing-function org-publish-attachment)

;;         ;; Images, fonts, etc.
;;         ("assets"
;;          :base-directory ,(expand-file-name "assets/" studio-root)
;;          :base-extension "png\\|jpg\\|jpeg\\|gif\\|svg\\|webp\\|woff\\|woff2\\|ttf\\|otf"
;;          :publishing-directory ,(expand-file-name "assets/" studio-public)
;;          :recursive t
;;          :publishing-function org-publish-attachment)

;;         ;; Everything
;;         ("site"
;;          :components ("studio" "devlog" "css" "assets"))))


;; ;; --------------------------------------------------
;; ;; the html preamble for devlog section
;; ;; (defun studio-devlog-preamble (info)
;; ;;   "Render author and date beneath the devlog title."
;; ;;   (let ((author (org-export-data (plist-get info :author) info))
;; ;;         (date (org-export-data (plist-get info :date) info)))
;; ;;     (format "<p class=\"post-meta\">%s · %s</p>"
;; ;;             author
;; ;;             date)))


;; (defun studio-publish ()
;;   "Build the complete studio website."
;;   (interactive)
;;   (org-publish-project "site" t)
;;   (message "SITE BUILT. THE BOMB CONTINUES TO FALL."))



;; (provide 'build)
