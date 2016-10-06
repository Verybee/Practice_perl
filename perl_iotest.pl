#!/usr/bin/perl -w
sub read_lib{
  if(!open LIB, "< $LIB_NAME"){die "Can not open lib file!\n"}
  if(!open TEMP, "> lib_temp"){die "Can not open temp file!\n"}
  $cell_cont=0;
  my $incell_sign=0;
  my $cell_name;
  my @b_cont=();
  while(<LIB>) {
    if(/^cell\b.(.*).../){
      print TEMP "cell_name $1\n";
      $incell_sign=1;
      $cell_cont += 1;
    }
    if(/^...pin\b.(.*).../){print TEMP "input $1\n"}
    if(/^..pin\b.(.*).../){print TEMP "output $1\n"}
    if(m/{/& $incell_sign){unshift @b_cont,1}
    if(m/}/& $incell_sign){shift @b_cont}
    if((!@b_cont)& $incell_sign){
      printf TEMP "cell_end\n";
      $incell_sign=0;
    }
  }
  close LIB;
  close TEMP;
  if($cell_cont==0){unlink lib_temp;die "Empty Lib file!\n"}
  print "Reading lib file succeeded! This Lib has $cell_cont cells.\n";
}

sub write_head{
  print TAR "//****************************************//\n";
  print TAR "//This file is auto built by perl\n";
  print TAR "//****************************************//\n";
  print TAR "module $TAR_NAME\n\t(\n\t\tinput in,\n\t\toutput out\n\t);\n\n";
}
sub write_end{
  print TAR "\nendmodule\n\n";
}

sub write_wire{
  my $wire_cont = $cell_cont-1;
  print TAR "\twire";
  foreach(1..$wire_cont){
    if($_==$wire_cont){print TAR " net_$_;"}
    else {print TAR " net_$_,"}
  }
  print TAR "\n";
}

sub connect{
  my $unit_cont=0;
  my $pin_name;
  if(!open TEMP, "< lib_temp"){die "Can not open temp file!\n"}
  while(<TEMP>){
    if(/cell_name.(.*)/){
      $unit_cont+=1;
      print TAR "\t$1 U$unit_cont ( ";
    }
    if(/input.(.*)/){
      $pin_name=$1;
      if($unit_cont==1){print TAR ".$pin_name(in),"}
      else{printf TAR ".$pin_name(net_%d),",$unit_cont-1}
    }
    if(/output.(.*)/){
      $pin_name=$1;
      if($unit_cont==$cell_cont){print TAR ".$pin_name(out),"}
      else{printf TAR ".$pin_name(net_%d),",$unit_cont}
    }
    if(/cell_end/){print TAR " );\n"}
  }
  close TEMP;
  unlink lib_temp;
}

sub write_file{
  if(!open TAR, "> $TAR_NAME.v"){die "Can not open $TAR_NAME.v file!$!"}
  &write_head;
  &write_wire;
  &connect;
  &write_end;
  close TAR;
  print "Writting $TAR_NAME.v succeeded!\n";
}

$LIB_NAME = shift @ARGV;
$TAR_NAME = shift @ARGV;
if(!$LIB_NAME){print "Please type lib_name:";chomp($LIB_NAME = <STDIN>)}
if(!$TAR_NAME){print "Please type target_name:";chomp($TAR_NAME = <STDIN>)}
&read_lib;
&write_file;
exit 1
