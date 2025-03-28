
\version"2.18"

% Command below to create a good quality png with transparent background
% lilypond --png -dpixmap-format=pngalpha -dresolution=1000 NLB073196_2.ly

% Custom commands
mBreak = { \bar "" \break }
bBreak = { \break }
x = {\once\override NoteHead #'style = #'cross }

customlyrics = {
  \override Lyrics.LyricText.font-shape = #'italic
  \small
}

% Tagline appears at the footer
\header {
    tagline = ""
}

% Main data
\score {{
\key g \major
\relative g'
{

\set Score.proportionalNotationDuration = #(ly:make-moment 1 16)
% \override Score.SpacingSpanner #'strict-note-spacing = ##t
% \autoBeamOff
% \override Staff.BarLine #'stencil = ##f
% \override Staff.TimeSignature #'transparent = ##t
% \override Staff.Stem #'transparent = ##t
% \override Lyrics . LyricText #'font-series = #'bold
% \override Lyrics . LyricText #'font-family = #'typewriter
\set melismaBusyProperties = #'()

\partial 16*4
\time 4/4
\tempo 4=120
\override Score.MetronomeMark #'transparent = ##t
\override Score.RehearsalMark #'break-visibility = #(vector #t #t #f)
g4	fis4	g	 c	b	b4	a \mBreak
}

\addlyrics {
"" "" "" "" "" "" ""
}

\addlyrics {
\customlyrics
"om haar"	bo --	ter	duur	"te	ver" --	ko --	pen
 }

\addlyrics {
\customlyrics
die	heeft	haar	toe --	ges --	pro --	ken
}

\addlyrics {
\customlyrics
wat moes -- "ten ze" nu "gaan be" -- gin -- nen
}

\addlyrics {
\customlyrics
om ze "aan haar" min -- "naar te" ge -- ven
}

\addlyrics {
\customlyrics
"om je"	bo --	ter	duur	"te	ver" --	ko --	pen
 }

}

\layout {
	indent = 0\cm
}

}

%#(set! paper-alist (cons '("wide" . (cons (* 18 cm) (* 4 cm))) paper-alist))

\paper {
	%#(set-paper-size "wide")
	paper-width = 12\cm
	paper-height = 8\cm
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
