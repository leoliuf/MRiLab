#convert latex to html in Windows

htlatex MRiLab_User_Guide.tex "epsconfig,2,frames"

#note: windows 'convert' actually failed, still need to find 'convert' which produces high dpi png

#resize image in html, change .css

div.figure img {text-align:center; height: auto; width: auto; max-width: 600px; max-height: 500px;}

#add "mathjax-config.js" to allow MathJax render in GitHub
