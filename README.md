# EDHREC Web Scraper

This project is no longer working as of a recent change in edhrec

EDHREC is a resource I use to determine popular cards for the game Magic: the Gathering. EDHREC lists cards by usage in certain decks.

Terminology:

EDH aka Commander: a format where decks are built around a specific MTG Card.

Cube: a compilation of cards for players to dynamically build decks from.

This Web Scraper politely scrapes card usage information from EDHREC. It specifically looks for how popular cards are in relation to the set of decks I am interested in for my commander cube. These numbers are compared to the cards that are already in my cube by popularity. Cards that are in my cube that aren't popular in EDHREC are highlighted, as well as cards that aren't in my cube that are popular on EDHREC. This helps me make informed decisions for which cards I can include for a fun and optimal player experience.

## Getting Started

### Prerequisites

Perl 5 - for reading/writing to files, and processing results

A perl library is used for to handle user agent requests. This can be installed with CPAN

```
cpan install Bundle::LWP
```

### Usage

These scripts depend on reading from local files to see which cards to compare. These are: commander_cube.csv, commander_draft.txt

Scraping information can come from different pages depending on the type of data you need. This is represented through 3 different harvest scripts. Harvest scripts are handled independently from comparison scripts so avoid unneccesary processing when local files are adjusted.

Harvest information from any of the pages. This will write to a a file in ./harvest

```
perl harvestaveragedeck.pl
perl harvestpercentdeck.pl
perl harvesttopcards.pl
```

The harvested data can then be compared to local files. Comparisons can be compared in ./results

```
perl compareaveragedeck.pl
perl comparepercentdecks.pl
perl comparetopcards.pl
```