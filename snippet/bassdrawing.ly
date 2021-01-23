\version "2.18.2"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LSR workaround:
#(set! paper-alist (cons '("snippet" . (cons (* 160 mm) (* 155 mm))) paper-alist))
\paper {
  #(set-paper-size "snippet")
  tagline = ##f
}

\markup\vspace #.5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Drawing a standard Stradella Accordion Bass
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#(define (create-pitch-list by-pitch result count)
"@var{result}is supposed to be a list containing a single pitch. 
A list of pitches is returned.  Each pitch is transposed by @var{by-pitch} in 
relation to the previous transposed pitch.
This is done @var{count} times.
Finally each calculated pitches pitch-ocatave is set zero.
Example:
(create-pitch-list (ly:make-pitch 0 1 0) (list (ly:make-pitch 0 0 0)) 2)
-> 
'(#<Pitch c' > #<Pitch d' > #<Pitch e' >)"
  (if (zero? count)
      (map 
        (lambda (p)
          (ly:make-pitch
            0
            (ly:pitch-notename p)
            (ly:pitch-alteration p)))
        (reverse result))
      (create-pitch-list
        by-pitch
        (cons (ly:pitch-transpose (car result) by-pitch) result)
        (1- count))))

#(define cycle-of-fifths ;; define circle of fifths as pitchlist
  (create-pitch-list (ly:make-pitch 0 4 0) (list (ly:make-pitch 0 6 -1)) 19))

#(define counter-basses ;; define counter bass notes as pitchlist
  (create-pitch-list (ly:make-pitch 0 4 0) (list (ly:make-pitch 0 1 -1/2)) 19))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% pitch+music functions and definitions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#(define (pitch-equals? p1 p2)
  (and
    (= (ly:pitch-alteration p1) (ly:pitch-alteration p2))
    (= (ly:pitch-notename p1) (ly:pitch-notename p2))))

#(define (note-name->string pitch)
  (let* ((a (ly:pitch-alteration pitch))
         (n (ly:pitch-notename pitch)))
    (make-concat-markup
      (list
        (make-simple-markup
          (vector-ref #("C" "D" "E" "F" "G" "A" "B") n))
        (if (= a 0)
            (make-line-markup (list empty-markup))
            (make-line-markup
              (list
                (alteration->text-accidental-markup a)
                (make-hspace-markup 0.1))))))))
  
#(define (chord-superscript n)
  ;; get the superscript for row n
  ;; counter bass notes and root notes have no superscript
  (cond
   ((= n 2) "M")
   ((= n 3) "m")
   ((= n 4) "7")
   ((= n 5) "o")
   (else "")))
   
#(define (get-index p)
  ;; get the index of a pitch p in the circle of fifths
  ;; this number is needed to create the labels of the bass buttons
  (list-index (lambda (x) (pitch-equals? x p)) cycle-of-fifths))

#(define (chord-name->markup p n)
  ;; make the name from a chord with pitch p in row n
  ;; you get an error when the pitch is not in the circle of fifths
  (let* ((i (get-index p))
         (terz (note-name->string (list-ref counter-basses i)))
         (bas (note-name->string (list-ref cycle-of-fifths i)))
         ;; root name of the button
         (simple
          (if (= n 0) terz bas)))
    (make-concat-markup
     (list
      simple
      (make-smaller-markup
       (make-raise-markup 0.6 (make-simple-markup (chord-superscript n))))))))
  
#(define-markup-command (accordion-bass layout props i-col i-row)
   (index? index?)
  ;; draw a standard stradella accordion bass with 120 buttons
  ;; mark the button in column i-col and i-row in a different color
  ;; column 1: B doubleflat, col 10: C, col 20: A#
  ;; the rows: 1=diminished chord, 2=7th chord,
  ;;           3=minor chord, 4=major chord, 5=root note, 6=counter bass note
  
  #:properties ((font-size 0) (thickness 2.5) (offset 3.5)(circle-padding 0.2))
  (let* ((ref-mrkp (interpret-markup layout props
                ;; This markup should have the largest extension and will serve
                ;; as a reference to calculate the largest circle diameter 
                ;; needed for button labels, checking out the horizontal extent 
                ;; of B DOUBLEFLAT sup M
                #{ 
                  \markup 
                    \fontsize #font-size \concat { 
                      "B" 
                      \musicglyph #"accidentals.flatflat" 
                      \smaller \raise #0.6 "M" 
                  } 
                #}))
         (ref-mrkp-x-ext (ly:stencil-extent ref-mrkp X))
         ;; calculating padding from circle-padding
         (pad (* (magstep font-size) circle-padding 2))
         ;; adding pad to extent of widest button label
         ;; don't mess radius with diameter!
         (dm-circle (+ (/ (cdr ref-mrkp-x-ext) 2) pad)) 
         ;; distance between two buttons in a row
         (col-dist (+ (* 2 dm-circle) pad)) 
         ;; you can vary the distance between the button rows
         (row-y-dist 0.95) 
         ;; horizontal shifting of the botton rows
         (h-shift (+ dm-circle pad)) 
         (thick 
           (* (magstep font-size) 
              (ly:output-def-lookup layout 'line-thickness)))
         (my-circle (make-circle-stencil dm-circle thick #f))
         (default-marked-button-stencil-proc
           (lambda (val)
             (ly:stencil-add
              (ly:stencil-in-color 
                (make-circle-stencil dm-circle 0 #t)
                1 1 1)
              (make-circle-stencil 
                (- dm-circle (* 5 thick)) (* val thick) #f)))))
    (apply ly:stencil-add
      empty-stencil
      (map
       (lambda (z)
         (ly:stencil-translate
          (apply ly:stencil-add
            empty-stencil
            (map
             (lambda (x)
               (let* ((chord-name-mrkp 
                        (chord-name->markup (list-ref cycle-of-fifths x) z))
                      (init-m 
                        (interpret-markup layout props
                          (if (= z 0)
                              (make-override-markup 
                                `(thickness . ,(* 10 thick))
                                (make-underline-markup chord-name-mrkp))
                              chord-name-mrkp)))
                      (m
                        (ly:make-stencil
                          (ly:stencil-expr init-m)
                          (ly:stencil-extent init-m X)
                          (ly:stencil-extent 
                            ;; stencil of a simple ref-markup to get correct
                            ;; baseline for all chord-name-markups
                            (interpret-markup layout props "B") 
                            Y))))
                 (ly:stencil-translate-axis
                   (ly:stencil-add
                     ;; mark C-Button
                     (if (and (= 1 z)(= 9 x))
                         (default-marked-button-stencil-proc 5)
                         empty-stencil)
                     ;; mark Ab- and E-Buttons
                     (if (and (= 1 z)(or (= 5 x)(= 13 x)))
                         (default-marked-button-stencil-proc 2.5)
                         empty-stencil)
                     ;; mark Button in column i-col and row i-row
                     ;; (some calculation is done because we draw row 6 first
                     ;;and work our way upwards)
                     (if (and (= (- 6 i-row) z)(= (1- i-col) x))
                         (make-circle-stencil dm-circle 0.7 #f)
                         empty-stencil)
                     ;; this is our chord name as button label
                     ;; underlined if counter bass note
                     (centered-stencil m)
                     ;; this is the button
                     my-circle)
                   (* x col-dist) 
                   X)))
             ;; loop through all columns
             (iota 20 0)))
          ;; calculate horizontal and vertical shift relative to the leftmost 
          ;; button in the row with the diminished chords
          (cons (* z h-shift) (* z col-dist (- row-y-dist)))))
       ;; loop through all rows
       (iota 6)))))
  
\markup \column {
  \vspace #2
  "Draw a standard Accordion bass system using Markup-funcions of Lilypond."
  \line { "The Buttons A" \flat ", C and E are marked." }
  "It's possible to mark a specific button, entering its row and column number"
  "Example:"
  \line { 
    \underline "first number:" 
    "column (1=B" 
      \concat {
      \hspace #-0.5 \super \fontsize #1 \doubleflat 
      ", 20=A" 
    }
    \hspace #-0.5 \super \sharp 
    ")" 
  }
  \line { 
    \underline "second number:" 
    "row (1=diminished chord, 2=7th chord, " 
  }
  "   3=minor chord, 4=major chord, 5=root note, 6=counter bass note)"
  "If the parameters are outside this range no button is colored."
  "Change the scale factor to a number you like."
  \line { 
    "Usage:" 
    \bold " \markup \scale #'(0.75 . 0.75) \accordion-bass #4 #2" 
  }
  \vspace #1
}

\markup \scale #'(0.75 . 0.75) \accordion-bass #5 #1
