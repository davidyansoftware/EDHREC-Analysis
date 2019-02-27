use strict;
use warnings;

use LWP::Simple;

# collect list of commanders
my @commanders;
open FILE, "commander_cube.csv" or die ("Couldn't open commander_cube.csv");
while (my $line = <FILE>) {
    chomp $line;
    next if ($line eq '');
    if ($line =~ m/^"(.*?)","(.*?)","(.*?)","(.*?)",$/) {
        my $card = $1;
		my $color = lc $2;
		my $type = lc $3;
		
        # handle inconsistent character encoding between CubeTutor and EDHRec
		$card =~ s/Lim-Dul's Vault/Lim-Dûl's Vault/i;
		
        # commanders are marked as rainbow to distinguish from non-commander cards
		if ($color eq "rainbow") {
			push @commanders, $card;
		}
    } else {
        print "Incorrect Format: $line\n";
    }
}
close FILE;

# count the average deck for each commander
my %count;
foreach my $commander (@commanders) {
	print STDERR ".";

	my $url = "https://edhrec.com/decks/$commander";
    my $content = get $url or die "no content: $commander\n";
	
	my $decklist;
	if ($content =~ /Buy this decklist at Card Kingdom<\/a><br \/><br \/>(.*?)<\/div>/) {
		$decklist = $1;
	} else {
		print STDERR "invalid format: $commander";
		exit 1;
	}
	
	my @decklist = split /<br \/>/, $decklist;
	foreach my $card (@decklist) {
		next if $card eq "";
		$card =~ s/^\d+ //;
		$count{$card}++;
	}
}

# print total count of all cards
open FILE, ">harvest/averagedeck.txt";
my @sortedcards = sort {$count{$b} <=> $count{$a}} keys %count;
foreach my $card (@sortedcards) {
	print FILE "$count{$card}\t$card\n";
}
