#!/usr/bin/env perl
use utf8;
use strict;
use FindBin '$RealBin';
use Encode;
use POSIX qw(strftime);

chdir "$RealBin/..";

# Get current date
my $current_date = strftime "%Y-%m-%d", localtime;

# Header with dynamic date
my $all = << "HEADER";
---
title: Plurality
subtitle: "The Future of Collaborative Technology and Democracy"
author: "Audrey Tang, E. Glen Weyl and the Plurality Community"
date: "$current_date"
---
HEADER

sub read_file {
    my $filename = shift;
    open my $fh, '<:utf8', $filename or die "Cannot open $filename: $!";
    my $content = do { local $/; <$fh> };
    return $content;
}

sub write_file {
    my $filename = shift;
    open my $fh, '>:utf8', $filename or die "Cannot open $filename: $!";
    print $fh @_;
}

for (sort <contents/english/0*.md>) {
    my $c = read_file($_);
    Encode::_utf8_on($c);
    $c =~ s/數/Shù/g;
    $c =~ s/位/Wèi/g;
    $c =~ s/：/:/g;
    $c =~ s/^( +|&nbsp;)+//mg;
    $c =~ s,(<(br|img)\b[^>]*)(?<!/)>,$1 />,g;
    $all .= "$c\n\n";
}

write_file('english.md', $all);

print "Generating PDF (this may take a while)...\n";

system << '.';
docker run --volume "$(pwd):/data" --user $(id -u):$(id -g) audreyt/pandoc-plurality-book english.md -o Plurality-english.pdf --toc -s --pdf-engine=xelatex -V CJKmainfont='Noto Sans CJK TC' -V fontsize=18pt -V documentclass=extreport -f markdown-implicit_figures
.

print "Generating ePub (this should be fast)...\n";

system << '.';
docker run --volume "$(pwd):/data" --user $(id -u):$(id -g) audreyt/pandoc-plurality-book english.md -o Plurality-english.epub --toc -s
.
