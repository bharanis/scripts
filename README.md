
doxygen_dot_merge.pl:
=====================

merge multiple doxygen generated dot files.
This is useful for generating a call map for a file or a bunch of files.

1) This command is to be run from outside the html directory where doxygen puts all the html, dot and map files.
2) This command assumes flat directory structure used in doxygen
   CREATE_SUBDIRS         = NO
3) doxygen prefixes the source filename to the name of the output dot files. One dot file is generated per function
4) only provide "cgraph" or "icgraph" as input. Not both.
5) provide the list of doxygen generated dot files to be merged.
eg:
./doxydotmerge.pl  `ls html/ssd_*_8c*_cgraph.dot  | grep -v test | grep -v buf `
