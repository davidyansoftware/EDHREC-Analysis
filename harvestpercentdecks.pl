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

# count the cards played in each commander deck
my %count;
foreach my $commander (@commanders) {
    print STDERR ".";

    my $url = "https://edhrec.com/commanders/$commander";
    my $content = get $url or die "no content: $commander\n";

    #while ($content =~ s/<div class="nwname">(.*?)<\/div>\n\s+<div class="nwdesc ellipsis">(\d+)% of (\d+) decks//)
    # 20181023
    while ($content =~ s/"name":"(.*?)".*?"label":"(\d+)% of (\d+) decks//)
    {
        # $1 cardname
        # $2 percent
        # $3 decks
        # $count{$1} += ($2 * $3)/100;

        # $1 cardname
        # $2 percent
        # $3 decks 
        $count{$1} += $2;
    }
}

# print count for commander decks
open FILE, ">harvest/percentdeckcount.txt";
my @sortedcards = sort {$count{$b} <=> $count{$a}} keys %count;
foreach my $card (@sortedcards) {
    print FILE "$count{$card}\t$card\n";
}
close FILE;
