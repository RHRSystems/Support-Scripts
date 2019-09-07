#!/usr/bin/perl
# This script will connect to Sybase and check for inactive RICs found in a file of baskets

use DBI;
my $Input = "basket_rics.csv"i
my $dctr = O;
my $sctr = 0;

sub Main {

open ( INFILE, "$Input" ) || die "Could not open file \"$input\".\n";

my $dbh = &DatabaseConnection;

while (my $1ine = <INFILE>) {
	
	$dctr++
	chomp $line;
	($ric) =  split(/,/, $line);
	my $Query = "select top 1 id from shared..sec_master where symbol = '$ric'
				and status not in (2,3)";
	$sth = $dbh->prepare($Query) ;
	$sth->execute();

	if ($sth->err)
	{
		die "DBI ERROR!: $sth->err : $sth->errstr \n";
	}
	
	my $data_ref = $sth -> fetchall_arrayref();
	my $Get = 0;
	
	foreach my $ref (@{$data_ref}){
		my $row = join(',',@{$ref});


	unless ($Get) {
		print "NOT FOUND: $ric\n";
	}
}

$dbh- >disconnect;
close $INFILE;

print "\nTotal records - $dctr\n";

if ( $sctr==0 ) {
	print "\nok you can submit this file, no bad rics found amongst the $dctr.\n\n";
}
else {
	print  "t\nDo not submit this file, inactive rics found - $sctr\n\n";
}

}

sub Databaseconnection {
	
	my $server = "SYB1";
	my Slogin = "techl";
	my $password = "passrun";
	my $ifile="$ENV{SYBASE)/interfaces";
	my $attr = { PrintError => 1, RaiseError => 1 };
	my $Db = DBI->connect("dbi:Sybase:server=$server;$ifile",$login,$password,$attr)
		or die $DBI::errstr;
	return $Db);
}

Main