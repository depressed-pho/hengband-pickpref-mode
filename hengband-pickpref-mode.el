;;; hengband-pickpref-mode.el -- Major mode for editing Hengband pickpref files
;;;
;;; Version: 1.0
;;; License: CC0 1.0 Universal

;; Keywords
(eval-and-compile
  ;; The following keywords aren't covered here. These are handled
  ;; specially:
  ;; - more than N dice
  ;; - more bonus than N
  (defvar hengband-pickpref:keywords
    '("all" "collecting" "unaware" "unidentified" "identified" "*identified*"
      "dice boosted" "worthless" "artifact" "ego" "good" "nameless"
      "average" "rare" "common" "wanted" "unique monster's" "human"
      "unreadable" "first realm's" "second realm's" "first" "second"
      "third" "fourth" "items" "weapons" "armors" "missiles" "magical devices"
      "lights" "junks" "corpses or skeletons" "spellbooks" "favorite weapons"
      "hafted weapons" "shields" "bows" "rings" "amulets" "suits" "cloaks"
      "helms" "gloves" "boots")
    "pickpref keywords that appear in patterns")

  (defvar hengband-pickpref:operators
    '("EQU" "IOR" "AND" "NOT" "LEQ" "GEQ")
    "pickpref conditional operators")

  (defvar hengband-pickpref:variables
    '("$RACE" "$CLASS" "$PLAYER" "$REALM1" "$REALM2" "$LEVEL" "$MONEY")
    "pickpref conditional variables")

  (defvar hengband-pickpref:races
    '("Human" "Half-Elf" "Elf" "Hobbit" "Gnome" "Dwarf" "Half-Orc"
      "Half-Troll" "Amberite" "High-Elf" "Barbarian" "Half-Ogre"
      "Half-Giant" "Half-Titan" "Cyclops" "Yeek" "Klackon" "Kobold"
      "Nibelung" "Dark-Elf" "Draconian" "Mindflayer" "Imp" "Golem"
      "Skeleton" "Zombie" "Vampire" "Spectre" "Sprite" "Beastman" "Ent"
      "Archon" "Balrog" "Dunadan" "Shadow-Fairy" "Kutar" "Android")
    "pickpref player races")

  (defvar hengband-pickpref:classes
    '("Warrior" "Mage" "Priest" "Rogue" "Ranger" "Paladin"
      "Warrior-Mage" "Chaos-Warrior" "Monk" "Mindcrafter" "High-Mage"
      "Tourist" "Imitator" "BeastMaster" "Sorcerer" "Archer"
      "Magic-Eater" "Bard" "Red-Mage" "Samurai" "ForceTrainer"
      "Blue-Mage" "Cavalry" "Berserker" "Weaponsmith" "Mirror-Master"
      "Ninja" "Sniper")
    "pickpref player classes"))

;; Faces
(defvar hengband-pickpref:inscription-face 'hengband-pickpref:inscription-face)
(defface hengband-pickpref:inscription-face
  '((t :inherit font-lock-doc-face))
  "Face to use for inscriptions."
  :group 'hengband-pickpref)

(defvar hengband-pickpref:prefix-face 'hengband-pickpref:prefix-face)
(defface hengband-pickpref:prefix-face
  '((t :inherit font-lock-type-face))
  "Face to use for pattern prefixes."
  :group 'hengband-pickpref)

;; Syntax table
(defvar hengband-pickpref-mode-syntax-table
  (let ((tab (make-syntax-table)))
    (modify-syntax-entry ?# "<" tab)
    (modify-syntax-entry ?\n ">" tab)
    (modify-syntax-entry ?* "_" tab)
    (modify-syntax-entry ?\[ "(]" tab)
    (modify-syntax-entry ?\] ")[" tab)
    tab)
  "Syntax table for hengband-pickpref-mode")

;; Font lock
(eval-when-compile
  (defun hengband-pickpref:ppre (keywords)
    (format "\\<\\(%s\\)\\>" (regexp-opt keywords))))

(defvar hengband-pickpref:font-lock-keywords
  (list
   ;; Comments
   (cons "^#.*$" font-lock-comment-face)

   ;; Ordinary keywords
   (cons (eval-when-compile
           (hengband-pickpref:ppre (append hengband-pickpref:keywords
                                           hengband-pickpref:operators)))
         font-lock-keyword-face)

   ;; Special keywords
   (cons (eval-when-compile
           (rx (seq word-start
                    "more "
                    (or (seq "than " (1+ digit) " dice")
                        (seq "bonus than " (1+ digit)))
                    word-end)))
         font-lock-keyword-face)

   ;; Variables
   (cons (eval-when-compile
           (hengband-pickpref:ppre hengband-pickpref:variables))
         font-lock-variable-name-face)

   ;; String constants
   (cons (eval-when-compile
           (hengband-pickpref:ppre (append hengband-pickpref:races
                                           hengband-pickpref:classes)))
         font-lock-string-face)

   ;; Prefixes
   (cons (eval-when-compile
           (rx line-start
               (or (in "!~;(")
                   (seq (in "?AP%") ":"))))
         hengband-pickpref:prefix-face)

   ;; Patterns
   (cons ":" hengband-pickpref:prefix-face)

   ;; Inscriptions
   (cons "#" hengband-pickpref:prefix-face)
   (cons "#\\(.*\\)$" (list 1 hengband-pickpref:inscription-face)))
  "Highlighting expressions for Hengband PickPref mode")

;; fill-paragraph
(defun hengband-pickpref:fill-paragraph (&optional justify)
  "Like \\[fill-paragraph] but handle Hengband pickpref comments."
  (interactive "P")
  ;; fill-comment-paragraph does nothing and returns nil when we are
  ;; not in a comment. That's perfectly fine, as we can never fill
  ;; non-comments. Always return t to indicate a success.
  (fill-comment-paragraph justify)
  t)

;;;###autoload
(define-derived-mode hengband-pickpref-mode prog-mode "Hengband PickPref"
  "Major mode for editing Hengband pickpref files."
  (setq-local font-lock-defaults '(hengband-pickpref:font-lock-keywords))
  (setq-local font-lock-keywords-only t)
  (setq-local comment-start "#")
  (setq-local fill-paragraph-function 'hengband-pickpref:fill-paragraph))

(provide 'hengband-pickpref-mode)
