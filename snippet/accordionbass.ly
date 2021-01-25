\version "2.18.2"

\header {
  title = ""
  % subtitle = \markup {"Prelude to Act 1 for " \italic "Carmen"}
  composer = ""
  % opus = "Op. 9"  % 作品号
  % enteredby = ""
}

% Page configurations
% \pointAndClickOff 

% built-in include files
\include "articulate.ly" % for decoration pitches

% user defined include files
% complie argument -I {{path}} or --include={{path}}
\include "accordion/bass.ly"


SampleMelody = \relative c'' {
  g8 a g e  f g f d | c4 e8 g c2
}

rootnotes = {
  g8 s s s f s^"m" s s |
  c s s s c2
}

chordnotes = \chordmode {
  s8 c q q  s d:m q q |
  s  c q q  c2
}


SampleAccompany = \MakeBass \rootnotes \chordnotes

music = \new GrandStaff <<
  \new Staff \relative c' {
    \set Staff.midiInstrument = # "accordion"
    \clef treble
    \key c \major
    \time 4/4
    \tempo 4=72
    % \partial 4
    \SampleMelody
    \bar "|."
  }
  \new Staff {
    \set Staff.midiInstrument = # "accordion"
    \clef bass
    \key c \major
    \time 4/4
    % \partial 4
    \SampleAccompany
    \bar "|."
  } 
>>

\score {
  \keepWithTag #'(layout chordname chordroot) \music
  \layout{}
}

\score {
  \articulate
  \unfoldRepeats
  \keepWithTag #'midi \music
  \midi {}
}
