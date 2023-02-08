#!/usr/bin/perl

# fix-onedrive-zip
#
# Fix OneDrive/Windows Zip files larger than 4Gig that have an invalid
# 'Total Number of Disks' field in the 'ZIP64 End Central Directory
# Locator'. The value in this field should be 1, but OneDrive/Windows sets
# it to 0.  This makes it difficult to work with these files using standard
# unzip utilities.
#
# This program changes the 'Total Number of Disks' field value to 1.
#
# Copyright (c) 2020-2022 Paul Marquess. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

use strict;
use warnings;

use Fcntl qw(SEEK_SET SEEK_END);
use Getopt::Long;

# Signatures for the headers we need to check
use constant ZIP_LOCAL_HDR_SIG                 => 0x04034b50;
use constant ZIP_END_CENTRAL_HDR_SIG           => 0x06054b50;
use constant ZIP64_END_CENTRAL_LOC_HDR_SIG     => 0x07064b50;

sub Seek;
sub Read;

my $VERSION = '1.01' ;
my $dry_run ;

GetOptions ("dry-run" => \$dry_run,
            "help"    => \&Usage)
    or Usage("Error in command line arguments\n");

Usage()
    unless @ARGV >= 1;

for my $filename (@ARGV)
{
    open my $fh,  "+<$filename"
        or die "Error: Cannot open '$filename': $!\n";
}

for my $filename (@ARGV)
{
    print "\nChecking '$filename'\n";
    open my $fh,  "+<$filename"
        or die "Cannot open '$filename': $!\n";

    my $data = Read $filename, $fh, 4;

    my $sig = unpack("V", $data) ;

    die "Error: No Zip signature at start of '$filename'\n"
        unless $sig == ZIP_LOCAL_HDR_SIG ;

    # Assume no comment or other trailing data
    # The last two things in the file are the Z64 & EOCD records

    Seek  $filename, $fh, -42 ;

    $data = Read $filename, $fh, 42;

    my $eocd = substr($data, 20);
    my $eocd_sig = unpack("V", substr($eocd, 0, 4)) ;

    die "Error: Cannot find Zip signature at end of '$filename'\n"
        unless $eocd_sig == ZIP_END_CENTRAL_HDR_SIG ;

    my $offset = unpack("VV", substr($eocd, 16, 4)) ;

    die sprintf "Error: bad offset 0x%X at end of '$filename'\n", $offset
        unless $offset == 0xFFFFFFFF ;

    my $z64_sig = unpack("V", substr($data, 0, 4)) ;

    die "Error: Cannot find Zip64 signature at end of '$filename'\n"
        unless $z64_sig == ZIP64_END_CENTRAL_LOC_HDR_SIG ;

    my $total_disks = unpack("V", substr($data, 16, 4)) ;

    if ($total_disks == 1)
    {
        print "Nothing to do: 'Total Number of Disks' field is already 1\n";
        next
    }

    if ($total_disks != 0)
    {
        die "Error: 'Total Number of Disks' field is $total_disks\n";
    }

    Seek $filename, $fh, -42 + 16 ;

    if ($dry_run)
    {
        print "Dry-Run: No change made to '$filename'\n";
    }
    else
    {
        print $fh pack "V", 1 ;
        print "Updated '$filename'\n";
    }
}

sub Seek
{
    my $filename = shift;
    my $fh = shift ;
    my $offset = shift ;

    seek $fh, $offset, SEEK_END
        or die "Cannot seek '$filename': $!\n" ;
}

sub Read
{
    my $filename = shift ;
    my $fh = shift;
    my $size = shift ;

    my $data ;

    read($fh, $data, $size) == $size
        or die "Cannot read from '$filename': $!\n" ;

    return $data;
}

sub Usage
{
    print <<'EOM';
Usage: fix-onedrive-zip [--dry-run] file1.zip [file2.zip...]

Fix OneDrive/Windows Zip files larger than 4Gig that have an invalid 'Total
Number of Disks' field in the 'ZIP64 End Central Directory Locator'. The
value in this field should be 1, but OneDrive/Windows sets it to 0. This
makes it difficult to work with these files using standard unzip utilities.

This program changes the 'Total Number of Disks' field value to 1.

See https://github.com/pmqs/Fix-OneDrive-Zip for support.

Copyright (c) 2020-2022 Paul Marquess (pmqs@cpan.org). All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

EOM
    exit;
}
