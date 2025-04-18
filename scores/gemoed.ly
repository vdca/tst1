
\version"2.18"

%{Command below to create a good quality png with transparent background%}
% lilypond --png -dpixmap-format=pngalpha -dresolution=1000 NLB073196_2.ly

% Custom commands
mBreak = { \bar "" \break }
bBreak = { \break }
x = {\once\override NoteHead #'style = #'cross }

%
customlyrics = {
  \override Lyrics.LyricText.font-shape = #'italic
  \small
}

annotations = {
  \override Lyrics.LyricText.font-family = #'typewriter
  \small
}

% Tagline appears at the footer
\header {
    tagline = ""
}

% Main data
\score {{
\key f \major
\relative g'
{

% \set Score.proportionalNotationDuration = #(ly:make-moment 1 16)
% \override Score.SpacingSpanner #'strict-note-spacing = ##t
% \autoBeamOff
% \override Staff.BarLine #'stencil = ##f
% \override Staff.TimeSignature #'transparent = ##t
% \override Staff.Stem #'transparent = ##t
% \override Lyrics . LyricText #'font-series = #'bold
% \override Lyrics . LyricText #'font-family = #'typewriter
\set melismaBusyProperties = #'()

\partial 2
\time 3/2
\tempo 4=120
\override Score.MetronomeMark #'transparent = ##t
\override Score.RehearsalMark #'break-visibility = #(vector #t #t #f)
f4 g a2 f4 e c2 d1 \mBreak
}

\addlyrics {
\annotations
\set stanza = #"p. contour"
"" "–" "+" "–" "–" "+" "+"
%{"" "" "" "" "" "+" ""%}
}

\addlyrics {
\set stanza = #"syllables"
\customlyrics
"die" "en" "heeft" "geen" "recht" "ge" -- "moed"
 }

\addlyrics {
\annotations
\set stanza = #"s. contour"
"" "=" "=" "=" "=" "–" "+"
%{"" "" "" "" "" "–" ""%}
}

}

\layout {
	indent = 0\cm
}

}

%#(set! paper-alist (cons '("wide" . (cons (* 18 cm) (* 4 cm))) paper-alist))

\paper {
	%#(set-paper-size "wide")
	paper-width = 10\cm
	paper-height = 5\cm
	left-margin = 0\cm
	right-margin = 0\cm

	myStaffSize = #20
	#(define fonts
	(make-pango-font-tree "Linux Libertine"
                          "Nimbus Sans"
                          "courier"
                           (/ myStaffSize 20)))
}

\layout {
    \context {
    \RemoveEmptyStaffContext
    \override VerticalAxisGroup #'remove-first = ##t
}}
