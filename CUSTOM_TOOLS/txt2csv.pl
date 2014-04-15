#!/usr/bin/perl
use strict;
use warnings;
#******************************************************************************#
#perl scipt.pl <inputFile path> <outFile Path>
#perl txt2csv.pl C:\EMAILS\emails.txt C:\LI_with_htomail\emails\

my $commandline ='';
while (@ARGV)
{
	$commandline = "$commandline"." ".shift(@ARGV);
}
my @commargs;
@commargs = split (" ",$commandline);
my $emailsFilePath=$commargs[0];
my $resultFile=$commargs[1];
$emailsFilePath=~s/\s*//g;
$resultFile=~s/\s*//g;
my $temp='';
if ($emailsFilePath eq '') 
{
	print "Please provide full path for inputFile .txt email File\n";
	exit;
}
if($resultFile eq '')
{
	print "Please provide location for output .csv File\n";
	exit;
}
if ($emailsFilePath=~/.*[\/\\](.*?)\.txt/is) 
{
	$temp=$1;
	$temp=~s/\s*//g;
}else{
	print "format in correct!\n";
}
$resultFile=~s/(?:\/|\\)$//g;
$resultFile=$resultFile.'/';
$resultFile=~s/\s*//g;

my $count=1;
my $j=1;
my $flag=1;
my $resultFile1=$resultFile.$temp.'_'.$j.'.csv';
print "Going to devide txtFile into CSVFile\n";
open(FILE,$emailsFilePath) or die "Can't read file $emailsFilePath [$!] \n";
while(<FILE>)
{
	my $email=$_;
	$email=~s/^\s+|\s+$//g;
	$email=','.','.$email."\n";
	if ($count>850) 
	{
		print "FileName -- $resultFile1 -- has been created.\n";
		$flag=1;
		$count=1;
		$j++;
		$resultFile1=$resultFile.$temp.'_'.$j.'.csv';
	}
	$count++;
	WriteToCSVfile($resultFile1,$email,\$flag);
}
close (FILE);
print "\n\n -- PROCESS HAS BEEN COMPLETED --\n\n";
#------------------------ Create CSV FIle Function ------------------------------#
sub WriteToCSVfile
{
	my($file,$content,$flag)=@_;
	my $content1="First Name,Last Name,E-mail Address\n";
	if($$flag==1)
	{
		open OUT, ">$file" or die "Cannot open $file for write :$!";
		print OUT "$content1";
		close OUT;
		$$flag++;
	}
	if ($$flag==2)
	{
		open OUT, ">>$file" or die "Cannot open $file for write :$!";
		print OUT "$content";
		close OUT;
		$$flag++;
	}
	else
	{
		open OUT, ">>$file" or die "Cannot open $file for write :$!";
		print OUT "$content";
		close OUT;
	}
}
#********************************* END OF FILE **************************************#
