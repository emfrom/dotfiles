;;
;; My initial config for schemesh
;;

;;
;; Git support functions
;;
(define *prompt-last-dir* #f)
(define *prompt-git-branch* "")

;; Load branch name

(define (prompt-refresh-git!)
  (guard (e (else (set! *prompt-git-branch* "")))
    ;; symbolic-ref: empty when not in repo, and avoids "HEAD" in detached state
    (let ((b (sh-run/string-rtrim-newlines
              {git symbolic-ref --quiet --short HEAD 2>/dev/null})))
      (set! *prompt-git-branch*
            (if (and b (not (string=? b "")))
                b
                "")))))


;; Check if refresh is needed
(define (prompt-maybe-refresh!)
  (let ((dir (charspan->string (sh-cwd))))
    (unless (and *prompt-last-dir*
                 (string=? dir *prompt-last-dir*))
      (set! *prompt-last-dir* dir)
      (prompt-refresh-git!))))

;;
;; Prompt function 
;; 
(define (emf-prompt lctx)
  (let ((a (linectx-prompt-ansi-text lctx)))

    (ansi-text-clear! a)

    ;; ---- terminal title ----
    (string+ a "\x1b;]0;term: ")
    (string+ a (charspan->string (sh-cwd)))
    (string+ a "\x07;")

    ;; ---- time (yellow) ----
    (let* ((d (current-date))
	   (h (date-hour d))
	   (m (date-minute d)))
      (yellow+ a (format "~2,'0d:~2,'0d" h m)))

    ;; -- Sancho Rainbow --
    (string+ a " ")
    (red+ a "S")
    (yellow+ a "a")
    (green+ a "n")
    (cyan+ a "c")
    (blue+ a "h")
    (magenta+ a "o")
    (string+ a " ")
    
    ;; ---- cwd (yellow) ----
    (yellow a (charspan->string (sh-home->~ (sh-cwd))))

    (string+ a "\n")

    ;; ---- git branch (red) ----
    (prompt-maybe-refresh!)
    (unless (string=? *prompt-git-branch* "")
      (red+ a "(")
      (red+ a *prompt-git-branch*)
      (red+ a ")")
      )

    ;; ---- final symbol ----
    (string+ a "> ")

    (linectx-prompt-ansi-text-set! lctx a)))

(linectx-prompt-proc emf-prompt)


;;
;; TERM 
;;
(if (equal? (getenv "TERM") "st-256color")
    (putenv "TERM" "xterm-256color"))

