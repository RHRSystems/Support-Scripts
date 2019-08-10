#!/bin/csh
# Using csh to force env variables to be set
#
# Author:  Randy Raskin
# Purpose: Use Sybtcl to get Sybase databases and run admin commands to check the
#          space used/free then send email with the results if below threshold

# \
cd `dirname $0`

# next line restarts as tclsh \
exec tclsh `basename $0` $*

package require Sybtcl

##############################################################################
# Global Variables
###############################################################################

set errormsg      ""
set dsquery       "SYB_WHK1"
set fda_username  "sa"
set fda_password  [exec getsap $dsquery]
set subject       "SYB_WHK1 space usage warning"
set sendTo        "$env(EMAIL_LIST)"
set logLevel       0
set retVal         0
set dbName        ""
set PercentFree   ""
set Type          ""
set Row           ""
set Row2          ""
set size_MB        0
set used_MB        0
set free_MB        0

###############################################################################
#                                                                             #
#  Proc:      DbGrabDB                                                        #
#  Purpose:   Repeat the Sybase command for every database                    #
#                                                                             #
###############################################################################

proc DbGrabDB { } {

global errormsg
global retVal
global f_username
global f_password
global dsquery
global sybmsg
global PercentFree
global Row
global Row2
global Type
global size_MB
global used_MB
global free_MB
global subject
global sendTo

regsub -all " " $f_password "" f_password

# create Fda connection
set getDbName [sybconnect $fda_username $fda_password $dsquery]

set dbSql "select name from master..sysdatabases where name like 'FDA_%'"

# Execute isql - any errors are added to the email
if { [ catch { sybsql $getDbName $dbSql } err ] != 0} {

   LogTrace 0 "<pre> ERROR: $sybmsg(dberrstr) $err"
}

set dbName [sybnext $getDbName]

LogTrace 0 "<CENTER><TABLE BORDER=2 WIDTH=85% CELLSPACING=0 CELLPADDING=5>"
LogTrace 0 "<TR BGCOLOR='#CCCCCC'>
                <TD ALIGN=CENTER><STRONG>Database</STRONG></TD>
                <TD ALIGN=CENTER><STRONG>Type</STRONG></TD>
                <TD ALIGN=CENTER><STRONG>size_MB</STRONG></TD>
                <TD ALIGN=CENTER><STRONG>used_MB</STRONG></TD>
                <TD ALIGN=CENTER><STRONG>free_MB</STRONG></TD>
                <TD ALIGN=CENTER><STRONG>% free</STRONG></TD>
            </TR>"

set Trigger "CLEAN"

while { $sybmsg(nextrow) != "NO_MORE_ROWS" } {

   set BigRow [DbSize $dbName]
   set Rows   [split BigRow :]
   set $Row   [lindex $Rows 0]
   set $Row2  [lindex $Rows 1]

   regsub -all {[\{\}]} $Row {} Row
   regsub -all "  " $Row " " Row

   regsub -all {[\{\}]} $Row2 {} Row2
   regsub -all "  " $Row2 " " Row2

   if { $dbName == "F_PROD_D" } { regsub -all "  " $Row " " Row
                                  regsub -all "  " $Row2 " " Row2 }

   set splitRow [split $Row " " ]
   set Type     [lindex $splitRow 2]
   set size_MB  [lindex $splitRow 3]
   set used_MB  [lindex $splitRow 4]
   set free_MB  [lindex $splitRow 5]
   set PercentFree [lindex $splitRow 6]

   set splitRow2 [split $Row2 " " ]
   set Type2     [lindex $splitRow2 2]
   set size_MB2  [lindex $splitRow2 3]
   set used_MB2  [lindex $splitRow2 4]
   set free_MB2  [lindex $splitRow2 5]
   set PercentFree2 [lindex $splitRow2 6]

   # Check for Data devices
   if { $PercentFree >  10.00 } {

       LogTrace 0 "<TR BGCOLOR='white'><TD>$dbName</TD>
                                       <TD>$Type</TD>
                                       <TD>$size_MB</TD>
                                       <TD>$used_MB</TD>
                                       <TD>$free_MB</TD>
                                       <TD>$PercentFree</TD></TR>"
   } elseif { $PercentFree <  5.00 } {

       set Trigger "ERROR"

       LogTrace 0 "<TR BGCOLOR='#FF0000'><TD>$dbName</TD>
                                       <TD>$Type</TD>
                                       <TD>$size_MB</TD>
                                       <TD>$used_MB</TD>
                                       <TD>$free_MB</TD>
                                       <TD>$PercentFree</TD></TR>"
   } else {

       set Trigger "ERROR"

       LogTrace 0 "<TR BGCOLOR='yellow'><TD>$dbName</TD>
                                         <TD>$Type</TD>
                                         <TD>$size_MB</TD>
                                         <TD>$used_MB</TD>
                                         <TD>$free_MB</TD>
                                         <TD>$PercentFree</TD></TR>"
   }

   # Check for Log devices
   if { $PercentFree2 >  10.00 } {

       LogTrace 0 "<TR BGCOLOR='white'><TD>$dbName</TD>
                                       <TD>$Type2</TD>
                                       <TD>$size_MB2</TD>
                                       <TD>$used_MB2</TD>
                                       <TD>$free_MB2</TD>
                                       <TD>$PercentFree2</TD></TR>"
   } elseif { $PercentFree <  5.00 } {

       set Trigger "ERROR"

       LogTrace 0 "<TR BGCOLOR='#FF0000'><TD>$dbName</TD>
                                       <TD>$Type2</TD>
                                       <TD>$size_MB2</TD>
                                       <TD>$used_MB2</TD>
                                       <TD>$free_MB2</TD>
                                       <TD>$PercentFree2</TD></TR>"
   } else {

       set Trigger "ERROR"

       LogTrace 0 "<TR BGCOLOR='yellow'><TD>$dbName</TD>
                                         <TD>$Type2</TD>
                                         <TD>$size_MB2</TD>
                                         <TD>$used_MB2</TD>
                                         <TD>$free_MB2</TD>
                                         <TD>$PercentFree2</TD></TR>"
   }

  set dbName [sybnext $getDbName]
}

LogTrace 0 "</TABLE></CENTER>"

sybclose $getDbName

if { $Trigger == "ERROR" } { SendMail $subject $sendTo }

}

################################################################################
#                                                                              #
#                               DbSize                                         #
#                                                                              #
################################################################################

proc DbSize { dbName } {

global retVal
global sybmsg
global errormsg
global f_username
global f_password
global dsquery
global PercentFree
global Row
global Row2
global Type
global size_MB
global used_MB
global free_MB

regsub -all " " $f_password "" f_password

# create Fda connection
set getData1 [sybconnect $f_username $f_password $dsquery]
set Sql "sp_space total"

sybuse $getData1 $dbName

if { [ catch { sybsql $getData1 $Sql } err ] != 0} {

   LogTrace 0 "<pre> ERROR: $sybmsg(dberrstr) $err"

} else {
   set Row [sybnext $getData1]
   set Row2 [sybnext $getData1]
   set BigRow "$Row:$Row2"

   return $BigRow
}

sybclose $getData1

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
   ##set appendMsg "$appendMsg <br> \n "
   set appendMsg "$appendMsg \n "

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

   LogTrace 1 "Entering Proc SendMail"

   set msg "Reply-To: ops@myco.com\n"
   append msg "Subject: $subject\n"
   append msg "To: $sendTo\n"
   append msg "MIME-Version: 1.0\n"
   append msg "Content-Type: text/html; charset=us-ascii\n"
   append msg "<body text='black' bgcolor='navy'>"
   append msg "<CENTER><TABLE BORDER=9 CELLPADDING=5 COLS=1>"
   append msg "<TR><TD ALIGN=CENTER VALIGN=CENTER BGCOLOR='#CCCCCC'><font color='blue'>
                     <b>DBA Report</b></TD>"
   append msg "</TABLE></CENTER>"
   append msg "<center><BR><b><u><FONT COLOR='white'>Database Size Check</b> - Run on: [exec date]
                                 </FONT></u><BR><HR><BR></center>"

   append msg $errormsg

   append msg "</table>"

   exec /bin/echo $msg | /usr/lib/sendmail -t > /dev/null &

   LogTrace 1 "Leaving SendMail"
}

###############################################################################
#
# Entry Point
#
###############################################################################

DbGrabDB
