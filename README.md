# HPMOR_FR
This project aims to make a book-style PDF and possibly ebook/mobi formats
out of the French translation for Harry Potter & the Methods of Rationality.

HPMOR a déjà des traductions, et déjà des livres en ebook, mobi, et en PDF
(en un tome ou en sept) que des courageux peuvent imprimer et relier.
Ce projet veut faire un livre HPMOR français dans tous ces formats.

## CREDITS
HPMOR est écrit par Eliezer Yudkowsky http://hpmor.com/info/
Basé sur les oeuvres Harry Potter de J.K. Rowling.
Traduction par AdrienH, relecture par kilobug (1-10) et Lexyann (14-25).
Autres traductions, formatage, relecture par Sylvain Abélard.


# CONTRIBUTE
Ce projet suit la Contributor Covenant : http://contributor-covenant.org/

## USE
Vous pouvez modifier les fichiers pour le livre (format, options).
Une manière simple de tester rapidement est de ne faire que le livre 7
`ruby hpmorfr.rb test`

ou pour tout tester :
`ruby hpmorfr.rb`

## TRADUIRE / RELIRE
En temps voulu nous mettrons probablement les sources (HTML ou Markdown)
sur ce GitHub. Toute relecture ou mise en forme est la bienvenue :)

## INSTALL
```# get some software installed 
$ apt-get install wkhtmltopdf
$ gem install gimli```

`ruby hpmorfr.rb init`

## Poor man's scraping
Ce script va récupérer les traductions sur FanFiction.net
Soyez gentils, respectez leurs serveurs et leur travail, n'abusez pas.
Scrape responsibly.


# TODO

Des pistes à poursuivre si le rendu n'est pas satisfaisant :
```# Markdown 2 PDF
$ pandoc README.md -o readme-pandoc.pdf
md2pdf < test.md > test.md.pdf 
```

```# Markbook TOC
kramdown/marbook? {:toc}
```

```# LATEX TOC + links
\section{Chapter One}\hypertarget{chapter-one}{}\label{chapter-one}
\tableofcontents
\subsection{Section One}\hypertarget{section-one}{}\label{section-one}
```

```# EPUB
$ kramdown Joined.md -o html --template document > Joined.html
$ tidy -asxhtml -output tidy.xhtml Joined.html
$ ebook-convert tidy.xhtml Joined.epub
ebook-convert Joined.epub Joined.mobi
ebook-convert Joined.epub Joined.azw3
```
