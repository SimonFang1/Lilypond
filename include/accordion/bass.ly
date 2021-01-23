
\include "manipulation.ly"
\include "accordion/limits.ly"

MakeBass =
#(define-music-function
    (parser location rootPart chordPart)
    (ly:music? ly:music?)
  #{
    \new Voice {
      <<
      \tag #'layout {\UpsideRange{\extractNote #1 $chordPart }}
      \tag #'midi {\UpsideRange $chordPart }
      {\DownsideRange $rootPart }
      \tag #'(layout markchord) {
        \new ChordNames {
          \set chordChanges = ##t
          $chordPart
        }
      }
      \tag #'(layout markchord) {
        \new ChordNames {
          \set chordChanges = ##t
          $rootPart
        }
      }
      >>
    }
  #})

