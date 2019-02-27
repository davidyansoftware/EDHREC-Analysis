use strict;
use warnings;

$| = 1;

my %basiclands = (
	'Plains' => 1,
	'Island' => 1,
	'Swamp' => 1,
	'Mountain' => 1,
	'Forest' => 1
);

# parse the lists of cards in EDHRec average decks
my %reccount;
my %notinmylist;
open FILE, "harvest/averagedeck.txt" or die ("Couldn't open harvest/averagedeck.txt");
while (my $line = <FILE>) {
	chomp $line;
	next if ($line eq '');
	if ($line =~ /^(.*?)\t(.*?)$/) {
		$reccount{$2} = $1;
		$notinmylist{$2} = 1;
	} else {
		print "Incorrect Format: $line\n";
	}
}
close FILE;

# compile the cards from CubeTutor
my %cubecount;
my %onlyinmylist;
open FILE, "commander_cube.csv" or die ("Couldn't open commander_cube.csv");
while (my $line = <FILE>) {
    chomp $line;
    next if ($line eq '');
    if ($line =~ m/^"(.*?)","(.*?)","(.*?)","(.*?)",$/) {
        my $card = $1;
		my $color = lc $2;
		my $type = lc $3;
		
        $card =~ s/Lim-Dul's Vault/Lim-Dûl's Vault/i;
        
        next if ($color =~ m/RAINBOW/i);
        
        delete $notinmylist{$card};
        $cubecount{$card} = 1;
        
        $onlyinmylist{$card} = 1;
    } else {
        print "not compatible: $line\n";
    }
}
close FILE;

# print deck-count sorted lists to file
open FILE, ">results/averagedeckdiff.txt";

print FILE "POTENTIAL CUTS\n";
my @sorted = sort {($reccount{$a} || 0) <=> ($reccount{$b} || 0)} keys %onlyinmylist;
foreach my $card (@sorted) {
    next if defined $basiclands{$card};
    my $count = $reccount{$card} || 0;
    print FILE "$count\t$card\n";
}
print FILE "\n\n";

print FILE "POTENTIAL ADDS\n";
@sorted = sort {($reccount{$b} || 0) <=> ($reccount{$a} || 0)} keys %notinmylist;
foreach my $card (@sorted) {
    next if defined $basiclands{$card};
    my $count = $reccount{$card} || 0;
    print FILE "$count\t$card\n";
}
close FILE;
