#!/usr/bin/perl

use Data::Dumper;
use feature 'say';

my $gindex = 1;
my %node2node = ();
my %connections = ();
my %sym2node = ();
my %sym2url = ();
my %file2nodes = ();
my %node2sym = ();



foreach $argnum (0 .. $#ARGV) {

  for (keys %node2node)
  {
    delete $node2node{$_};
  }

  # pass 1:: node mappings
  open (dotf,$ARGV[$argnum]) || die "Cannot read logfile!\n";;
  while (<dotf>) {
    if (/Node/) {
      my ($num, $sym, $rest) = /^ *Node(\d+) \[label=\"([^\"]+)"(.*)$/;
      if ($num) {
         if (exists $sym2node{$sym}) {
            $node2node{$num} = $sym2node{$sym};
         } else {
            my ($url) = ($rest =~ m/^.*URL=\"([^\"]+)".*$/);
            $sym2node{$sym} = $gindex;
            $node2sym{$gindex} = $sym;
            $sym2url{$sym} = $url;
            $node2node{$num} = $gindex;
            $gindex ++;
         }

         if ($num == 1) {
             my ($file) = ($ARGV[$argnum] =~ m/(^.*)_8[ch].*$/);
             push(@{$file2nodes{$file}}, $sym2node{$sym});
         }
      }
    }
  }
  close(dotf);

  # pass 2:: renaming
  open (dotf,$ARGV[$argnum]) || die "Cannot read dot file!\n";;
  while (<dotf>) {
    if (/Node/) {
      my ($num1, $num2, $rest) = /^ *Node(\d+) -> Node(\d+)(.*)$/;
      if ($num1) {
         my $key=$node2node{$num1}.".".$node2node{$num2};
         if (exists $connections{$key}) {
         } else {
           $connections{$key} = "yes";
         }
      }
    }
  }
  close(dotf);
}


########### print df the .dot file

open (df, '>html/merged.dot');

print df "digraph G\n";
print df "{\n";
print df "  edge [fontname=\"FreeSans\",fontsize=\"10\",labelfontname=\"FreeSans\",labelfontsize=\"10\"];\n";
print df "  node [fontname=\"FreeSans\",fontsize=\"10\",shape=record];\n";
print df "  rankdir=LR;\n";
 

for (sort keys %sym2node) {
    print df "   Node".$sym2node{$_}." [label=\"".$_."\",height=0.2,width=0.4,color=\"black\", fillcolor=\"white\", style=\"filled\",URL=\"".$sym2url{$_}."\"];\n";
}
for (sort keys %connections) {
    my ($n1,$n2) = /(\d+)\.(\d+)/;
    print df "   Node".$n1." -> Node".$n2." [dir=front,color=\"midnightblue\",fontsize=\"10\",style=\"solid\",fontname=\"FreeSans\"];\n";
}

for (sort keys %file2nodes) {
  print df "#file >> ".$_."\n";
  print df "{ rank=same; ";
  foreach $i (0 .. (@{$file2nodes{$_}}-1)) {
    print df "   Node".$file2nodes{$_}[$i]."; ";
  }
  print df "}\n";
}



print df "}\n";
close(df);


########### generate png and map files
os.system("dot html/merged.dot -Tpng -o html/merged.png");
os.system("dot html/merged.dot -Tcmapx -o html/merged.map");

########## create html file and embed map in it

open (hf, '>html/merged.html');
print hf "<html>\n";
print hf "<div>\n";
print hf "<div class=\"center\">\n";
print hf "<img border=\"0\" alt=\"\" usemap=\"#merged_map\" src=\"merged.png\">\n";
print hf "</div>\n";
print hf "<map id=\"merged\" name=\"merged_map\">\n";

# contents of merged.map with $ removed
open (mf,"html/merged.map") || die "Cannot read map file!\n";;
while (<mf>) {
  if(/area/) {
    s/\$//;
    print hf $_; 
  }
}
close(mf);

print hf "</map>\n";
print hf "</div>\n";
print hf "</html>\n";
close(hf);
