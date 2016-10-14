#!/usr/bin/perl -w
@body=();
sub function{
  if(!open LIB, "< $LIB_NAME"){die "Can not open lib file!\n"}
  my ($connect,$net_cont,$cell_name,$pin_name,$cell_cont,$output_cont);
  my @b_cont=();
  my $incell_sign=0;
  while(<LIB>) {
    if(/^cell\((.*)\)/){
      $incell_sign=1;
      $cell_cont += 1;
      $connect="\t".$1." U$cell_cont"." ("
    }
    if(/^\s+pin\((.*)\)/){$connect.=".".$1."("}
    if(/input;/&$incell_sign){$connect.="net_".($cell_cont-1)."),"}
    if(/output;/&$incell_sign){
      $output_cont+=1;
      if($output_cont==1){$connect.="net_".($cell_cont)."),"}
      else{$connect.="),"}
    }
    if(m/{/& $incell_sign){unshift @b_cont,1}
    if(m/}/& $incell_sign){shift @b_cont}
    if((!@b_cont)& $incell_sign){
      $_=$connect.");\n";
      s/\),\)/\)\)/;
      $incell_sign=0;
      $output_cont=0;
      push(@body,$_);
    }
  }
  $_=shift @body;
  s/net_0/in/g;
  unshift (@body,$_);
  $_=pop @body;
  s/net_$cell_cont/out/g;
  push(@body,$_."\nendmodule");
  close LIB;
  if($cell_cont==0){die "Empty Lib file!\n"}
  print "Reading lib file succeeded! This Lib has $cell_cont cells.\n";
  $connect="\twire";
  foreach(1..($cell_cont-1)){$connect.=" net_".$_.","}
  $_=$connect.";\n";
  s/,;/;/;
  unshift(@body,$_);
  unshift(@body,$head);
}
sub write_file{
  if(!open TAR, "> $TAR_NAME.v"){die "Can not open $TAR_NAME.v file!$!"}
  print TAR @body;
  close TAR;
  print "Writting $TAR_NAME.v succeeded!\n";
}
$LIB_NAME = shift @ARGV;
$TAR_NAME = shift @ARGV;
if(!$LIB_NAME){print "Please type lib_name:";chomp($LIB_NAME = <STDIN>)}
if(!$TAR_NAME){print "Please type target_name:";chomp($TAR_NAME = <STDIN>)}
$head="//This file is auto built by perl\n\nmodule $TAR_NAME\n\t(\n\t\tinput in,\n\t\toutput out\n\t);\n\n";
&function;
&write_file;
exit 1
