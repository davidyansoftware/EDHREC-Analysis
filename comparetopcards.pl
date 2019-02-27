use strict;
use warnings;

$| = 1;

my @colors = qw(white blue black red green multi colorless);

# parse the top cards per color from EDHRec
my %reccount;
my %notinmylist;
foreach my $color (@colors) {
    open FILE, "harvest/${color}count.txt" or die ("Couldn't open harvest/${color}count.txt");
    while (my $line = <FILE>) {
        chomp $line;
        next if ($line eq '');
        if ($line =~ /^(.*?)\|(.*?)$/) {
            $reccount{$color}{$1} = $2;
            $notinmylist{$color}{$1} = 1;
        } else {
            print "Incorrect Format: $line\n";
        }
    }
    close FILE;
}

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
		
		next if $type eq "land";
		
        $card =~ s/Lim-Dul's Vault/Lim-Dûl's Vault/i;
        
        next if ($color =~ m/RAINBOW/i);
        $color =~ s/mono_//i;
		$color =~ s/colourless/colorless/i;
        $color = "multi" if ($color eq "azorius" or
			$color eq "dimir" or
			$color eq "rakdos" or
			$color eq "gruul" or
			$color eq "selesnya" or
			$color eq "orzhov" or
			$color eq "golgari" or
			$color eq "simic" or
			$color eq "izzet" or
			$color eq "boros");
        
        delete $notinmylist{$color}{$card};
        $cubecount{$color}{$card} = 1;
        
        $onlyinmylist{$color}{$card} = 1;
    } else {
        print "not compatible: $line\n";
    }
}
close FILE;

# print count-sorted lists to file
foreach my $color (@colors) {
    open FILE, ">results/".$color."diff.txt";
    
    print FILE "POENTIAL CUTS\n";
    my @sorted = sort {($reccount{$color}{$a} || 0) <=> ($reccount{$color}{$b} || 0)} keys %{$onlyinmylist{$color}};
    foreach my $card (@sorted) {
        my $count = $reccount{$color}{$card} || 0;
        print FILE "$card,$count\n";
    }
    print FILE "\n\n";
    
    print FILE "POTENTIAL ADDS\n";
    @sorted = sort {($reccount{$color}{$b} || 0) <=> ($reccount{$color}{$a} || 0)} keys %{$notinmylist{$color}};
    foreach my $card (@sorted) {
		my $count = $reccount{$color}{$card} || 0;
        print FILE "$card,$count\n";
    }
    close FILE;
}
