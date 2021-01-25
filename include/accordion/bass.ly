
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
      \tag #'layout {\DownsideRange $rootPart }
      \tag #'chordname {
        \new ChordNames {
          \set noChordSymbol = #(make-simple-markup "")
          \set chordChanges = ##t
          $chordPart
        }
      }
      \tag #'chordroot {
        \new ChordNames {
          \set noChordSymbol = #(make-simple-markup "")
          \set chordChanges = ##t
          $rootPart
        }
      }
      \tag #'midi {\transpose c c, \UpsideRange $chordPart }
      \tag #'midi {\transpose c c, \DownsideRange $rootPart }
      >>
    }
  #})

