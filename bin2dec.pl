#!/usr/bin/perl -w
$_ = shift @ARGV;
my $result = 0;
my $cont = 0;
my @word = split //;
foreach(@word){
  $cont += 1;
  if($_==1){
    $result += 0.5**$cont;
  }
}
print "$result\n";
