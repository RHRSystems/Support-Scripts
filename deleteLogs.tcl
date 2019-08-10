#!/bin/csh
# Using csh to force env variables to be set
#
# Author:  Randy Raskin
# Purpose: Clean out dump files and logs older than 2 days
#
#

# \
cd `dirname $0`

# next line restarts as tclsh \
exec tclsh `basename $0` $*

###############################################################################
# Global Variables
###############################################################################

set logLevel   1

set errormsg   ""
set EMAIL_LIST "me@me.com"
set Ctr        0
set Ctr2       0
set Ctr3       0
set today      "[clock format [clock seconds] -format "%Y%m%d"]"
set cleanDir   /sybdump/trandump
set cleanDir2  "$env(A_CUSTOMPROCS)"
set cleanDir3  "$env(A_GENERICPROCS)"
set clientList "F_CLIENT1 F_CLIENT2 F_CLIENT3 F_CLIENT4"

###############################################################################
#                                                                             #
#  Proc:      cleanDIR                                                        #
#  Purpose:   Generates an archive of reports                                 #
#                                                                             #
###############################################################################

proc cleanDIR { } {

global today
global Ctr
global Ctr2
global Ctr3
global today
global cleanDir
global cleanDir2
global cleanDir3
global clientList

LogTrace 1 "Entering $cleanDir"

#                            #
# ----- First Directory -----#
#                            #

cd $cleanDir

foreach logFile [glob -nocomplain -- F_*] {

    set split [split $logFile .]
    set d [lindex $split 2]
    set e [string range $d 0 7]
    set diff [expr $today - $e]

    if { $diff > 0 } {

       incr Ctr

       LogTrace 0 "File is more than 1 day old, removing --> $logFile"
       file delete -force $logFile
    }
}

LogTrace 1 "Leaving $cleanDir Total Removed - $Ctr"
LogTrace 1 ""
LogTrace 1 "Entering $cleanDir2"
LogTrace 1 ""

#                             #
# ----- Second Directory -----#
#                             #

cd $cleanDir2

foreach client [lsort $clientList] {

  set globTarget [file join $cleanDir2 $client *]

  foreach sourceFile [glob -nocomplain $globTarget] {

    if { [file mtime $sourceFile] > 172800 } {

       incr Ctr2

       set delFile2 [file tail $sourceFile]

       LogTrace 0 "= File is more than 2 days old, removing --> $delFile2"

       file delete -force $sourceFile
    }
  }
}

LogTrace 1 "Leaving $cleanDir2 Total Removed - $Ctr2"
LogTrace 1 ""
LogTrace 1 "Entering $cleanDir3"
LogTrace 1 ""

#                            #
# ----- Third Directory -----#
#                            #

cd $cleanDir3

foreach client [lsort $clientList] {

  set globTarget [file join $cleanDir3 $client *]

  foreach sourceFile [glob -nocomplain $globTarget] {

    if { [file mtime $sourceFile] > 172800 } {

       incr Ctr3

       set delFile3 [file tail $sourceFile]

       LogTrace 0 "+ File is more than 2 days old, removing --> $delFile3"
       file delete -force $sourceFile
    }
  }
}

LogTrace 1 "Leaving $cleanDir3 Total Removed - $Ctr3"

}

###############################################################################
#                                                                             #
#  Proc:      AppendMsg                                                       #
#  Purpose:   Basically, checks that errorsmsg doesn't exceed practical       #
#             limit                                                           #
#                                                                             #
###############################################################################

proc AppendMsg { appendMsg } {

   global errormsg

   set maxLength 500000

   # add <br> to appendMsg
   set appendMsg "$appendMsg <br> \n "

   # errormsg should not exceed $maxLength characters
   puts "$appendMsg"

   if { [ string length $errormsg ] > $maxLength } {

      puts "Truncating mail"
      puts " Errormsg length:  [string length $errormsg ]"

      set errormsg [string range $errormsg 0 $maxLength]
      append errormsg "Truncating mail - it exceeds $maxLength.  \
                       Check log file for more info\n"

      puts " Errormsg length: [string length $errormsg ]"

   } else {

      append errormsg $appendMsg
   }
}

#############################################################################
#                                                                           #
#  Proc:    LogTrace                                                        #
#  Purpose: For logging purpose.  This also allows us to specify a certain  #
#           level of logging in the procedure(s) as needed.                 #
#                                                                           #
#############################################################################


proc LogTrace { minLogLevel errorMsg } {

   global logLevel

   if { $minLogLevel <= $logLevel } {

      AppendMsg $errorMsg

   }
}

###############################################################################
#                                                                             #
#  Proc:      SendMail                                                        #
#  Purpose:   This is a generic Proc sends mail.  Other functions build up    #
#             the error message.                                              #
#                                                                             #
###############################################################################

proc SendMail { subject sendTo } {

   global errormsg

   set msg "Reply-To: me@me.com\n"
   append msg "Subject: $subject\n"
   append msg "To: $sendTo\n"
   append msg "MIME-Version: 1.0\n"
   append msg "Content-Type: text/html; charset=us-ascii\n"
   append msg "<body text='#FFFFFF' bgcolor='navy'>"
   append msg "<CENTER><TABLE BORDER=9 CELLPADDING=5 COLS=1>"
   append msg "<TR><TD ALIGN=CENTER VALIGN=CENTER BGCOLOR='#CCCCCC'><font color='blue'> \
                     <b>DBA Report</TD></TR><BR><BR>"
   append msg "</TABLE></CENTER><BR><HR><BR>"

   append msg $errormsg

   exec /bin/echo $msg | /usr/lib/sendmail -t > /dev/null &
}

###############################################################################
#
# Entry Point
#
##############################################################################

LogTrace 0 ""
LogTrace 0 "Started [exec date]"
LogTrace 0 ""

cleanDIR

LogTrace 0 ""
LogTrace 0 "Finished [exec date]"

SendMail deleteDumps_DB1 $EMAIL_LIST
