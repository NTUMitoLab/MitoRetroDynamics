using TikzPictures
using LaTeXStrings
a = 10 

b = L"""
\draw (0,0) -- (10,10);
\draw (%$a,0) -- (0,10);
\node at (5,5) {tikz $\sqrt{\pi}$};"""


tp = TikzPicture("""
\\draw (0,0) -- (10,10);
\\draw ($(a),0) -- (0,10);
\\node at (5,5) {tikz \$\\sqrt{\\pi}\$};
"""
, options="scale=0.25", preamble="")