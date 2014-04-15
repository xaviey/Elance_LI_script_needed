#!/usr/bin/perl
# Version 1.0 07-Apr-2014 by Xaviey 
#
# Version 1.1.0 11-Apr-2014 by Xaviey
#		Adjust HOTMAIL_DELETE_CONTACTS() to work efficiently
#		Adjust the sleep to fit in script
#
# Version 1.1.1 12-Apr-2014 By Xaviey
#		Revised & Final HOTMAIL_DELETE_CONTACTS()
#		Revised HOTMAIL_ADD_CONTACTS()

use Cwd;
use WWW::Mechanize;

my $agent = WWW::Mechanize->new(autocheck => 0);
my $agent_HOT='';
my $agent_LI='';
my $proxyStatus=1;    # If this value = 1 it will use proxies and if it has 0 then it will NOT use proxies
my $outName='output_File.xls';
my $inputFile_Path='input.txt';
my %inputFile=();
$inputNum=0;
$inputNum1=$ARGV[0];
if($inputNum1!='')
{
	$inputNum=$inputNum1-1;
}
####---INPUT-FILE-------####
if(-e $inputFile_Path)
{
	open(FILE,$inputFile_Path) or die "Can't read file $inputFile_Path [$!] \n";
	while(<FILE>) {
		my ($key,$val)=split(/\=/,$_);
		$key=~s/^\s+|\s+$//g;
		$val=~s/^\s+|\s+$//g;
		$inputFile{$key}=$val;
	}close (FILE);
}else {
	print "\n".$inputFile_Path." --inputFile-- file Doesn't Exists \n"; exit;
}

my $resumeFile="resumeFile.txt";
my $checkSearch="";
if(-e $resumeFile) {
	$checkSearch=readFile($resumeFile);
	$checkSearch=~s/\|$//isg;
}
my $email;
my $filePath;
my $dirPath=getcwd.'/emails';
print "------ Started --------- \n";
my @ips=split(',',$inputFile{'proxy'});
my @liusers=split(',',$inputFile{'users'});
my @gmusers=split(',',$inputFile{'hotmailusers'});
my $email;
my @usArray=split(":",$liusers[$inputNum]);
my @GusArray=split(":",$gmusers[$inputNum]);
print my $username=$usArray[0];
my $password=$usArray[1];
my $Gusername=$GusArray[0];
my $Gpassword=$GusArray[1];
my $HM_LogouFile='';
my $LI_LogouFile='';
print "username: $username\npassword: $password \nGusername: $Gusername \nGpassword: $Gpassword \n";
print "------** Started **---------\n";

HEADER();
print "Check if any contact pre-exists in HM!\n";
HOTMAIL_DELETE_CONTACTS(); ##working - TESTED
print "print Check if any contact pre-exists in LI!\n";
DELETE_LI(); ##working - TESTED
print "Cleaning done\n";

opendir(DIR, $dirPath) || die "Can't open directory: $!\n";
while (my $filename = readdir(DIR)) {
	if($filename=~/^\./is){next;}
    $filePath= $dirPath."/".$filename;
	if($checkSearch ne ""){
		if($checkSearch =~ /$filename/is){next;}
	}
	print "Going for File -> $filename\n";
	%emailHash=();
	%contHash=();
	@contArray=();
	HEADER();
	HOTMAIL_ADD_CONTACTS();##working - TESTED
	IMPORT_CONTACTS();##working - TESTED
	@contArray=();
	GET_DATA();##working - TESTED
	HOTMAIL_DELETE_CONTACTS();##working - TESTED
	@contArray=();
	%contHash=();
	DELETE_LI();##working - TESTED
	LI_Logout();##working - TESTED
	my $resume_name="$filename\n";
	appendToFile($resumeFile,$resume_name);
	print "------ Completed processing $filename ---------\n";
	print "DONE and take 5 \n";
	sleep(300);
}
closedir(DIR);
print "-----Completed--------\n";
sub HOTMAIL_ADD_CONTACTS
{
	HOTMAIL_LOGIN();
	print "Going to ADD Contacts in HOTMAIL Account ....\n";
	print " \n";
	print "********** HOTMAIL ACCOUNT ************* \n";
	print "username: $username \npassword: $password \nGusername: $Gusername \nGpassword: $Gpassword \n";
	print " \n";
	print " \n";
	my $url="https://people.live.com/";
	my $response=$agent_HOT->get($url);
	my $htmlPage = $agent_HOT->content;
	writeToFile('output/peopleHM.htm',$htmlPage);

	$url='https://people.live.com/import';
	$response=$agent_HOT->get($url);
	$htmlPage = $agent_HOT->content;
	writeToFile('output/importHM.htm',$htmlPage);
	my $try_count=0;

	HM_IMPORT:
		if($try_coun>0 && $try_count<=3){
			sleep(4);
			$url='https://people.live.com/import/other?biciid=ImportCatalog';
			$response=$agent_HOT->get($url);
			$htmlPage = $agent_HOT->content;
			writeToFile("output/ImportCatalogHM_$try_count.htm",$htmlPage);
			$agent_HOT->add_header(
				'User-Agent'=>'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)',
				'Host'=>'bay182.mail.live.com',
				'DNT'=>'1',
			);
		}elsif($try_count>3){
			print "NO Contacts Added into the HOTMAIL - Please check why!! \n";
			print "\n";
			exit;
		}
		$url="https://bay182.mail.live.com/mail/options.aspx?subsection=eImport";
		$response=$agent_HOT->get($url);
		$htmlPage = $agent_HOT->content;
		writeToFile("output/eImport_$try_count.htm",$htmlPage);
		if ($htmlPage=~/(?:<form[^<>]+?id\W+form1)/is)
		{
			my $cookie=$response->{_request}{_headers}{cookie};
			if($cookie=~/mt\s*=\s*(.*?);/is)
			{
				$cookie=$1;
			}
			$agent_HOT->form_id('Form1');
			$agent_HOT->field('ctl05$FileUploadControl'=>$filePath);
			$agent_HOT->field('__EVENTTARGET'=>'ctl05$FileUploadButton');
			$agent_HOT->field('mt'=>$cookie);
			$agent_HOT->submit();
			$htmlPage = $agent_HOT->content();
			writeToFile('output/AddHM.htm',$htmlPage);
			if($htmlPage=~/\s+successfully\s+imported\s+your\s+contacts/is or $htmlPage=~/\d+\s+new\s+contacts\s+have\s+been\s+added/is)
			{
				print "Contacts Added Successfully!! \n";
				return;
			}

			$try_count++;
			goto HM_IMPORT;
		}else{
			print "Form1 --HM-- Not found!\n";
			exit;
		}
}
sub HOTMAIL_LOGIN
{
	print "Going To Login on HOTMAIL....\n";
	my $url="http://www.hotmail.com/‎";
	$agent_HOT->get($url);
	$htmlPage = $agent_HOT->content;
	clearFile(\$htmlPage);
	my %formData=();
	parseFormData($htmlPage,\%formData);
	if ($htmlPage=~/urlPost\s*:\s*["'](.*?)['"]/is)
	{
		$url= $1;
		$url=~s/\s//g;
	}
	$formData{'login'} =$Gusername;
	$formData{'passwd'} =$Gpassword;  
	$formData{'LoginOptions'} = 3;
	$formData{'NewUser'} = 1;
	$formData{'idsbho'} = 1;
	$formData{'sso'} = 0;
	$formData{'LoginOptions'} = 3;
	$formData{'type'} = 11;
	$formData{'i1'} = 0;
	$formData{'i2'} = 1;
	$formData{'i3'} = 612611;
	$formData{'i4'} = 0;
	$formData{'i7'} = 0;
	$formData{'i12'} = 1;
	$formData{'i13'} = 0;
	$formData{'i14'} = 347;
	$formData{'i15'} = 10674;
	$formData{'i17'} = 0;
	$formData{'i18'} = '__Login_Strings%7C1%2C__Login_Core%7C1%2C';
	$formData{'i12'} = 11;
	my $response=$agent_HOT->post($url,\%formData);
	$htmlPage = $agent_HOT->content;
	clearFile(\$htmlPage);
	if ($htmlPage=~/window\.location\.replace\W+(.*?)['"]/is) 
	{
		$url=$1;
		$url=~s/\s//g;
		$agent_HOT->get($url);
		$htmlPage = $agent_HOT->content;
	}
	$HM_LogouFile=$htmlPage;
	writeToFile('output/HOTlogin.htm',$htmlPage);
	return 1;
}

sub HOTMAIL_DELETE_CONTACTS
{

	my $check_hm_count=0;
	#Label to check
	CHECK_HM:
		HEADER();
		HOTMAIL_LOGIN();
		$url="https://people.live.com/";
		my $response=$agent_HOT->get($url);
		my $htmlPage1 = $agent_HOT->content;
		clearFile(\$htmlPage1);
		my $autherID='';
		if($htmlPage1=~/AuthUser\s*:\s*["'](.*?)['"]/is)
		{
			$autherID=$1;
		}
		$url="https://people.directory.live.com/people/abcore?SerializeAs=compact&market=en-in&appid=EC521704-D600-4108-AAB9-116D4782CBC4&version=W5.M2&cbus=0.9243767135705927";
		$response=$agent_HOT->get($url);
		$htmlPage = $agent_HOT->content;
		writeToFile('output/DELGM-contacts1.htm',$htmlPage);
		clearFile(\$htmlPage);
		my @hm_del_con=();
		if($htmlPage=~/["]\s*ABCH\s*["]/is)
		{
			print "Going to Delete HM Contacts!!...\n";
			while($htmlPage=~/["]\s*ABCH\s*["]/is)
			{
				$htmlPage=$';
				my $tempFile=$`;
				if ($tempFile=~/.*\[\[["](.*?)["]/is)
				{
					push @hm_del_con,$1
				}
			}
			print "Total Contacts -> ". scalar @hm_del_con."\n";
			print "\n";
			my $i=1;
			my $contactID="";
			foreach(@hm_del_con)
			{
				$contactID.=',"'.$_.'"';
				if($i==100 && (scalar @hm_del_con) >100)
				{
					$contactID=~s/^\,|\,$//g;
					$htmlPage=del_hm_process($contactID,$autherID);
					writeToFile('output/del_hm_process.htm',$htmlPage);
					$i=0;
					$contactID='';
				}
				$i++;
			}
			$contactID=~s/^\,|\,$//g;
			$htmlPage=del_hm_process($contactID,$autherID);
			writeToFile('output/del_hm_process.htm',$htmlPage);
			if ($htmlPage=~/\W+Success\W+true/is){
				print "All HM Contacts Deleted Successfully!!\n";
			}
			if($check_hm_count<=3)
			{
				HM_Logout();
				$check_hm_count++;
				goto CHECK_HM;
			}
		}
		else
		{
			print "No contcats in HM!\n";
		}
	HM_Logout();
}

sub del_hm_process
{
	my ($contactID,$autherID)=@_;
	my %formData=();
	$formData{'cn'} = "Microsoft.Live.People.Service.PeopleService";
	$formData{'mn'} = "DeleteContacts";
	$formData{'d'} ="[".$contactID."]";
	$formData{'v'} = 1;
	my $url1= 'https://people.live.com/people.fpp?cnmn=Microsoft.Live.People.Service.PeopleService.DeleteContacts&ptid=0&a=&au='.$autherID;
	$url1=~s/\s//g;
	my $response=$agent_HOT->post($url1,\%formData);
	$htmlPage = $agent_HOT->content;
	return $htmlPage;
}

sub GET_DATA
{
	$agent_LI->get("https://www.linkedin.com/home?trk=nav_responsive_tab_home");
	$htmlPage = $agent_LI->content;
	writeToFile('output/home.htm',$htmlPage);
	$agent_LI->get("https://www.linkedin.com/profile/edit?trk=nav_responsive_sub_nav_edit_profile");
		$htmlPage = $agent_LI->content;
		writeToFile('output/1EditProfile.htm',$htmlPage);
	$agent_LI->get("https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections");
	$htmlPage = $agent_LI->content;
		writeToFile('output/2contactslist.htm',$htmlPage);
	$agent_LI->get("http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts");
	$htmlPage = $agent_LI->content;
		writeToFile('output/3contactslist.htm',$htmlPage);
	###----------------------
	%formData=();
	$postUrl="http://www.linkedin.com/people/directoryContactsBrowse";
	$formData{'initial'}='DONT_CARE';
	$formData{'invited'}='true';
	$formData{'batchId'}='0';
	$formData{'membersOnly'}='false';
	$formData{'meta'}='false';
	$formData{'threshold'}='500';
	$agent_LI->add_header(
		'Referer'=>'http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts',
		'X-IsAJAXForm'=>'1',
		'X-Requested-With'=>'XMLHttpRequest',
	);
	$agent_LI->post($postUrl,\%formData);
	$htmlPage = $agent_LI->content;
	writeToFile('output/4contactslist.htm',$htmlPage);
	my @initialArray=();
	if($htmlPage=~/activeInitials\W+(.*?)\]\s*\}/is){
		$initial=$1;
		$initial=~s/\"|\\//isg;
		@initialArray= split(',',$initial);
	}
	###----------------------
	$total=$#initialArray+1;
	for($i=0;$i<$total;$i++)
	{
		print "Going to Get Contacts for $initialArray[$i].. \n";
		%formData=();
		$postUrl="http://www.linkedin.com/people/directoryContactsBrowse";
		$formData{'initial'}=$initialArray[$i];
		$formData{'invited'}='true';
		$formData{'batchId'}='0';
		$formData{'membersOnly'}='false';
		$formData{'meta'}='false';
		$formData{'threshold'}='500';
		$agent_LI->add_header(
			'Referer'=>'http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts',
			'X-IsAJAXForm'=>'1',
			'X-Requested-With'=>'XMLHttpRequest',
		);
		$agent_LI->post($postUrl,\%formData);
		$htmlPage = $agent_LI->content;
		writeToFile('output/5contactslist.htm',$htmlPage);
		my $flag=0;
		while($htmlPage =~ /hasNonSummaryData\W+(.*?)(\"\s*\}\s*,\s*\{|\}\s*\])/is)
		{
			$flag=1;
			$htmlPage=$';
			$tempPage=$1;
			$liFlag="N";
			($email,$contactid,$profilelink,$fname,$lname,$title)="";
			if($tempPage =~ /\W+displayNameFL\W+(.*?)\\[\'\"]/is){
				($fname,$lname)=split(" ",$1);
			}
			if($tempPage =~ /\W+mainEmail\W+(.*?)\\[\'\"]/is){
				$email=$1;
			}
			if($tempPage =~ /\W+displayHeadline\W+(.*?)\\[\'\"]/is){
				$title=$1;
				$title=~s/mainEmail//is;
			}
			if($tempPage =~ /\W+profileLink\W+(.*?)\\[\'\"]/is){
				$profilelink="http://www.linkedin.com/".$1;
			}
			if($tempPage =~ /\"contactID\W+(.*?)\\[\'\"]/is){
				$contactid=$1;
				unless(exists $contHash{$1}){
					push (@contArray,$contactid);
					$contHash{$1}=1;
				}
			}
			if($profilelink ne ""){$liFlag="Y";}
			unless(exists $emailHash{$email}){
				$data="$fname\t$lname\t$email\t$title\t$profilelink\t$liFlag\n";
				appendToFile($outName,$data);
				$emailHash{$email}=1;
			}
		}
		if($flag==0){
			ERROR("There are no contacts available in the LinkedIn Invites List!");
			print "There are no contacts available in the LinkedIn Invites List!\n";
			return 0;
		}elsif($flag==1){
			print "Records -> ".$#contArray."\n";
			print "Now sleeping for 5 secs\n";
			sleep(5); ## sleep for 5 seconds and then get all records, at every alphabet. (was 5 secs)
		}
	}
	return 1;
}

sub DELETE_LI
{
	LI_Logout() unless($LI_LogouFile eq '');
	print "sleeping for 120 secs now after LI_Logout in DELETE_LI\n";
	sleep(120);
	HEADER();
	GET_LOGIN();
	print "sleeping for 10 secs now\n";
	sleep(10);
	$agent_LI->get("http://www.linkedin.com/connections?type=combined&trk=nav_responsive_sub_nav_network");
	$htmlPage =$agent_LI->content;
	writeToFile('output/rand1.htm',$htmlPage);
	sleep(4);
	$agent_LI->get("http://www.linkedin.com/company/home?trk=nav_responsive_sub_nav_companies");
	$htmlPage = $agent_LI->content;
	writeToFile('output/rand2.htm',$htmlPage);
	sleep(3);
	$agent_LI->get("https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections");
	$htmlPage = $agent_LI->content;
	writeToFile('output/2.htm',$htmlPage);
	sleep(2);
	$agent_LI->get("http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts");
	$htmlPage = $agent_LI->content;
	writeToFile('output/3.htm',$htmlPage);
	###----------------------
	%formData=();
	$postUrl="http://www.linkedin.com/people/directoryContactsBrowse";
	$formData{'initial'}='DONT_CARE';
	$formData{'invited'}='true';
	$formData{'batchId'}='0';
	$formData{'membersOnly'}='false';
	$formData{'meta'}='false';
	$formData{'threshold'}='500';
	$agent_LI->add_header(
		'Referer'=>'http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts',
		'X-IsAJAXForm'=>'1',
		'X-Requested-With'=>'XMLHttpRequest',
	);
	$agent_LI->post($postUrl,\%formData);
	$htmlPage =$agent_LI->content;
	writeToFile('output/4.htm',$htmlPage);
	my @initialArray=();
	if($htmlPage=~/activeInitials\W+(.*?)\]\s*\}/is){
		$initial=$1;
		$initial=~s/\"|\\//isg;
		@initialArray= split(',',$initial);
	}
	###----------------------
	sleep(5);
	$total=$#initialArray+2;
	for($i=0;$i<$total;$i++)
	{
		print "Going to Get Contacts for $initialArray[$i].. \n";
		%formData=();
		$postUrl="http://www.linkedin.com/people/directoryContactsBrowse";
		$formData{'initial'}=$initialArray[$i];
		$formData{'invited'}='true';
		$formData{'batchId'}='0';
		$formData{'membersOnly'}='false';
		$formData{'meta'}='false';
		$formData{'threshold'}='500';
		$agent_LI->add_header(
			'Referer'=>'http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts',
			'X-IsAJAXForm'=>'1',
			'X-Requested-With'=>'XMLHttpRequest',
		);
		$agent_LI->post($postUrl,\%formData);
		$htmlPage = $agent_LI->content;
		writeToFile('output/5.htm',$htmlPage);
		my $flag=0;
		while($htmlPage =~ /hasNonSummaryData\W+(.*?)(\"\s*\}\s*,\s*\{|\}\s*\])/is)
		{
			$flag=1;
			$htmlPage=$';
			$tempPage=$1;
			$liFlag="N";
			$contactid="";
			if($tempPage =~ /\"contactID\W+(.*?)\\[\'\"]/is){
				$contactid=$1;
				unless(exists $contHash{$contactid}){
					push (@contArray,$contactid);
					$contHash{$contactid}=1;
				}
			}
			
		}	
	}
	sleep(10);
	DELETE1();
}

sub DELETE1
{
	LI_Logout();
	print "sleeping for 60 secs now after LI_Logout in DELETE1\n";
	sleep(60);
	HEADER();
	GET_LOGIN();
	print "sleeping for 5 secs now\n";
	sleep(5);
	$agent_LI->get("https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections");
	$htmlPage = $agent_LI->content;
	writeToFile('output/6.htm',$htmlPage);
	print "Going to Delete Contacts from LinkedIn...\n";
	my $url="http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts";
	$agent_LI->add_header();
	$agent_LI->get($url);
	$htmlPage = $agent_LI->content;
	writeToFile('output/7.htm',$htmlPage);
	if($htmlPage =~ m/id\W+contacts-browser-form\W+(.*?)<\/form/is)
	{
		my $data=$1;
		my %formData=();
		parseFormData($data,\%formData);

		my $contID='';
		$total=$#contArray+1;
		print "Total Records to delete -> ".$total."\n";
		for($i=1;$i<=$total;$i++)
		{
			$contID.=" ".$contArray[$i-1];
			if($i%200 == 0)
			{
				$contID=~s/^\s+|\s+$//is;
				LI_del_process($contID,\%formData,$i);
				$contID='';
			}
		}
		$contID=~s/^\s+|\s+$//is;
		LI_del_process($contID,\%formData,$i-1);
	}
	else
	{
		writeToFile('output/manage_contact.htm',$htmlPage);
		ERROR("--Li Delete Form Not Found---!");
	}
}

sub LI_del_process
{
	my($contID,$formData,$i)=@_;
	$formData->{'contactIds'} = $contID;
	$formData->{'delete'} = 'Submit';
	$agent_LI->post('https://www.linkedin.com/people/submit-contact',$formData);
	$htmlPage2 = $agent_LI->content;
	writeToFile('output/LI_delete.htm',$htmlPage2);
	if(($htmlPage2 =~ /<strong>\s*\d+\s*contact\(s\)\s+were\s+deleted\s+from\s+your\s+Contacts\s+list/is) or ($htmlPage2 =~ /<h3>\s*Contact\s+Removal\s+Processing/is))
	{
		print "Contacts Deleted: $i against Total: $total\n";
		sleep(10);
		return 1;
	}
}

sub IMPORT_CONTACTS
{
	print "Entered IMPORT_CONTACTS \n";
	GET_LOGIN();
	sleep(4);
	print "Going to Add EM's \n";
	#my $add_conx_url='https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections';
	my $add_conx_url='https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_utilities_add_connx';
	$agent_LI->get($add_conx_url);
	$htmlPage = $agent_LI->content;
	writeToFile('output/nav_utilities_add_connx.htm',$htmlPage);
	sleep(10);
	if($Gusername=~/gmail/is){
		$agent_LI->submit_form(form_id => 'abook-import-form-gmail',fields => {email=> $Gusername,password=>$Gpassword});
		$agent_LI->get("http://www.linkedin.com/reg/webmail-connect-entry-v2?goback=%2Efiie_*1_gmail_*1_*1_*1_*1_*1_*1&origin=gmail&goback=.fiie_*1_gmail_*1_*1_*1_*1_*1_*1&flow=1qbwqgl-1x89vr3");
	}elsif($Gusername=~/yahoo/is){
		$agent_LI->submit_form(form_id => 'abook-import-form-yahooSocial',fields => {email=> $Gusername,password=>$Gpassword});
		$agent_LI->get("http://www.linkedin.com/reg/webmail-connect-entry-v2?goback=%2Efiie_*1_yahooSocial_*1_*1_*1_*1_*1_*1&origin=yahooSocial&goback=.fiie_*1_yahooSocial_*1_*1_*1_*1_*1_*1&flow=1qbwqgl-1x89vr3");
	}elsif($Gusername=~/hotmail/is){
		if($htmlPage=~/id\W+abook-\import-form-hotmail/is)
		{
			$agent_LI->submit_form(form_id => 'abook-import-form-hotmail',fields => {email=> $Gusername,password=>$Gpassword});
			$htmlPage = $agent_LI->content;
			writeToFile('output/abook-import-form-hotmail.htm',$htmlPage);
		}
#--------------------#
		if($htmlPage=~/genieRedirectUrl\s*:\s*\'(.+?)\'/is)
		{
			my $url='https://www.linkedin.com'.$1;
			if($htmlPage=~/X-FS-Origin-Request\s*\"\s*:\s*\"(.+?)\"/is)
			{
				my $referal='https://www.linkedin.com'.$1;
				$agent_LI->add_header('Referer'=>$referal);
			}
			if($url=~/hotmail/is){
				$agent_LI->get($url);
				$htmlPage=$agent_LI->content;
				writeToFile('output/geniehm_redirect.htm',$htmlPage);
			}
		}
		my $ppft='';
		if($htmlPage=~/name\s*=\s*[\"\']PPFT[\"\']/is)
		{
			if($htmlPage=~/.*(<input.+?name\s*=\s*[\"\']PPFT[\"\'].+?>)/is)
			{
				$ppft=$1;
				if($ppft=~/value\s*=\s*\"(.*?)\"/is)
				{
					$ppft=$1;
				}
			}
		}
		my $url='';
		if($htmlPage=~/urlPost\s*:\s*[\'\"](.+?)[\"\']/is)
		{
			$url=$1;
		}
		if($htmlPage=~/AV\s*:\s*[\"\'](.+?)[\'\"]/is)
		{
			my $referal=$1;
			$agent_LI->add_header(
			'Referer'=>$referal,
			'User-Agent'=>'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)',
			'DNT'=>'1',
			);
		}
		my %formData=();
		$formData{'login'}=$Gusername;
		$formData{'passwd'}=$Gpassword;
		$formData{'PPFT'}=$ppft;
		$formData{'type'}='11';
		$formData{'PPSX'}='Passp';
		$formData{'idsbho'}='1';
		$formData{'sso'}='0';
		$formData{'NewUser'}='1';
		$formData{'LoginOptions'}='3';
		$formData{'i1'}='0';
		$formData{'i2'}='1';
		$formData{'i3'}='68996';
		$formData{'i4'}='0';
		$formData{'i7'}='0';
		$formData{'i12'}='1';
		$formData{'i13'}='0';
		$formData{'i14'}='159';
		$formData{'i17'}='0';
		$formData{'i18'}='__Login_Strings|1,__Login_Core|1,__Login_OTC|1,';
		if($url){
			sleep(2);
			$agent_LI->post($url,\%formData);
			$htmlPage = $agent_LI->content;
			writeToFile('output/addcontacts_verify.htm',$htmlPage);
			sleep(4);
		}
#--------------------#
		
		$agent_LI->get("https://www.linkedin.com/reg/webmail-connect-entry-v2?goback=.fiie_*1_hotmail_*1_*1_*1_*1_*1_*1&origin=hotmail&goback=.fiie_*1_hotmail_*1_*1_*1_*1_*1_*1&flow=1qbwqgl-1x89vr3");
	}
	$htmlPage = $agent_LI->content;
	writeToFile('output/addcontacts.htm',$htmlPage);
	if($htmlPage=~/name\W+aBookConnectForm\W+/is or $htmlPage=~/Stay\s+in\s+touch\s+with\s+your\s+contacts\s+we\s+found\s+when\s+you\s+added\s+your\s+address/is) {
		print "Contacts Addedd Successfuly !! \n";
	}elsif($htmlPage=~/we\s+couldn\'t\s+find\s+any\s+contacts\s+in\s+your\s+address\s+book/is){
		print "Please check your HM acc ! if it has any contact in it.\n";
		exit;
	}else{
		print "Looks Like Daily Limit reached!! please check \n";
		ERROR("----No Contact Addedd !!----");
		exit;
	}
	sleep(5);
}

##--------------------------------------LOGIN--------------------------------#
sub GET_LOGIN
{
	print "LI Login..\n";
	my $url="https://www.linkedin.com/uas/login";
	$agent_LI->get($url);
	sleep(6);
	$agent_LI->submit_form(
        form_name => 'login',
        fields => {
			session_key=> $username,
			session_password => $password,
		}
	);
	$htmlPage = $agent_LI->content;
	writeToFile('output/1.htm',$htmlPage);
	if((!$htmlPage =~ />\s*Sign\s+Out\s*</isg) or ($htmlPage =~ />\s*Security\s+Verification\s*</isg))
	{
		ERROR("---Login-Problem---!");
		die;
	}
	$LI_LogouFile=$htmlPage;
	return 1;
}
##-------------------------------------LOGOUT---------------------------------------#
sub HM_Logout
{
	print "Going to HotMail Logout..\n";
	my $url='';
	if($HM_LogouFile =~/>\s*Sign\s+Out\s*</is)
	{
		$HM_LogouFile=$`;
		if ($HM_LogouFile =~/.*href\W+(.*?)['"]/is) 
		{
			$url=$1;
		}
	}
	if ($url eq '' and $HM_LogouFile ne '') 
	{
		ERROR("---Hotmail Logout-Problem---!");
	}
	$url=~s/\&\#58;/:/isg;
	$url=~s/\&\#63;/?/isg;
	$url=~s/\&\#61;/=/isg;
	$url=~s/\&\#38;/&/isg;
	$url=~s/\&\#37;/%/isg;
	$url=~s/\s//isg;
	$agent_HOT->get($url);
	$htmlPage = $agent_HOT->content;
	writeToFile('output/HMlogout.htm',$htmlPage);
	return 1;
}

sub LI_Logout
{
	print "Going to LI Logout..\n";
	my $url='';
	if($LI_LogouFile=~/>\s*Sign\s+Out\s*</is)
	{
		$LI_LogouFile=$`;
		if ($LI_LogouFile =~/.*href\W+(.*?)['"]/is) 
		{
			$url=$1;
		}
	}
	if ($url eq '') 
	{
		ERROR("---linkdin Logout-Problem---!");
	}
	$url=~s/\&amp;/&/isg;
	$url=~s/\s//isg;
	$agent_LI->get($url);
	$htmlPage = $agent_LI->content;
	writeToFile('output/LIlogout.htm',$htmlPage);
	return 1;
}

sub parseFormData
{
	my ($resultFile,$formData)=@_;
	my $nm;
	while($resultFile=~/<(select|input)/is)
	{
		my $tempFile;
		$resultFile=$';
		$tempFile=$';
		if($1 eq "Input" or $1 eq "input" or $1 eq "INPUT")
		{
			$tempFile=~/(.+?>)/is;
			$tempFile=$1;
			if(!(($tempFile=~/type\W+button/i) or ($tempFile=~/type\W+image/i)))
			{
				if($tempFile=~/\bname\W+(.*?["'])/is){
					$nm=$1;
					$nm=~s/\W\z//i;
					if(!(($tempFile=~/type\W+radio/i) or ($tempFile=~/type\W+checkbox/i)))
					{
						if($tempFile=~/value.*?["'](.*?["'])/i)
						{
							$tempFile=$1;
							$tempFile=~s/\W\z//i;
						}
						elsif($tempFile=~/value\s*=(.+?[\s|>])/i)
						{
							$tempFile=$1;
							$tempFile=~s/\W\z//i;
						}
						else
						{
							$tempFile="";
						}
						if(exists($$formData{$nm}))
						{
							$$formData{$nm}=$$formData{$nm}."&".$nm."=".$tempFile;
						}
						else
						{
							$$formData{$nm}=$tempFile;
						}
					}
					elsif($tempFile=~/type\W+checkbox/i and $tempFile=~/checked/i)
					{
						$$formData{$nm}="1";
					}
					elsif($tempFile=~/type\W+checkbox/i)
					{
						$$formData{$nm}="";
					}
				}
			}
		}
		elsif($1 eq "Select" or $1 eq "select" or $1 eq "SELECT")
		{
			$tempFile=~/(.+?>)/is;
			$tempFile=$1;
			if($tempFile=~/name\W+(.*?["'|>])/is)
			{
				$nm=$1;
				$nm=~s/\W\z//i;
				$resultFile=~/<\/select/is;
				$resultFile=$';
				$tempFile=$`."</select";
				if($tempFile=~/.*(<option.*selected.*?>)/is)
				{
					$tempFile=$1;
					if($tempFile=~/value="(.*?")/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					elsif($tempFile=~/value='(.*?')/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					elsif($tempFile=~/value=(.+?[\s|>])/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					else
					{
						$tempFile="";
					}
				}
				elsif($tempFile=~/(<option.*?>)/is)
				{
					$tempFile=$1;
					if($tempFile=~/value="(.*?")/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					elsif($tempFile=~/value='(.*?')/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					elsif($tempFile=~/value=(.+?[\s|>])/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					else
					{
						$tempFile="";
					}
				}
				else
				{
					$tempFile="";
				}
				$$formData{$nm}=$tempFile;
			}
		}
		$nm = "";
	}
}
#----------------------------------Clear File------------------------------------#
sub clearFile
{
	my ($resultFile)=@_;
	$$resultFile=~s/&nbsp\;//isg;
	$$resultFile=~s/&amp\;/&/isg;
	$$resultFile=~s/\&gt\;//isg;
	$$resultFile=~s/\&quot\;/\%22/isg;
	$$resultFile=~s/<!--.*?-->//isg;
}
###------------WRITETOFILE--------###
sub writeToFile
{
    my ($fileName,$content)=@_;
	open OUT, ">:utf8", $fileName or die "Cannot open $fileName for write :$!";
	print OUT "$content";
	close OUT;
}

sub appendToFile
{
    my ($fileName,$content)=@_;
	open OUT, ">>:utf8", $fileName or die "Cannot open $fileName for write :$!";
	print OUT "$content";
	close OUT;
}

sub readFile
{
	my ($fname)=@_;
	open( HTML, $fname ) || die "Can't open company file: $!";
	my $content;
	while(<HTML>){
		$content.= $_;
	}
	return $content;
}

sub ERROR
{
	my ($content)=@_;
	print "Error::".$content."\n";
	open OUT, ">>:utf8", "error_Log.txt" or die "Cannot open $fileName for write :$!";
	print OUT "$content\n";
	close OUT;
}

sub HEADER
{
	$agent = WWW::Mechanize->new(autocheck => 0);
	$agent->add_header('User-Agent'=>$inputFile{'useragent'});
	if($proxyStatus==1){
		$agent->proxy(['http'], 'http://'.$inputFile{'proxyUser'}.'@'.$ips[$inputNum].'/');
	}
	$agent_HOT=$agent;
	$agent_LI=$agent;
}
#****************************** END OF FILE **********************************#