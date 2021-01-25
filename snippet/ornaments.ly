\version "2.18.2"

\include "articulate.ly"


articulations = \relative c'' {
  b4
  b \accent
  b \espressivo
  b \marcato
  b \portato
  b \staccatissimo
  b \staccato
  b \tenuto
}

ornaments = \relative c'' {
  b4
  b \prall
  b \mordent
  b \prallmordent
  b \turn
  b \upprall
  b \downprall
  b \upmordent
  b \downmordent
  b \lineprall
  b \prallprall
  b \pralldown
  b \prallup
  b \reverseturn
  b \trill
}

\book {
  \score {
    \articulations
    \header {
      piece = "original"
    }
    \layout{}
    % \midi{}
  }
  \score {
    \articulate
    \articulations
    \header {
      piece = "articulation effects"
    }
    \layout{}
    % \midi{}
  }
  \score {
    \ornaments
    \header {
      piece = "original"
    }
    \layout{}
    % \midi{}
  }
  \score {
    \articulate
    \ornaments
    \header {
      piece = "ornament effects"
    }
    \layout{}
    \midi{}
  }
}

