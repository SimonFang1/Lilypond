%% http://lsr.di.unimi.it/LSR/Item?id=326
%% see also http://lilypond.org/doc/v2.18/Documentation/snippets/keyboards

\version "2.18.2"


% Treble clef with properties of bass clef
fakeTrebleClef = {
 \set Staff.clefGlyph = #"clefs.G"
 \set Staff.clefPosition = #-2
 \set Staff.middleCPosition = #6
}

% Bass clef with properties of treble clef
fakeBassClef = {
 \set Staff.clefGlyph = #"clefs.F"
 \set Staff.clefPosition = #2
 \set Staff.middleCPosition = #-6
}

% Similar to above, but lower and positioned after barline
fakeBassClefShift = {
 % Change default prefatory item order so that clef is printed after barline
 \override Score.BreakAlignment.break-align-orders =
                 #(make-vector 3 '(span-bar
                                   breathing-sign
                                   staff-bar
                                   clef 
                                   key
                                   time-signature))
 \set Staff.clefGlyph = #"clefs.F"
 \set Staff.clefPosition = #-8
 \set Staff.middleCPosition = #-6
}

\book { 
 \score {
  \new Staff \relative c {
   \clef bass \voiceTwo 
   c2^\markup { 1. Without tweaking clef properties, output is nonsensical } ~ 
   << {
    c |
   }
   \new Voice \relative c'' {
    \clef treble \voiceOne
    c8 c g' g |
   } >>
  }
  \layout{}
  \midi{}
 }
 \score {
  \new PianoStaff <<
  \new Staff \relative c' {
   \key es \major
   \override DynamicLineSpanner.padding = #2.5
   <bes es g>8\ppp^\markup { 2. Final bar of \italic "Gesegnet sei, durch den die Welt entstund..."
   from Wolf's \italic "Italienisches Liederbuch" } <bes es g>
   <bes es g>[ <bes es g>] ~ <bes es g>2\fermata \bar "||"
  }
  \new Staff \relative c \keepWithTag #'layout {
   \clef bass \key es \major
   r8. \stemDown <es es,>16 <es es,>4 ~
   << {
    \voiceTwo <es es,>2
   }
   \new Voice {
    % The faked clef and notes
    \voiceOne \tag #'layout { \fakeTrebleClef <g g'>\fermata }
    % The real notes for MIDI output
    \tag #'midi { <es'' es'> }
   } >> \bar "|."
  }
  >>
  \layout{}
  \midi{}
 }
 \score {
  \new PianoStaff <<
  \new Staff \relative c' {
   \time 3/8
   \set subdivideBeams = ##t
   \override TupletNumber.stencil = ##f
   \override TupletBracket.stencil = ##f
   \tieDotted
   << { \voiceOne
    \tuplet 3/2 {
     fis16(^\markup { 3. Bars 148 - 151 from Debussy's \italic "L'Isle joyeuse" }
     e d \repeat unfold 5 { c d e fis e d } c d e)
    }
   }
   \new Voice { \voiceTwo
    bes4. ~ |
    bes |
    bes ~ |
    bes |
   } >>
   
   << {
    \tuplet 3/2 {
     fis'16(^\markup { 4. As above, but with small clefs on pedal notes }
     e d \repeat unfold 5 { c d e fis e d } c d e)
    }
   }
   \new Voice { \voiceTwo
    bes4. ~ |
    bes |
    bes ~ |
    bes |
   } >>
  }
  \new Staff \relative c'' \keepWithTag #'layout {
   \time 3/8
   << { \voiceOne
    bes8\rest \clef treble as16( c as8)
    as16( c as8) as16( c)
    bes( d bes8. d16)
    bes8.( d16 bes8)
   }
   \new Voice { \voiceTwo
    \tag #'layout {
     \fakeBassClef
     a,4. ~ |
     a ~ |
     a ~ |
     a |
    }
    \tag #'midi {
     c,, ~ |
     c ~ |
     c ~ |
     c |
    }
   } >>
   % Make clefs visible for each bar, except at end of system
   \override Staff.Clef.break-visibility = #end-of-line-invisible
   << { \voiceOne
    bes'8\rest \clef treble as16( c as8)
    as16( c as8) as16( c)
    bes( d bes8. d16)
    bes8.( d16 bes8)
   }
   \new Voice { \voiceTwo
    \tag #'layout {
     \fakeBassClef
     a,4. ~ |
     % Shrink clef to small size
     \override Staff.Clef.font-size = #-5
     % We want to prevent clef size changing, otherwise first clef is smaller
     \override Staff.Clef.full-size-change = ##t
     % The faked bass clef, printed after the barline and next to the pedal note
     \fakeBassClefShift
     a ~ |
     % Because we have overridden break-visibility, the cautionary clef is also displayed here...
     a ~ |
      % ...and here
     a |
     % Return to default clef properties
     \revert Score.BreakAlignment.break-align-orders
     \revert Staff.Clef.font-size
     \revert Staff.Clef.full-size-change
    }
    \tag #'midi {
     c,, ~ |
     c ~ |
     c ~ |
     c |
    }
   } >>
  }
  >>
  \layout {
   \context { \Score
    \remove "Bar_number_engraver"
   }
  }
  \midi {}
 }
}
