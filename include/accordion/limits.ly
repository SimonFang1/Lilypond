

#(define (bounded-pitch low high pitch)
  (let ((o (ly:pitch-octave pitch))
        (n (ly:pitch-notename pitch))
        (a (ly:pitch-alteration pitch))
        (l (ly:pitch-steps low))
        (h (ly:pitch-steps high))
        (p (ly:pitch-steps pitch)))
    (if (ly:pitch<? pitch low)  (set! o (+ o (ceiling (/ (- l p) 7)))))
    (if (ly:pitch<? high pitch) (set! o (- o (ceiling (/ (- p h) 7)))))
    (ly:make-pitch o n a)))


#(define (bounded-music low high music)
  (let ((es (ly:music-property music 'elements))
        (e (ly:music-property music 'element))
        (p (ly:music-property music 'pitch)))
      (if (pair? es)
        (ly:music-set-property! music 'elements (map (lambda (x) (bounded-music low high x)) es)))
      (if (ly:music? e)
        (ly:music-set-property! music 'element (bounded-music low high e)))
      (if (ly:pitch? p)
        (begin
          (set! p (bounded-pitch low high p))
          (ly:music-set-property! music 'pitch p)))
      music))

UpsideRange =
#(define-music-function
    (parser location music)
    (ly:music?)
    (let ((e (ly:make-pitch -1 2 NATURAL))
          (d' (ly:make-pitch 0 1 NATURAL)))
        (bounded-music e d' music)))

DownsideRange =
#(define-music-function
    (parser location music)
    (ly:music?)
    (let ((e, (ly:make-pitch -2 2 NATURAL))
          (d (ly:make-pitch -1 1 NATURAL)))
        (bounded-music e, d music)))

