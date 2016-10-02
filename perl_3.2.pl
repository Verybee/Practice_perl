#!/usr/bin/perl
@name = ("fred","betty","barney","dino","Wilma","pebbles","bamm-bamm");
chomp(@num=<STDIN>);
foreach $num(@num){
  print "$name[$num-1]\t";
}
print "\n";
exit(0);
