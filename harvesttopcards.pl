use strict;
use warnings;

use LWP::Simple;

my %colors = (
    white => 'w',
    blue => 'u',
    black => 'b',
    red => 'r',
    green => 'g',
    multi => 'multi',
    colorless => 'colorless'
);

# get top card count of each color
my %count;
foreach my $color (keys %colors) {
    my $url = "https://edhrec.com/top/$colors{$color}";
    my $content = get $url or die "no content: $color\n";

	#$content =~ s/<h3>Lands<\/h3>(.*?)$//is;
    #while ($content =~ s/<div class="nwname">(.*?)<\/div>\n\s+<div class="nwdesc ellipsis">(\d+)% of (\d+) decks//) {
    # 20181023
    while ($content =~ s/"label":"In (\d+) decks<br>\d% of (\d+) decks.*?"name":"(.*?)"//) {
        # $1 cardname
        # $2 percent
        # $3 decks
        # $count{$color}{$1} += ($2 * $3)/100;

        # $1 decks 
        # $2 totalDecks 
        # $3 cardname
        $count{$color}{$3} += sprintf("%.4f", $1 / $2);
    }
}

# print total count of all cards
foreach my $color (keys %colors) {
    open FILE, ">harvest/${color}count.txt";
    my @sorted = sort {$count{$color}{$a} <=> $count{$color}{$b}} keys %{$count{$color}};
    foreach my $card (@sorted) {
        print FILE "$card|$count{$color}{$card}\n";
    }
	close FILE;
}
