

tikzplotTEX = L"""\documentclass[border={5pt 0pt 20pt 5pt}, preview]{standalone}

\usepackage{pgfplots}
\pgfplotsset{compat=1.15}
\usepackage{xcolor}


\usepackage{tikz}
\usepackage[utf8]{inputenc}
\usepackage{xfp}
\usepackage{booktabs}
\usetikzlibrary{calc}
\usepackage{graphicx}

\newcommand{\Del}[1]{\textit{$\Delta$\MakeLowercase{#1}}}
\newcommand\ratio[2]{%
    \pgfmathparse{ #1/(#1 + #2)}\pgfmathresult
}


\newcommand\colorBar{
    \begin{tikzpicture}

       
        \pgfdeclarehorizontalshading{someShading}{4cm}{
        color(0cm)=(green!0!gray);
        color(4cm)=(green!100!gray)
        }
        
        \shade [shading=someShading](0,0) rectangle ++(1,0.3);
        \node [] at (0,-0.2) {0};
        \node [] at (1,-0.2) {1};
        
        \end{tikzpicture}
}


\newcommand\particle[2]{%
  \begin{tikzpicture}[x=2cm, y=2cm]
  
  % Calculate the ratio of nucleus to cytosol concentration
  \def\nratio{\fpeval{ round(#1/(#1 + #2),2)}  };
  \def\cratio{\fpeval{ round(#2/(#1 + #2),2)}  };
  
  %Node for Circles
  \node at (0,0) [circle,draw, scale=1 ,fill=green!\fpeval{round(100*\cratio)}!gray] (c2) {};
  
  \node at (0,0) [circle,draw, scale=0.5 ,fill=green!\fpeval{round(100*\nratio)}!gray] (c1) {};
  
  
  %Node for line ends
  \node [inner sep=0,outer sep=0, xshift=0.2cm] at (c1.east) (n_conc) {};
  \node [inner sep=0,outer sep=0,yshift = -0.09cm] at (n_conc.south) (c_conc) {};
  
  % Node for data
  \node [inner sep=0,outer sep=0, xshift=0.cm, text width = 0cm, align=left] at (n_conc.east) {\scalebox{.2}{\nratio} };
  \node [inner sep=0,outer sep=0, xshift=0.cm, text width = 0cm, align=left] at (c_conc.east) {\scalebox{.2}{\cratio}};
  
  % Draw Lines
  \draw[-, very thin] (n_conc) -- (c1);
  \draw[-, very thin] (c_conc) -- (0.13cm,-0.1065cm);
  
  \end{tikzpicture}
}

\newcommand\drawRatio[2]{%
    \begin{tikzpicture}[baseline={(c_conc.base)}, outer sep=0]
        \def\sc{3}
        \node at (0,0) [scale=\sc] {\particle{#1}{#2}};
    \end{tikzpicture}
}



\begin{document}

\begin{tabular}[c]{p{1.4cm}p{1.8cm}p{2.8cm}|p{1.8cm}p{1.6cm}}
    \toprule
    \multicolumn{1}{c}{} & \multicolumn{2}{c}{\textbf{Healthy Mitochondria}} & \multicolumn{2}{c}{\textbf{Damaged Mitochondria}} \\ \midrule
     &\textbf{Simulation} & \multicolumn{1}{c}{\textbf{Data}}\hspace{0.52cm}  & \textbf{Simulation} & \hspace{0.5cm}\textbf{Data}  \\ 
     &   \multicolumn{4}{c}{\textbf{Rtg3-GFP}}  \\
    WT & \drawRatio{1}{0} & \drawRatio{0}{1} & \drawRatio{1}{2} & \drawRatio{1}{2} \\
    \Del{Rtg1} & \drawRatio{1}{2} & \drawRatio{1}{2}  & \drawRatio{1}{2} & \drawRatio{1}{2} \\
    \Del{Rtg2} & \drawRatio{1}{2} & \drawRatio{1}{2}& \drawRatio{1}{2} & \drawRatio{1}{2} \\
    \Del{Mks} & \drawRatio{1}{2} & \drawRatio{1}{2}& \multicolumn{2}{r}{}  \\
    \Del{Rtg2}\Del{Mks} & \drawRatio{1}{2} & \drawRatio{1}{2} & \multicolumn{2}{r}{} \\ 
     &   \multicolumn{4}{c}{\textbf{Rtg1-GFP}}   \\
    WT & \drawRatio{1}{0} & \drawRatio{0}{1} & \drawRatio{1}{2} & \drawRatio{1}{2} \\
    \Del{Rtg3} & \drawRatio{1}{2} & \drawRatio{1}{2}& \drawRatio{1}{2} & \drawRatio{1}{2} \\
    \Del{Rtg2} & \drawRatio{1}{0} & \drawRatio{0}{1} & \drawRatio{1}{2} & \drawRatio{1}{2} \\ 
    \Del{Mks} & \drawRatio{1}{2} & \drawRatio{1}{2}& \multicolumn{2}{r}{}  \\
    \Del{Rtg2}\Del{Mks} & \drawRatio{1}{2} & \drawRatio{1}{2} & \multicolumn{2}{r}{} \\ 
      &   \multicolumn{4}{c}{\textbf{Rtg2-GFP}}   \\
    WT & \drawRatio{1}{0} & \drawRatio{0}{1} & \drawRatio{1}{2} & \drawRatio{1}{2} \\
    &  & & \multicolumn{2}{c}{\colorBar} \\
    \bottomrule
\end{tabular}

\end{document}
"""
