#!/usr/bin/perl

use strict;
use warnings;

#################################################################################
# set file processing params                                                    #
#################################################################################

my $inputfile = 'konkordanz.txt';       #file containing correspondent Ids
my $delimiter = "\t";                   #value delimiter in $inputfile (e.g. "\t", "\s", ",", ";"...)
my $processfile = 'tcn_utf8.mrc.seq';   #file containing obsolete Ids to be replaced by new values in accordance with $inputfile and processing given below
my $linematch = " 85641 L ";            #script application is limited to $processfile lines containing this distinctive string/value



#################################################################################
# pimp shell output                                                             #
#################################################################################

print "\033[2J";
print "\033[0;0H";
sleep 1;
print "\nFile $processfile in progress...\n";
sleep 1;
print "\nThe table $inputfile (values delimited by $delimiter) is now applied to lines containing \"$linematch\".\n";
print "Please wait";
sleep 1;
print "...\n";



#################################################################################
# feed correspondant values to hash AND respective syntax (here: specific URLs) #
#################################################################################

my %correspondance;

open my $fh_input, '<' , $inputfile || die "\nCannot open input file $inputfile\n";

while (my $line = <$fh_input>) {
        chomp $line;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        $line =~ s/\r//g;
        next unless length($line);
        my ($id_old, $id_new) = split /$delimiter/, $line;
        defined($id_new) || die "Error: no counterpart for $id_old\n";
        $correspondance{'http://www.aspresolver.com/aspresolver.asp?NADR;'.$id_old} = 'https://nl.sub.uni-goettingen.de/id/'.$id_new .'?origin=/collection/nlh-tcn';
}

close $fh_input;



#################################################################################
# replace matches by regex actions and write output file                        #
#################################################################################

open my $fh_process, '<' , $processfile || die "\nCannot open file to process: $processfile\n";
open my $fh_output, '>' , $processfile.'.tmp' || die "\nCannot write temp file\n";


while (my $inline = <$fh_process>) {
        chomp($inline);
        if ($inline =~ /$linematch/) {
                foreach my $url_old (keys %correspondance) {
                        if ($inline =~ m/\Q$url_old/) {
#                               print $inline.' ---> ';
                                my $url_new;
                                $url_new = $correspondance{$url_old};
                                (my $outline = $inline) =~ s/\$\$u.*\$\$/\$\$u\$\$/;
                                $outline =~ s/\$\$u\$\$/\$\$u$url_new\$\$/;
#                               print $outline."\n";
                                print $fh_output "$outline\n";
                        }
                }
        }
        else {
                print $fh_output "$inline\n";
        }
}

close $fh_process;
close $fh_output;



#################################################################################
# identify unmatched sets and write to seperate file                            #
#################################################################################

open my $fh_check, '<' , $processfile.'.tmp' || die "\nUnable to access $processfile.tmp for check routine\n";

my @url_sets;
my @nourl_sets;

while (my $checkline = <$fh_check>) {
        chomp($checkline);
        if ($checkline =~ /$linematch/) {
                my $seqid_url = substr($checkline, 0, 9);
                push @url_sets, $seqid_url;
        }
        else {
                my $seqid_nourl = substr($checkline, 0, 9);
                push @nourl_sets, $seqid_nourl;
        }
}

close $fh_check;



sub unique {                                                    # reduce @nourl_sets to unique values
        my %ids;
        grep !$ids{$_}++, @_;
}

my @nourl_sets_unique = unique(@nourl_sets);



my %urlid_hash = map { $_ => 1 } @url_sets;                     # get difference between the two arrays
my %nourlid_hash = map { $_ => 1 } @nourl_sets_unique;

my @nourl_ids = grep !$urlid_hash{$_}, @nourl_sets_unique;



open my $fh_reprocess, '<' , $processfile || die "\nCannot open file to process: $processfile\n";
open my $fh_nourlfile, '>' , $processfile.'.rej' || die "\nCannot write outputfile for non-matching sets.\n";

while (my $nourlline = <$fh_reprocess>) {
        chomp($nourlline);
        foreach my $nourl_id (@nourl_ids) {
                if ($nourlline =~ /^$nourl_id\s.+/g) {
                        print $fh_nourlfile "$nourlline\n";
                }
        }
}

close $fh_reprocess;
close $fh_nourlfile;



open my $fh_linremove, '<' , $processfile.'.tmp' || die "\nUnable to access $processfile.tmp for cleanup routine\n";
open my $fh_final, '>' , $processfile.'.sed' || die "\nCannot write outputfile\n";

while (my $finalline = <$fh_linremove>) {
        chomp($finalline);
        foreach my $url_ids (@url_sets) {
                if ($finalline =~ /^$url_ids\s.+/g) {
                        print $fh_final "$finalline\n";
                }
        }
}

close $fh_linremove;
close $fh_final;



unlink $processfile.'.tmp';



exit();