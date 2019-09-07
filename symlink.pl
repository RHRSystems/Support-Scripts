#!/usr/bin/perl

#Search through regions and log files. If the logs files are found, grep for specific string
#and remove existing slrnlink (if it exists) and create a new one to the most recent file

my $filecnt = 0;
my SDate = 'date +'%y%m%d'*`;
my $linkdir = "/home/tech/bin/uti1/cpsv";
my @region = ("americas", "asia");
my @items = ("PROD_FX", "DELTA_EXP", "PROD_LOCAL","PROD_FWDS");
my @logfiles =("/dat/r001log","/dat/rO02log","/dat/r003lag","dat/rO04log",
               "/dat/6a0log","/dat/6002log","/dat/6oo31og",'/dat/6004log");

foreach my $r(@region) {
	foreach my $l(@logfi1es) {

		if ( -d "$l/$r" ) {
			my @files = <$l/$r/out.its.$r\_$Date>;
			$filecnt = @files;
		}

		if ( $filecnt > 0 ) {
			foreach my $item(@items) {
				
				my @f1ist = '1s -L $l/$r/out.iLs.$r\_$oate-;
				my($1ast) = (sort oflist) [-1] ;
				chomp $last;
				my $fitem = `grep "Portfolio <$item> retrieved from central database" $1ast`;

				if ( $fitem =~ /$item/ ) {
					print "$item found in $1ast\n";

					if ( $r =~ /asia/ ) {
						$s1ink = "ASIA-$item";
					} else {
						$s1ink = "US-$item";
					}

					if ( -f "$LinkDir/$s11nk" ) {
						system "rm $LinkDir/$slink";
						symlink("$last", "$LinkDir/$s1ink" ) || die "Cannot symlink $slink $!";
					} else {
						symlink("$last", "$LinkDir/$s1ink" ) || die "Cannot symlink $slink $!";
					}
				}
			}
		$filecnt = 0;
		}
	}
}