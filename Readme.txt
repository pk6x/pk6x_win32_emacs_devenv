This setup is 99.9% inspired by Casey Muratori who created the handmadehero series. 

w32_emacs_dev is a way to setup a C/C++ dev environment using Emacs as the code editor on Windows and your choice of C/C++ compiler toolkit (In this setup, it uses the MSVC compiler "cl") (it is also recommended to use other debugging tool alongside, e.g MSVC debugger).

Cmd or Command Prompt must be the shell you use here as MSVC toolkit, at least at the time of writing, make use of that shell only to run their tools. So be aware of using other shell environments like powershell for example. That wont run. 

Setting up the environment consist of couple of steps to follow. 

So, before starting, make sure (Microsoft Visual Studio) and (Emacs) are both installed on your Windows machine.

Now, to begin:






First, go to the Startup folder on Windows by typing "shell:startup" using "Run" and paste "subst_drive.bat) file there. This way, this .bat file will get invoked automatically when Windows booted.

The "subst_drive.bat" file what it does is just to tell Windows to create a new drive that is derived from your choice of physical drive that exists in your system. The substed drive in the setup took the initial "w:" but you can change it but you must also change wherever you see w: to the one you have chosen to be the substed drive. 

subst w: d:/dev 

Now, a new drive should appear on your Windows system in the Explorer.exe for example, or cd to it using "cmd".

-Windows
	|
	|__> Startup folder
		|
		|__> subst_drive.bat






Then, go to your project main dir into "misc" folder and paste "shell.bat" file in there. 

You can  create your project folder to have at least this structure: You don't have to as everything can be located wherever you like, just make sure you make the right changes in the locations used here. This structure is only a guide. 

-project main folder
	|
	|__> src (for example)
	|
	|__> includes (for example)
	|
	|__> misc
		|__> shell.bat

For example, your project folder could be structured simply this way:

-project main folder
	|
	|__> shell.bat

You can definitely name the misc folder to other name too, the only thing to be aware of is to make the corresponding changes as well wherever you see "misc" mentioned to your new naming.

shell.bat file job is first to run "vcvarsall.bat" (x64 in this setup, but you can choose x86 for 32-bit applications) so the local cmd shell you are running will have MSVC compiler up and running. Other cmd shells will not have that if you try to. Second job is to set a new value in the path variable to where this shell.bat is located. (set path=W:\project_dir\misc;%path% 






Then, paste a copy of Command Prompt on Desktop (you can rename this copy to whatever your like, here I named to "w32_emacs_dev")
 
-Windows
	|
	|__> Desktop
		|
		|__> Command Prompt shortcut (w32_emacs_dev)

Now go to Properties and set the both values of "Target" and "Start in" as shown in the picture.

The Target value is sat to (%windir%\system32\cmd.exe /k W:\project_dir\misc\shell.bat)

The /k flag is to just to tell Command Prompt to go to that location (W:\project_dir\misc\) and run that .bat file immediately (shell.bat in this setup)

The "Start in" value is sat to the desired drive of choice, in this case is sat to the substed drive "W:\" but that could be anything else.

This way, this local scoped environment of Command Prompt will start at that desired location, eg w:\ in this example

w:\ subst drive should already been sat from that .bat file that is (subst_drive.bat).






Then, paste the "build.bat" file into your project main folder or any other sub-folders (here I have located in a sub-folder "code")

-project main folder
	|
	|__> src (for example)
	|
	|__> includes (for example)
	|
	|__> code
		|__> build.bat

The build.bat file job is to compile/link your C/C++ code with your chosen options and flags.

Tips:
In this specific build.bat file is written this way:

@echo off
mkdir ..\build (This will create a new folder named "build")
pushd ..\build (This will mark the current dir to go back to after finishing whatever comes next)
cl ..\..\project_dir\code\main.cpp (compiling)
popd (Will return back to where the .cpp file is, the one was marked by pushd before)

The way Emacs know how to run the build.bat is how it was setup first in the init.el file. (Thanks to Casey Muratori and how he wrote it)

So Emacs now can not only know where to look for build.bat file but also can determine the underlying operating system to look for the file.

/* Emacs Casey's setup for C/C++ compilation

; Determine the underlying operating system
(setq casey-aquamacs (featurep 'aquamacs))
(setq casey-linux (featurep 'x))
(setq casey-win32 (not (or casey-aquamacs casey-linux)))

;; (setq casey-todo-file "w:/handmade/code/todo.txt")
;; (setq casey-log-file "w:/handmade/code/log.txt")

(setq compilation-directory-locked nil)

(when casey-win32 
  (setq casey-makescript "build.bat")
  (setq casey-font "outline-Liberation Mono")
)

(when casey-aquamacs 
  (cua-mode 0) 
  (osx-key-mode 0)
  (tabbar-mode 0)
  (setq mac-command-modifier 'meta)
  (setq x-select-enable-clipboard t)
  (setq aquamacs-save-options-on-quit 0)
  (setq special-display-regexps nil)
  (setq special-display-buffer-names nil)
  (define-key function-key-map [return] [13])
  (setq mac-command-key-is-meta t)
  (scroll-bar-mode nil)
  (setq mac-pass-command-to-system nil)
  (setq casey-makescript "./build.macosx")
)

(when casey-linux
  (setq casey-makescript "./build.linux")
  (display-battery-mode 1)
)

(load-library "view")
(require 'cc-mode)
(require 'ido)
(require 'compile)
(ido-mode t)

(setq compilation-context-lines 0)
(setq compilation-error-regexp-alist
    (cons '("^\\([0-9]+>\\)?\\(\\(?:[a-zA-Z]:\\)?[^:(\t\n]+\\)(\\([0-9]+\\)) : \\(?:fatal error\\|warnin\\(g\\)\\) C[0-9]+:" 2 3 nil (4))
     compilation-error-regexp-alist))

(defun find-project-directory-recursive ()
  "Recursively search for a makefile."
  (interactive)
  (if (file-exists-p casey-makescript) t
      (cd "../")
      (find-project-directory-recursive)))

(defun lock-compilation-directory ()
  "The compilation process should NOT hunt for a makefile"
  (interactive)
  (setq compilation-directory-locked t)
  (message "Compilation directory is locked."))

(defun unlock-compilation-directory ()
  "The compilation process SHOULD hunt for a makefile"
  (interactive)
  (setq compilation-directory-locked nil)
  (message "Compilation directory is roaming."))

(defun find-project-directory ()
  "Find the project directory."
  (interactive)
  (setq find-project-from-directory default-directory)
  (switch-to-buffer-other-window "*compilation*")
  (if compilation-directory-locked (cd last-compilation-directory)
  (cd find-project-from-directory)
  (find-project-directory-recursive)
  (setq last-compilation-directory default-directory)))

(defun make-without-asking ()
  "Make the current build."
  (interactive)
  (if (find-project-directory) (compile casey-makescript))
  (other-window 1))
(define-key global-map [f5] 'make-without-asking)

*/ 

The full version of Casey's Emacs C/C++ configuration code (includes styling and other mode handling) 

Copy and paste in the "init.el" located inside .emacs.d folder in Romaing in Appdata folder


;; //////////////////////////////// Start of "From Casey Muratori (C/C++ style and compilation)"
; Determine the underlying operating system
(setq casey-aquamacs (featurep 'aquamacs))
(setq casey-linux (featurep 'x))
(setq casey-win32 (not (or casey-aquamacs casey-linux)))

;; (setq casey-todo-file "w:/handmade/code/todo.txt")
;; (setq casey-log-file "w:/handmade/code/log.txt")

(setq compilation-directory-locked nil)

(when casey-win32 
  (setq casey-makescript "build.bat")
  (setq casey-font "outline-Liberation Mono")
)

(when casey-aquamacs 
  (cua-mode 0) 
  (osx-key-mode 0)
  (tabbar-mode 0)
  (setq mac-command-modifier 'meta)
  (setq x-select-enable-clipboard t)
  (setq aquamacs-save-options-on-quit 0)
  (setq special-display-regexps nil)
  (setq special-display-buffer-names nil)
  (define-key function-key-map [return] [13])
  (setq mac-command-key-is-meta t)
  (scroll-bar-mode nil)
  (setq mac-pass-command-to-system nil)
  (setq casey-makescript "./build.macosx")
)

(when casey-linux
  (setq casey-makescript "./build.linux")
  (display-battery-mode 1)
)

(load-library "view")
(require 'cc-mode)
(require 'ido)
(require 'compile)
(ido-mode t)

(defun casey-ediff-setup-windows (buffer-A buffer-B buffer-C control-buffer)
  (ediff-setup-windows-plain buffer-A buffer-B buffer-C control-buffer)
)
(setq ediff-window-setup-function 'casey-ediff-setup-windows)
(setq ediff-split-window-function 'split-window-horizontally)

;; C/C++ mode handling
;; Unique comments style
(setq fixme-modes '(c++-mode c-mode emacs-lisp-mode))
(make-face 'font-lock-fixme-face)
(make-face 'font-lock-note-face)
(mapc (lambda (mode)
  (font-lock-add-keywords
     mode
     '(("\\<\\(TODO\\)" 1 'font-lock-fixme-face t)
       ("\\<\\(NOTE\\)" 1 'font-lock-note-face t))))
      fixme-modes)
(modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
(modify-face 'font-lock-note-face "Dark Green" nil nil t nil t nil nil)

;; Accepted file extensions and their appropriate modes
(setq auto-mode-alist
(append
 '(("\\.cpp$"    . c++-mode)
   ("\\.hin$"    . c++-mode)
   ("\\.cin$"    . c++-mode)
   ("\\.inl$"    . c++-mode)
   ("\\.rdc$"    . c++-mode)
   ("\\.h$"    . c++-mode)
   ("\\.c$"   . c++-mode)
   ("\\.cc$"   . c++-mode)
   ("\\.c8$"   . c++-mode)
   ("\\.txt$" . indented-text-mode)
   ("\\.emacs$" . emacs-lisp-mode)
   ("\\.gen$" . gen-mode)
   ("\\.ms$" . fundamental-mode)
   ("\\.m$" . objc-mode)
   ("\\.mm$" . objc-mode)
   ) auto-mode-alist))

;; C++ indentation style
  (defconst c-default-style
  '((c-electric-pound-behavior   . nil)
    (c-tab-always-indent         . t)
    (c-comment-only-line-offset  . 0)
    (c-hanging-braces-alist      . ((class-open)
                                    (class-close)
                                    (defun-open)
                                    (defun-close)
                                    (inline-open)
                                    (inline-close)
                                    (brace-list-open)
                                    (brace-list-close)
                                    (brace-list-intro)
                                    (brace-list-entry)
                                    (block-open)
                                    (block-close)
                                    (substatement-open)
                                    (statement-case-open)
                                    (class-open)))
    (c-hanging-colons-alist      . ((inher-intro)
                                    (case-label)
                                    (label)
                                    (access-label)
                                    (access-key)
                                    (member-init-intro)))
    (c-cleanup-list              . (scope-operator
                                    list-close-comma
                                    defun-close-semi))
    (c-offsets-alist             . ((arglist-close         .  c-lineup-arglist)
                                    (label                 . -4)
                                    (access-label          . -4)
                                    (substatement-open     .  0)
				                            (statement-case-intro  .  4)
                                    (statement-block-intro .  c-lineup-for)
                                    (case-label            .  4)
                                    (block-open            .  4)
                                    (inline-open           .  0)
                                    (topmost-intro-cont    .  0)
                                    (knr-argdecl-intro     . -4)
                                    (brace-list-open       .  0)
                                    (brace-list-intro      .  4)))
      (c-echo-syntactic-information-p . t))
    "Big Fun C++ Style."
    )

(defun big-fun-c-hook ()
  ;; Set my style for the current buffer
  (c-add-style "BigFun" c-default-style t)

  ;; 4-space tabs
  (setq tab-width 4
        indent-tabs-mode nil)

  ;; Newline indents, semi-colon wont
  (setq c-hanging-semi&comma-criteria '((lambda () 'stop)))
  
  ;; Additional style stuff
  (c-set-offset 'member-init-intro '++)

  ;; No hungry backspace
  (c-toggle-auto-hungry-state -1)
  
  ;; Abbrevation expansion
  (abbrev-mode 1)

  ;; Format the given file as a header file
  (defun header-format ()
    (interactive)
    (setq BaseFileName (file-name-sans-extension (file-name-nondirectory buffer-file-name)))
    (insert "#if !defined(")
    (push-mark)
    (insert BaseFileName)
    (upcase-region (mark) (point))
    (pop-mark)
    (insert "_H)\n")
    (insert "/* ========================================================================\n")
    (insert "   $File: $\n")
    (insert "   $Date: $\n")
    (insert "   $Revision: $\n")
    (insert "   $Creator: OOOO $\n")
    (insert "   ======================================================================== */\n")
    (insert "\n")
    (insert "#define ")
    (push-mark)
    (insert BaseFileName)
    (upcase-region (mark) (point))
    (pop-mark)
    (insert "_H\n")
    (insert "#endif")
    )

  ;; Format the given file as a source file
  (defun source-format ()
    (interactive)
    (setq BaseFileName (file-name-sans-extension (file-name-nondirectory buffer-file-name)))
    (insert "/* ========================================================================\n")
    (insert "   $File: $\n")
    (insert "   $Date: $\n")
    (insert "   $Revision: $\n")
    (insert "   $Creator: OOOO $\n")
    (insert "   ======================================================================== */\n")
  )

  (cond ((file-exists-p buffer-file-name) t)
        ((string-match "[.]hin" buffer-file-name) (source-format))
        ((string-match "[.]cin" buffer-file-name) (source-format))
        ((string-match "[.]h" buffer-file-name) (header-format))
        ((string-match "[.]cpp" buffer-file-name) (source-format)))

  (defun find-corresponding-file ()
    "Find the file that corresponds to this one."
    (interactive)
    (setq CorrespondingFileName nil)
    (setq BaseFileName (file-name-sans-extension buffer-file-name))
    (if (string-match "\\.c" buffer-file-name)
       (setq CorrespondingFileName (concat BaseFileName ".h")))
    (if (string-match "\\.h" buffer-file-name)
       (if (file-exists-p (concat BaseFileName ".c")) (setq CorrespondingFileName (concat BaseFileName ".c"))
     (setq CorrespondingFileName (concat BaseFileName ".cpp"))))
    (if (string-match "\\.hin" buffer-file-name)
       (setq CorrespondingFileName (concat BaseFileName ".cin")))
    (if (string-match "\\.cin" buffer-file-name)
       (setq CorrespondingFileName (concat BaseFileName ".hin")))
    (if (string-match "\\.cpp" buffer-file-name)
       (setq CorrespondingFileName (concat BaseFileName ".h")))
    (if CorrespondingFileName (find-file CorrespondingFileName)
       (error "Unable to find a corresponding file")))
  (defun find-corresponding-file-other-window ()
    "Find the file that corresponds to this one."
    (interactive)
    (find-file-other-window buffer-file-name)
    (find-corresponding-file)
    (other-window -1))
  (define-key c++-mode-map "\e." 'find-corresponding-file)
  (define-key c++-mode-map "\e>" 'find-corresponding-file-other-window)
  (define-key c++-mode-map [C-tab] 'indent-region)
  (define-key c++-mode-map "\C-y" 'indent-for-tab-command)
  (define-key c++-mode-map "^[  " 'indent-region)

;; (add-to-list 'compilation-error-regexp-alist 'amgun-devenv)
 ;; (add-to-list 'compilation-error-regexp-alist-alist '(amgun-devenv
 ;; "*\\([0-9]+>\\)?\\(\\(?:[a-zA-Z]:\\)?[^:(\t\n]+\\)(\\([0-9]+\\)) :
 ;; \\(?:see declaration\\|\\(?:warnin\\(g\\)\\|[a-z ]+\\) C[0-9]+:\\)"
 ;; 2 3 nil (4)))
)

(add-hook 'c-mode-common-hook 'big-fun-c-hook)

;; add en dash word "hyphenated compound word" as word constituents in the syntax table
(add-hook 'c++-mode-hook 'superword-mode)
(add-hook 'c++-mode-hook (lambda () (modify-syntax-entry ?- "w")))

;; set "gnu" style indenting for c
  ;; (setq c-default-style "Linux"
  ;; c-basic-offset 4)

;; C/C++ compilation
(setq compilation-context-lines 0)
(setq compilation-error-regexp-alist
    (cons '("^\\([0-9]+>\\)?\\(\\(?:[a-zA-Z]:\\)?[^:(\t\n]+\\)(\\([0-9]+\\)) : \\(?:fatal error\\|warnin\\(g\\)\\) C[0-9]+:" 2 3 nil (4))
     compilation-error-regexp-alist))

(defun find-project-directory-recursive ()
  "Recursively search for a makefile."
  (interactive)
  (if (file-exists-p casey-makescript) t
      (cd "../")
      (find-project-directory-recursive)))

(defun lock-compilation-directory ()
  "The compilation process should NOT hunt for a makefile"
  (interactive)
  (setq compilation-directory-locked t)
  (message "Compilation directory is locked."))

(defun unlock-compilation-directory ()
  "The compilation process SHOULD hunt for a makefile"
  (interactive)
  (setq compilation-directory-locked nil)
  (message "Compilation directory is roaming."))

(defun find-project-directory ()
  "Find the project directory."
  (interactive)
  (setq find-project-from-directory default-directory)
  (switch-to-buffer-other-window "*compilation*")
  (if compilation-directory-locked (cd last-compilation-directory)
  (cd find-project-from-directory)
  (find-project-directory-recursive)
  (setq last-compilation-directory default-directory)))

(defun make-without-asking ()
  "Make the current build."
  (interactive)
  (if (find-project-directory) (compile casey-makescript))
  (other-window 1))
(define-key global-map [f5] 'make-without-asking)

; Commands
(set-variable 'grep-command "grep -irHn ")
(when casey-win32
    (set-variable 'grep-command "findstr -s -n -i -l "))
;; //////////////////////////////// End of "From Casey Muratori (C/C++ style and compilation)"

