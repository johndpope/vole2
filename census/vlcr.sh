#!/bin/sh

# This script requires that the user be in the admin group to send a log report

# A script to generate Vienna and system log information, and send it
# to the conference moderator
# Author: devans
# Created 2011-03-02

scriptversion=1.9

# use Apple version of the utilities. Avoid Macports,Fink or Darwinports
PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Note: I don't know how long bzip2 has been available on OS X
# therefore gzip is used to compress the log.
# send results to TO
TO='dave.evans55@googlemail.com'
# temporary file for reports
T="/tmp/vlcr.${USER}.report.temporary.txt"
# display reportsint he browser  using this file
HTMLREPORT="/tmp/vlcr.${USER}.report.html"
# where to put the full documentation
FULLDOC="/tmp/vlcr.${USER}.fulldoc.html"
# where to put the quick start documentation
QSGDOC="/tmp/vlcr.${USER}.qsgdoc.html"
# where to puts the bugs document
BUGSDOC="/tmp/vlcr.${USER}.bugs.html"
# location for the Vienna installations report
VINSTALL="/tmp/vlcr.${USER}.vienna.html"
# where the crash reporter files live
CR=~/Library/Logs/CrashReporter

# all apps need application support
appsupportdir='/Library/Application Support/Vienna Reporter'
Cookiefile="${appsupportdir}/ViennaReporter.cookie.txt"
# if this file exists, cookies are disabled
cookiedisable="${appsupportdir}/cookie-disable"
# Where we stash the users nickname
cixnicknamefile="${appsupportdir}/cixnickname.txt"

# 0 if nickname not set 
nickset=0
nick=not_set_yet

# where the system logs live
L=/var/log/system.log

# all functions go before the main part of the script

######### get_nickname function ##########
function get_nickname(){
if [ -f "${cixnicknamefile}" ]
then
nick=$(cat "${cixnicknamefile}")
nickset=1
fi
}
########## end of get_nickname function ######

############### nickname setting function #######
function cix_nick() {
printf 'Your nickname is currently set to \"%s\"\n' "${nick}"
read -p "Please enter your Cix nickname or anon: " nick
if [ "X${nick}" = X ]
then
nick=notknown
fi
if [ $Admin -eq 0 ]
then
echo "${nick}" > "${cixnicknamefile}"
printf 'You are an administrator. Your nickname has been saved as \"%s\"' \
	"${nick}"
else
printf 'You are an unpriveleged user. Your nickname has been set\n'
printf 'for the current session only. To save it permanently, login\n'
printf 'as an administrator. Your nickname is \"%s\"\n' "${nick}"
echo 
fi
nickset=1
}
############### end of nickanme setting #########

############### html_entities function ##########
# see HTML spec 4.01
function html_entities(){
sed -e '
s/&/\&amp;/g
s/</\&lt;/g
s/>/\&gt;/g
s/"/\&quot;/g
'
}
############## end of html_entities function #######

############## find_vienna function ############

# search the output of system_profiler for instances of Vienna
function find_vienna() {
awk  'BEGIN { o = 0 ; count=0 }
/^    [0-9A-Za-z]/ { o=0 }
/^    Vienna:/ { o=1; print; count++ }
/^      / { if (o==1) print }
END { printf( "\nVienna installations detected: %d\n", count) }
'
}
########### end of find_vienna ###############

########### begin w3c_boilerplate ############
function w3c_boilerplate() {
# This goes at the head of each html page. It keeps the validator happy.
cat << "W3C_END"
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
            "http://www.w3.org/TR/html4/strict.dtd">
<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" >
W3C_END
}
############## end of w3c_boilerplate ################################

############### begin standard_header function ########
function standard_header() {
# this header goes at the beginning of reports and emails

echo Cix user nickname: $nick 
echo Local user name: $USER 
echo Admin user: $AdminText
echo Vienna version from user: $vers 
echo Report type: ${REPORT_TYPE} 
echo Script run on: ${datenow} 
echo Script version: $scriptversion 
echo Local time: `date`
echo Report ID: ${reportid} 
echo Cookie: ${Cookie} 
echo Fossil manifest SHA1: ${manifest} 
if  which -s openssl 
then 
echo Script SHA1: `openssl sha1 "$0" | sed -e 's/.*= //'` 
else
echo Script SHA1: no openssl 
fi
if  which -s md5 
then
echo Script MD5: `md5 "$0" | sed -e 's/.*= //'`
else
echo Script MD5: no md5
fi 
echo Bash version: ${BASH_VERSION}
echo 
}
########## end of standard header function ###########

########## beginning of set_variables function ######
function set_variables () {

reportid=`uuidgen`
datenow=`TZ=UTC date +%Y-%m-%dT%H:%M:%SZ`
G="grep -i Vienna"
H=${reportid}.${datenow}

# Check for cookies and set if required

if [ ! -d "${appsupportdir}" ]
then
mkdir -p "${appsupportdir}"
fi
if [ -f "${Cookiefile}" ]
    then 
	Cookie=`tail -1 "${Cookiefile}"`
    else
     # give the user a cookie - Yum Yum
	echo Hello new user
	if  which -s uuidgen
        then
	 echo 'Please do not delete or modify this file.' > "${Cookiefile}"
	 echo 'It is used by the Vienna Reporter' >> \
		"${Cookiefile}"
	 echo 'to anonymously identify your Mac.' >> "${Cookiefile}"
	 echo 'Please read the man page for uuidgen.' >> "${Cookiefile}"
	 Cookie=`uuidgen`
	 echo ${Cookie} >> "${Cookiefile}"
       fi
    fi
# ask the user for nickname if never set
if [ ${nickset} -eq 0 ] ; then cix_nick ; fi
}
#################
################ begin reporter function ##################
function reporter () {
set_variables
standard_header > $T
echo '=== Begin uname ===' >> $T
uname -a >> $T
echo '=== End uname ===' >> $T
echo >> $T
echo === Begin Mac OS X version === >> $T
sw_vers >> $T
echo === End Mac OS X version === >> $T
echo >> $T

echo === Begin Vienna installed versions === >> $T
echo "${vienna_full}" >> $T
echo === End Vienna installed versions === >> $T
echo >> $T

echo === Begin xcodebuild === >> $T
[ -x /usr/bin/xcodebuild ] && xcodebuild -version >> $T
[ -x /usr/bin/xcode-select ]  && xcode-select -print-path >> $T
echo === End xcodebuild === >> $T

echo >> $T

echo === Begin developer tools === >> $T
if [ -x /usr/sbin/system_profiler ]
then
system_profiler SPDeveloperToolsDataType >> $T
else
echo No system_profiler, shame >> $T
fi
echo === End developer tools === >> $T

echo >> $T
if [ "X${REPORT_TYPE}" = XLog ]
then
echo '=== Begin system log files count ===' >> $T
GFC=`ls  ${L}.[0-9]*.gz 2>/dev/null | wc -l`
echo System log gzip files: ${GFC} | tee -a $T
BFC=`ls ${L}.[0-9]*.bz2 2>/dev/null | wc -l`
echo System log bzip files: ${BFC} | tee -a $T
echo === End system log files count === >> $T

echo >> $T
echo '=== Begin system log for Vienna ===' >> $T
[ $GFC -gt 0 ] && \
gzcat ${L}.[0-9]*.gz |  $G  >> $T

[ $BFC -gt 0 ] && which -s bzcat && \
bzcat ${L}.[0-9]*.bz2  |  $G >> $T

[ -f ${L} ] && cat ${L} | $G >> $T
echo '=== End system log for Vienna ===' >> $T
fi  # end of if for report type log

if [ "X${REPORT_TYPE}" = XCrash ]
then
echo '=== Begin crash reporter filelist for Vienna ===' >> $T
FC=`ls ${CR}/Vienna_* 2>/dev/null | wc -l`
echo crash report files ${FC}
[ ${FC} -gt 0 ] && \
ls -lT ${CR}/Vienna_* >> $T
echo '=== End crash reporter filelist for Vienna ===' >> $T
fi

echo >> $T
echo '=*= End of report =*=' >> $T
echo 
read -p "Is it OK to send the report [Y/n] ? : " ok
if [ "X${ok}" = Xn ] || [ "X${ok}" = XN ] 
then
echo Thanks for your participation. Your report has not been sent.
echo You can find the text of the report that would have been 
echo sent in the file "${T}". 
echo You can view this report using the T menu option.
echo
return 0
fi

# use gzip because bzip2 may not be available
cat $T | gzip  -c9| uuencode ${H}.vnr.gz | pbcopy -Prefer txt
 
echo
echo Your email app will now be opened with the To: and Subject:
echo fields already filled in. Please remember to paste your clipboard
echo into the message body and then send the message. Please do not
echo alter the message header or body in any way.
echo
echo There will now be a brief pause while you read this message  ...
sleep 10
logger "Vienna Reporter script version ${scriptversion} sending report ${H}\
 for type ${REPORT_TYPE}"
echo Starting email app.
hint=$(echo Paste your clipboard below this line. | mailto_url_encode)
open "mailto:${TO}?subject=Vienna%20vlcr%20${H}&body=${hint}"
} 
################ end of reporter function ####################

############ begin mailto helper function ####################
# protect spaces and newlines for the mailto facility 
# See RFC 2368
function mailto_url_encode () {
	awk  ' { gsub(/ /, "%20"); printf("%s%%0d%%0a",$0);}'
	}
############ end mailto helper function ##############

############ begin quick start guide #############
function quick_start() {
quick_start_gen "${QSGDOC}"
if [ $? -eq 0 ]
then
open "${QSGDOC}"
fi
}
############# end quick start guide function ##########

############# begin quick_start_gen function  ########
function quick_start_gen(){
cat > "${1}"<< QUICK_START
$(w3c_boilerplate)
<!-- Full documentation for Vienna crash reporter is now
stored in the script -->
<title>Vienna census,log and crash reporter quick start guide</title>
</head>
<body>
<pre>
This is for the impatient and those experienced with the command line.
All others should view the full documentation first.

1. Unzip the zip file.
2. Open Terminal
3. Run the script with "sh vlcr.sh"
4. A menu appears. It looks like this:

$(get_menu)

Census collects basic information about your mac
Log Reporter collects the system log files relating to Vienna.
      It should be run from an administrator account.
Crash Reporter collects the crash reports relating to Vienna.
      It should be run from the account where you run Vienna.
View full or quick documentation displays the documentation
      relating to the current version of vlcr.sh.
Change or set your Cix nickname does what it says.
View last report lets you see what's in the reports.
Send me email if you want. It invokes your default email client
      such as Apple Mail or Thunderbird.
Quit does the obvious thing.

That's about it really. Have fun. I like reports, stats and logs.
</pre>
</body>
QUICK_START
if [ $? -ne 0 ] 
then
echo an error has occured in generating the documentation file
exit 1
fi
}
############## end qucik_start_gen function ########

############# begin full_docs_gen function ##############

function full_docs_gen () {
# one argument, the name of the file to generate

menu=`get_menu`
[ -n "${1}" ] || exit 1
cat > "${1}" << END_OF_FULL_DOC_zhqa
$(w3c_boilerplate)
<title>The Vienna census - how to participate</title>
</head>
<body>
<pre>
It's census time here in the Vienna conference.  This is
the one you cannot afford to miss! Your  participation
will be most welcome and it will help the Vienna developers
in the future development of Vienna.

What's being collected?  - see below

How to participate.
------------------
Download cixfile:vienna/files:census.zip
(It's tiny, < 5k)

Open Vienna and navigate to Vienna -> About Vienna
Make a note of Vienna version information, N.N.NN (NNNN)

Create an empty folder in your home folder and name it
"census". Unzip the zip file into it.

If you have any work that you have copied to the clipboard,
please save it now.

Open /Applications/Utilities/Terminal

Yes, I know it is the command line. I'm very sorry
for those of you who are averse to the command line, but
this is the simplest way for me to implement a simple
survey.

In Terminal window type:

      cd census
      sh census.sh

The screen will clear and a menu will be displayed like this:

${menu}

You will be asked if you wish to view the documentation in
your browser. Answer Y or N.

A prompt will appear. Please answer the question
with your Cix nickname.

Another prompt will appear. Please answer the question
with the Vienna version information or "none" if you do
not have Vienna..

You will be asked if you wish to send the census data.
Answer Y (default) or N

When you have done that, your default email program
will open with the To: and Subject: fields already
filled in. 

We are almost done. A tiny program has copied the
census data to your clipboard. 

Now for the important step!

=== Paste the clipboard into the message window. ===

Take care not to disturb the census data.

Now send the message.

That's it. Job done. Simples. Thanks for your participation.
It will help us in the future development of Vienna.
----

Problems
--------
When pasting the clipboard into Thunderbird, it sometimes comes up with
a message "Found an attachment keyword XX". It is trying to be too
clever. Close the yellow window by clicking on the litte X icon
on the right and send the message as usual.

For the security conscious.
---------------------------

Q: What information is being gathered?

A:
Most of this information is gathered by the script automatically.
Basic information about your Mac.
Your Vienna version.
Whether you have the development system installed and which
version.
Your Mac's hostname.
Your cix nickname and login name on your Mac.
System log messages that relate to Vienna.
A list of Crash Reporter files that relate to Vienna. We don't collect
the files at the moment..

Q: How do I find out what is being sent?

A:
Read the file temporary-file in the census directory.
Review the script vlcr.sh.sh.

Q: What programs are used to create the census.

A: census.sh - a small Bash shell script available for review by anyone.
Standard system utilities such as gzip bzcat pbcopy grep uuencode
hostname uname uuidgen and (if it exists) xcodebuild.
Your default email application.

Q: Why is the census data sent in BASE64 or UUencoded form?

A: To prevent long lines from getting mangled. The data are also
compressed.

Q: Why are the system log messages relating to Vienna being gathered?

A: I want to see whether you get the same messages that I get, or
any that I have not seen before.
---

Privacy Policy
--------------
Your personal data (email address, login name, cix nickname, hostname)
will not be shared with anyone.

You do not have to give your cix nickname to participate but I would
much prefer that you do give it.

The script will install a small cookie in 
"${Cookiefile}"
It contains a UUID. Please see http://en.wikipedia.org/wiki/UUID
Please do not delete this file. It is used to identify your Mac
anonymously in the event you send more than one report. It will
also be used in a forthcoming crash reporter.

</pre>
</body>
END_OF_FULL_DOC_zhqa
if [ $? -ne 0 ] 
then
echo an error has occured in generating the documentation file
exit 1
fi
}
############ end of full_docs_generate function ##############

########## begin full_docs function ###########

function full_docs(){
full_docs_gen "${FULLDOC}"

open "${FULLDOC}"
}
######### end of full_docs function ##########

######### begin bugs_doc_gen function ##########
function bugs_doc_gen(){
# generate the bugs document - 1 argument, the name of the file 
[ -n "${1}" || exit 1
cat > "${1}" << BUGS_DOC_jejsk
$(w3c_boilerplate)
<title>Known bugs and issues</title>
</head>
<body>
<pre>
Thunderbird email client
------------------------
When  pasting the report into Thunderbird's message window, it sometimes
pops up an Alert panel  in yellow at the bottom of the window with
a message &quot;Attachment detected&quot;. Dismiss the panel by clicking
on the little X button on the right hand side. It does not seem to affect
anything.

Bash version 4
--------------

When using Bash version 4 as the shell, when sending an email with the
M option, the pre-composed header at the top of the message body window
is completely garbled.

As OS X sh command is currently version 3, this is not a problem
 at the moment.

</pre>
</body>
BUGS_DOC_jejsk
if [ $? -ne 0 ]
then
echo An error has occurred. "${1}" not generated
exit 1
fi
}
######### end bugs_doc_gen function ############
########### start of send_email function ############

function send_email () {
set_variables
cat << END_OF_EMAIL
Your email application will open in a new window
with the To: and Subject: headers filled in.
Feel free to change the Subject:, leaving the word
Vienna in there somewhere.

A short block of text will be placed at the beginning of the message.
Please compose your message below the last line of this block.

END_OF_EMAIL

read -p "Press enter to continue : " junk
tm=$(printf "%s\n\n%s%s%s" \
      "$(standard_header)" \
      "Thanks from the Vienna developers for your feedback.\n" \
      "Please add something meaningful to the subject.\n" \
      "Please compose your message below this line.\n" )
mailbody=$(echo "${tm}" | mailto_url_encode )
open "mailto:${TO}?body=${mailbody}&subject=Vienna%20user"

}
########### end of send_email function #############

########## start of vienna_installations_in_browser ###########
function vienna_installations_in_browser() {
cat > "${VINSTALL}" << END_OF_VINSTALL
$(w3c_boilerplate)
<title>Vienna Installations</title>
<!-- this report is generated by vlcr.sh -->
<!-- $(date) -->
</head>
<body>
<pre>
$(echo "${vienna_full}" | html_entities) 
</pre>
</body>
END_OF_VINSTALL
open "${VINSTALL}"
}
############ end of vienna_installations_in_browser

########### start of vienna_installations function #########
function vienna_installations() {
echo "${vienna_full}"
read -p "Do you wish to read this report in your browser? [yN]: " junk
case ${junk} in
	[Yy] ) vienna_installations_in_browser ;;
	esac
return
}
########### end of vienna_installations function ############

########### begin get_menu function #############
function get_menu() {

cat << END_OF_MENU

  S         Census Reporter
  L         Log Reporter ( Administrators only )
  C         Crash Reporter ( Login to the account where you use Vienna )
  F         View full documentation in your browser
  Z         View quick start guide in your browser
  N         Change or set your Cix nickname
  T         View the last report generated in your browser
  M         Send email to the maintainer of this program
  V         Show Vienna installations on your Mac
  Q         Quit this program

END_OF_MENU


}
########### end of get_menu #####################




############## start of menu function #############
function menu () {

get_menu

read -p "Please make your choice [SLCFZNTVMQ] ? : " choice

    case "${choice}" in
	 [Ss] )  REPORT_TYPE=Census ; reporter ;;
	 [Ll] )  REPORT_TYPE=Log ;
		if [ $Admin -ne 0 ]
		 then
		  echo '********* Login as Administrator please! **********'
		  read -p "Press Enter to continue : " junk
		 else
		  reporter 
		 fi;;
	 [Cc] )  REPORT_TYPE=Crash ; reporter;;
	 [Ff] )  full_docs ;;
	 [Zz] )  quick_start "${QSGDOC}" ;;
	 [Nn] )  cix_nick ;;
         [Tt] )  view_report_in_browser ;;
         [Mm] )  REPORT_TYPE='User' ;   send_email ;;
	 [Vv] )  vienna_installations ;;
	 [Qq] )  exit 0;;
     esac 

}  ######### end of menu function ###########

########### begin view_in_textedit function ###########

# this is not used any more as we now use the browser
function view_in_textedit () {
if [ -f "${T}" ]
then
# Pipe the file into the editor, because textedit may not realise the file
# has changed.
cat "${T}" | open -f 
else
echo
echo You have not generated any reports yet!
echo
fi
return 0

}
############ end of view_in_textedit function ###########

############ begin view_report_in_browser function #######
function view_report_in_browser(){
if [ ! -f "${T}" ]
   then
     echo;     echo "You have not yet generated any reports!" ;echo
     return
    fi
cat > "${HTMLREPORT}"<< EOF_HTML_REPORT
$(w3c_boilerplate)
<title>Last report generated</title>
<!-- this report generated by vlcr.sh version ${scriptversion} -->
<!-- $(date) -->
</head>
<body>
<pre>
*** This page generated by vlcr.sh 
*** version ${scriptversion} on $(date)

$(cat "${T}" | html_entities)
</pre>
</body>

EOF_HTML_REPORT
open "${HTMLREPORT}"
return 0
}
############ end view_report_in_browser function #########

########## begin givehelp function ##############

function givehelp() {
cat << end_of_givehelp_x201

Usage:   sh vlcr.sh option

where option is:

help    - displays this help
version - shows version information
docgen  - generate documentation in the current directory

If option is not supplied vlcr will enter its menu-driven mode
end_of_givehelp_x201
}
############ end of givehelp function #########
############ begin process_arguments function  ############
function process_arguments() {
case "$1" in 
	version ) echo Version ${scriptversion} ;;
	docgen ) generate_local_docs ;;
	* ) givehelp ;;
	esac
return 0
}
############# end process_arguments function #############

############## begin generate_local_docs function #######
function generate_local_docs(){
quick_start_gen  quick_start.html
full_docs_gen    manual.html
bugs_doc_gen     bugs.html
}
############## end generate_local_docs function #########


############# start of main script ###########
# all functions must precede this #

if [ -n "${1}" ]
then 
# user has supplied at least one argument to the script
process_arguments $1 
exit 0
fi


# get the Fossil manifest
manifest='Not found, no worries, it does not matter'
if [ -f manifest.uuid ]
then
manifest=`cat manifest.uuid`
fi
# find out if the user is an admin
id | grep '(admin)'
Admin=$?
case $Admin in 
	0 ) AdminText=yes ;; 
        1 ) AdminText=no  ;;
	2 ) AdminText='error occurred' ;;
	esac
clear
echo
echo
echo "Vienna Reporter version ${scriptversion}"  
echo 



if ! which -s uuidgen
then
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "An error has occurred. Your Mac does not have uuidgen."
echo "It has been available since OS X 10.2 so something is amiss."
echo "Please report this error to the vienna/chatter topic."
echo "You are welcome to browse the documentation, but expect to"
echo "see error messages mesages if you use the reports or email options."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo 
read -p "press return to acknowledge this message : " junk
fi

echo 'Please wait while we find Vienna on your Mac ...'
vienna_full=$( system_profiler SPApplicationsDataType | find_vienna )
echo "${vienna_full}" | grep 'Version:\|detected'
echo 'Use the V menu option to display the full Vienna installation report.'
echo 'Done'
echo
get_nickname
if [ $nickset -eq 1 ]
then
printf 'Your cix nickname is currently \"%s\"' "${nick}"
fi


while true; do menu ;done
