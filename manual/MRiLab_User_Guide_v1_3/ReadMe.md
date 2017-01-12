# convert latex to html

### convert latex to html in Windows using Mathjax
This works fine in sourceforge for equation rendering, but not for GitHub for this case
```
htlatex MRiLab_User_Guide.tex "epsconfig_mathjax,2,frames"
```
### convert latex to html in Windows using svg
GitHub doesn't render MathJax well and htlatex converts equation into low quality png file by default, so switch to use svg file
First, use modified tex4ht.env instead of default one (see [this][1])
```
htlatex MRiLab_User_Guide.tex "epsconfig_svg,2,frames"
```
### resize image in html
change .css to scale image size (see [this][2])
```
div.figure img {text-align:center; height: auto; width: auto; max-width: 600px; max-height: 500px;}
```






[1]:<http://tex.stackexchange.com/questions/43772/latex-xhtml-with-tex4ht-bad-quality-images-of-equations>
[2]:<http://stackoverflow.com/questions/787839/resize-image-proportionally-with-css>