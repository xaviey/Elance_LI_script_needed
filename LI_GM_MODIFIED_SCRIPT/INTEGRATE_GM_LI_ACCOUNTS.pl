#!/usr/bin/perl
## Version 3.1 Updated on 10-April-2014 by xaviey
## Version 3.2 updated on 14-April-2014 by xaviey
#  Optimized - DELETE_LI
#
#
use Cwd;
use WWW::Mechanize;
my $agent = WWW::Mechanize->new(autocheck => 0);
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
####---INPUT-FILE-------
if(-e $inputFile_Path){
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
my @gmusers=split(',',$inputFile{'gmailusers'});
my $email;
my @usArray=split(":",$liusers[$inputNum]);
my @GusArray=split(":",$gmusers[$inputNum]);
print my $username=$usArray[0];
my $password=$usArray[1];
my $Gusername=$GusArray[0];
my $Gpassword=$GusArray[1];
print "username: $username \npassword: $password \nGusername: $Gusername \nGpassword: $Gpassword \n";
print "------** Started **---------\n";
opendir(DIR, $dirPath) || die "Can't open directory: $!\n";
while (my $filename = readdir(DIR)) {
	if($filename=~/^\./is){next;}
    $filePath= $dirPath."/".$filename;
	if($checkSearch ne ""){
		if($checkSearch =~ /$filename/is){next;}
	}
	print "Going for File -> $filename\n";
	open(FILE,$filePath) or die "Can't read file email id.txt [$!] \n";
	while(<FILE>) {
		my $data = $_;
		$data=~s/\s+//isg;
		$email.="$data,,";
	}close (FILE);
	$email=~s/^,|,$//is;
	# print $email; naren
	%emailHash=();
	@contArray=();
	%contHash=();
	$contArrayDelete=();
	#GMAIL_LOGIN();
	#INTEGRATE_GM_LI_ACCOUNTS();
	#GMAIL_DELETE_CONTACTS();
	#DELETE_LI();
	HEADER();
	GMAIL_DELETE_CONTACTS();
	GMAIL_ADD_CONTACTS();##working
	IMPORT_CONTACTS();##working
	@contArray=();
	GET_DATA();##working
	GMAIL_DELETE_CONTACTS();
	@contArray=();
	%contHash=();
	DELETE_LI();
	my $resume_name="$filename\n";
	appendToFile($resumeFile,$resume_name);
	print "------ Completed proceesing of $filename ---------\n";
}
closedir(DIR);
#unlink($resumeFile);
print "-----Completed-All-files-in-dir-------\n";


sub INTEGRATE_GM_LI_ACCOUNTS
{
	GMAIL_LOGIN();
	GMAIL_ADD_CONTACTS_SAMPLE();
	GET_LOGIN();
	IMPORT_CONTACTS_SAMPLE();
}

sub GMAIL_ADD_CONTACTS
{
	GMAIL_LOGIN();
	print "Going to ADD Contacts in GMAIL Account ....\n";
	print " \n";
	print "********** GMAIL ACCOUNT ************* \n";
	print " \n";
	print "You are using this Login data: \n";
	print "username: $username \npassword: $password \nGusername: $Gusername \nGpassword: $Gpassword \n";
	print "Going to ADD Contacts in GMAIL....\n";
	print " \n";
	print " \n";
	my $url="https://mail.google.com/mail/c/u/0/data/contactstore?ac=true&ct=true&ev=true&gp=false&hl=en&id=personal&max=5&mf=g1&out=js&type=4";
	my $response=$agent->get($url);
	$htmlPage = $agent->content;
	writeToFile('output/AddGM1.htm',$htmlPage);
	my($token,$spcID)=('','');
	if ($htmlPage=~/AuthToken.+\"(.*?)\"/is){
		$token = $1;
	}
	if ($htmlPage=~/\"ak\W+(.*?)\"/is){
		$spcID = $1;
	}
	my %formData;
	$formData{'id'}= 'personal';
	$formData{'op'} =  "id%3Dpersonal%26type%3D12%26mid%3D3d$spcID%26irc%3Dtrue%26cr%3Dtrue%26clid%3DgmailspcNum%26contacts%3D%252C$email%26group%3D6%26sgids%3D27%252C17%252C2a%252C6%252Cd%252Ce%252Cf";
	$formData{'out'} = 'js';
	$formData{'tok'} = $token;
	$formData{'type'} = 3;
	my $url1= "https://mail.google.com/mail/c/u/0/data/contactstore/mutate";
	my $response=$agent->post($url1,\%formData);
	$htmlPage = $agent->content();
	writeToFile('output/AddGM2.htm',$htmlPage);
	if ($htmlPage=~/\W+Success\W+true/is){
		print "Contacts Added Successfully!! \n";
	}
	else
	{
		print "NO (ZERO) Contacts Added into the GMAIL acct - Please check why!! \n";
		print "\n";
	}
	print "htmlPage: $htmlPage \nresponse: $response \n";
}

#############GMAIL##############
sub GMAIL_ADD_CONTACTS_SAMPLE
{
	$emails='nick@test-company.com ,Nick ,Dave@abc-company.com,Dave';
	print "Going to ADD Contacts in GMAIL Account ....\n";
	print " \n";
	print "********** GMAIL ACCOUNT ************* \n";
	print " \n";
	print "You are using this Login data: \n";
	print "username: $username \npassword: $password \nGusername: $Gusername \nGpassword: $Gpassword \n";
	print "Going to ADD Contacts in GMAIL....\n";
	print " \n";
	print " \n";
	my $url="https://mail.google.com/mail/c/u/0/data/contactstore?ac=true&ct=true&ev=true&gp=false&hl=en&id=personal&max=5&mf=g1&out=js&type=4";
	my $response=$agent->get($url);
	$htmlPage = $agent->content;
	writeToFile('output/AddGM1.htm',$htmlPage);
	my($token,$spcID)=('','');
	if ($htmlPage=~/AuthToken.+\"(.*?)\"/is){
		$token = $1;
	}
	if ($htmlPage=~/\"ak\W+(.*?)\"/is){
		$spcID = $1;
	}
	my %formData;
	$formData{'id'}= 'personal';
	$formData{'op'} =  "id%3Dpersonal%26type%3D12%26mid%3D3d$spcID%26irc%3Dtrue%26cr%3Dtrue%26clid%3DgmailspcNum%26contacts%3D%252C$emails%26group%3D6%26sgids%3D27%252C17%252C2a%252C6%252Cd%252Ce%252Cf";
	$formData{'out'} = 'js';
	$formData{'tok'} = $token;
	$formData{'type'} = 3;
	my $url1= "https://mail.google.com/mail/c/u/0/data/contactstore/mutate";
	my $response=$agent->post($url1,\%formData);
	$htmlPage = $agent->content();
	writeToFile('output/AddGM2.htm',$htmlPage);
	if ($htmlPage=~/\W+Success\W+true/is){
		print "Contacts Added Successfully!! \n";
	}
	else
	{
		print "NO (ZERO) Contacts Added into the GMAIL acct - Please check why!! \n";
		print "\n";
	}
	print "htmlPage: $htmlPage \nresponse: $response \n";
}

sub IMPORT_CONTACTS_SAMPLE
{
	print "Entered IMPORT_CONTACTS_SAMPLE \n";
	GET_LOGIN();
	print "Going to Add EM's \n";
	$agent->get("https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections");
	$htmlPage = $agent->content;
	writeToFile('output/1.htm',$htmlPage);
	$agent->add_header('Referer'=>'https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections');
	if($Gusername=~/gmail/is){
		$agent->submit_form(form_id => 'abook-import-form-gmail',fields => {email=> $Gusername,password=>$Gpassword});
		$agent->get("http://www.linkedin.com/reg/webmail-connect-entry-v2?goback=%2Efiie_*1_gmail_*1_*1_*1_*1_*1_*1&origin=gmail&goback=.fiie_*1_gmail_*1_*1_*1_*1_*1_*1&flow=1qbwqgl-1x89vr3");
	}elsif($Gusername=~/yahoo/is){
		$agent->submit_form(form_id => 'abook-import-form-yahooSocial',fields => {email=> $Gusername,password=>$Gpassword});
		$agent->get("http://www.linkedin.com/reg/webmail-connect-entry-v2?goback=%2Efiie_*1_yahooSocial_*1_*1_*1_*1_*1_*1&origin=yahooSocial&goback=.fiie_*1_yahooSocial_*1_*1_*1_*1_*1_*1&flow=1qbwqgl-1x89vr3");
	}
	$htmlPage = $agent->content;
	writeToFile('output/addcontacts.htm',$htmlPage);
	if($htmlPage=~/name\W+aBookConnectForm\W+/is) {
		print "Contacts Addedd Successfuly !! \n";
	} else {
		print "No Contact Addedd !! \n";
		ERROR("----No Contact Addedd !!----");
	}
}


sub GMAIL_LOGIN
{
	HEADER();
	print "Going To Login on GMAIL....\n";
	my $url="https://www.gmail.com";
	$agent->get($url);
	$agent->submit_form(form_id => 'gaia_loginform',  fields => {Email=> $Gusername,  Passwd => $Gpassword});
	$htmlPage = $agent->content;
	writeToFile('output/Glogin.htm',$htmlPage);
	return 1;
}

sub GMAIL_DELETE_CONTACTS
{
	GMAIL_LOGIN();
	print "Going to Delete Contacts!!...\n";
	my $deleteID='';
	my $spcNum = int rand(1000000);
	$url="https://mail.google.com/mail/c/u/0/data/contactstore?ac=true&ct=true&ev=true&gp=false&hl=en&id=personal&max=5000&mf=g1&out=js&type=4";
	my $response=$agent->get($url);
	$htmlPage = $agent->content;
	writeToFile('output/DELGM-contacts1.htm',$htmlPage);
	my @tempArray = $htmlPage=~/\"(\w{10,16})\\\"/isg;
	foreach my $x (@tempArray){$contHash{$x}=1;}
	my @contactID = keys(%contHash);
	print "Total Contacts -> ". $#contactID;
	print "\n";
	$deleteID = join('%2522%255D%252C%255Bnull%252C%2522',@contactID);
	my($token,$spcID)=('','');
	if ($htmlPage=~/AuthToken.+\"(.*?)\"/is){
		$token = $1;
	}
	if ($htmlPage=~/\"ak\W+(.*?)\"/is){
		$spcID = $1;
	}
	my %formData=();
	$formData{'id'} = "personal";
	$formData{'op'} =  "id%3Dpersonal%26type%3D6%26mid%3D$spcID%26irc%3Dtrue%26cr%3Dtrue%26clid%3Dgmail$spcNum%26ckeysd%3D%255Bnull%252C%255B%255Bnull%252C%2522$deleteID%2522%255D%255D%255D%26sgids%3D27%252C17%252C2a%252C6%252Cd%252Ce%252Cf";
	$formData{'tok'} = $token;
	$formData{'type'} = 3;
	my $url1= "https://mail.google.com/mail/c/u/0/data/contactstore/mutate";
	my $response=$agent->post($url1,\%formData);
	$htmlPage = $agent->content();
	writeToFile('output/DELGM-contacts3.htm',$htmlPage);
	if ($htmlPage=~/\W+Success\W+true/is){
		print "All Contacts Deleted Successfully!!\n";
	}
}

sub GET_DATA
{
	GET_LOGIN();
	$agent->get("https://www.linkedin.com/profile/edit?trk=nav_responsive_sub_nav_edit_profile");
		$htmlPage = $agent->content;
		writeToFile('output/1EditProfile.htm',$htmlPage);
	$agent->get("https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections");
	$htmlPage = $agent->content;
		writeToFile('output/2contactslist.htm',$htmlPage);
	$agent->get("http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts");
	$htmlPage = $agent->content;
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
	$agent->add_header(
		'Referer'=>'http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts',
		'X-IsAJAXForm'=>'1',
		'X-Requested-With'=>'XMLHttpRequest',
	);
	$agent->post($postUrl,\%formData);
	$htmlPage = $agent->content;
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
		$agent->add_header(
			'Referer'=>'http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts',
			'X-IsAJAXForm'=>'1',
			'X-Requested-With'=>'XMLHttpRequest',
		);
		$agent->post($postUrl,\%formData);
		$htmlPage = $agent->content;
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
		}
		print "Records -> ".$#contArray."\n";
		print "Now sleeping for 25 secs\n";
		sleep(25); ## sleep for 25 seconds and then get all records, at every alphabet. (was 5 secs)
	}
}

sub DELETE_LI
{
	sleep(120);
	HEADER();
	GET_LOGIN();
	print "sleeping for 10 secs now\n";
	sleep(10);
	$agent->get("http://www.linkedin.com/connections?type=combined&trk=nav_responsive_sub_nav_network");
	$htmlPage =$agent->content;
	writeToFile('output/rand1.htm',$htmlPage);
	sleep(4);
	$agent->get("http://www.linkedin.com/company/home?trk=nav_responsive_sub_nav_companies");
	$htmlPage = $agent->content;
	writeToFile('output/rand2.htm',$htmlPage);
	sleep(3);
	$agent->get("https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections");
	$htmlPage = $agent->content;
	writeToFile('output/2.htm',$htmlPage);
	sleep(2);
	$agent->get("http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts");
	$htmlPage = $agent->content;
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
	$agent->add_header(
		'Referer'=>'http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts',
		'X-IsAJAXForm'=>'1',
		'X-Requested-With'=>'XMLHttpRequest',
	);
	$agent->post($postUrl,\%formData);
	$htmlPage =$agent->content;
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
		$agent->add_header(
			'Referer'=>'http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts',
			'X-IsAJAXForm'=>'1',
			'X-Requested-With'=>'XMLHttpRequest',
		);
		$agent->post($postUrl,\%formData);
		$htmlPage = $agent->content;
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
	sleep(60);
	HEADER();
	GET_LOGIN();
	print "sleeping for 5 secs now\n";
	sleep(5);
	$agent->get("https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections");
	$htmlPage = $agent->content;
	writeToFile('output/6.htm',$htmlPage);
	print "Going to Delete Contacts from LinkedIn...\n";
	my $url="http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts";
	$agent->add_header();
	$agent->get($url);
	$htmlPage = $agent->content;
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
	$agent->post('https://www.linkedin.com/people/submit-contact',$formData);
	$htmlPage2 = $agent->content;
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
	print "Going to Add EM's \n";
	$agent->get("https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections");
	$htmlPage = $agent->content;
	writeToFile('output/1.htm',$htmlPage);
	$agent->add_header('Referer'=>'https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections');
	if($Gusername=~/gmail/is){
		$agent->submit_form(form_id => 'abook-import-form-gmail',fields => {email=> $Gusername,password=>$Gpassword});
		$agent->get("http://www.linkedin.com/reg/webmail-connect-entry-v2?goback=%2Efiie_*1_gmail_*1_*1_*1_*1_*1_*1&origin=gmail&goback=.fiie_*1_gmail_*1_*1_*1_*1_*1_*1&flow=1qbwqgl-1x89vr3");
	}elsif($Gusername=~/yahoo/is){
		$agent->submit_form(form_id => 'abook-import-form-yahooSocial',fields => {email=> $Gusername,password=>$Gpassword});
		$agent->get("http://www.linkedin.com/reg/webmail-connect-entry-v2?goback=%2Efiie_*1_yahooSocial_*1_*1_*1_*1_*1_*1&origin=yahooSocial&goback=.fiie_*1_yahooSocial_*1_*1_*1_*1_*1_*1&flow=1qbwqgl-1x89vr3");
	}
	$htmlPage = $agent->content;
	writeToFile('output/addcontacts.htm',$htmlPage);
	if($htmlPage=~/name\W+aBookConnectForm\W+/is) {
		print "Contacts Addedd Successfuly !! \n";
	} else {
		print "No Contact Addedd !! \n";
		ERROR("----No Contact Addedd !!----");
	}
}


##-------------LOGIN--------------#
sub GET_LOGIN
{
	print "Going to Login..\n";
	HEADER();
	my $url="https://www.linkedin.com/uas/login";
	$agent->get($url);
	$agent->submit_form(
        form_name => 'login',
        fields => {
			session_key=> $username,
			session_password => $password,
		}
	);
	$htmlPage = $agent->content;
	writeToFile('output/1.htm',$htmlPage);
	if(!$htmlPage =~ />\s*Sign\s+Out\s*</isg)
	{
		ERROR("---Login-Problem---!");
		die;
	}
	return 1;
}

sub CHECK_CONTACTS
{
	GET_LOGIN();
	sleep(4);
	$agent->get("http://www.linkedin.com/connections?type=combined&trk=nav_responsive_sub_nav_network");
	$htmlPage = $agent->content;
	writeToFile('output/rand11.htm',$htmlPage);
	sleep(3);
	$agent->get("http://www.linkedin.com/company/home?trk=nav_responsive_sub_nav_companies");
	$htmlPage = $agent->content;
	writeToFile('output/rand12.htm',$htmlPage);
	sleep(3);
	$agent->get("https://www.linkedin.com/fetch/importAndInviteEntry?trk=nav_responsive_sub_nav_add_connections");
	$htmlPage = $agent->content;
	writeToFile('output/9.htm',$htmlPage);
	sleep(4);
	$agent->get("http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts");
	$htmlPage = $agent->content;
	writeToFile('output/10.htm',$htmlPage);
	print "Going to Get Contacts List and Saving it...\n";
	%formData=();
	$postUrl="http://www.linkedin.com/people/directoryContactsBrowse";
	$formData{'initial'}='DONT_CARE';
	$formData{'invited'}='true';
	$formData{'batchId'}='0';
	$formData{'membersOnly'}='false';
	$formData{'meta'}='false';
	$formData{'threshold'}='500';
	$agent->add_header(
		'Referer'=>'http://www.linkedin.com/people/contacts?sortAction=lastName&showInvited=true&membersOnly=false&trk=ac-manage-contacts',
		'X-IsAJAXForm'=>'1',
		'X-Requested-With'=>'XMLHttpRequest',
	);
	sleep(2);
	$agent->post($postUrl,\%formData);
	$htmlPage = $agent->content;
	writeToFile('output/11.htm',$htmlPage);
	my $flag=0;
	while($htmlPage =~ /hasNonSummaryData\W+(.*?)(\"\s*\}\s*,\s*\{|\}\s*\])/is)
	{
		$flag=1;
		$htmlPage=$';
		$tempPage=$1;
		$contactid="";
		if($tempPage =~ /\"contactID\W+(.*?)\\[\'\"]/is){
			$contactid=$1;
			push (@contArrayDelete,$contactid);
		}
	}
	if($flag==1){
		sleep(5); ## 5 sec sleep to switch on delete records.
		CHECK_AND_DELETE();
	}
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

#------------WRITETOFILE--------
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
}