# Fix-OneDrive-Zip

[![Linux build](https://github.com/pmqs/Fix-OneDrive-Zip/workflows/Linux%20build/badge.svg)](https://github.com/pmqs/Fix-OneDrive-Zip/actions)
[![Macos build](https://github.com/pmqs/Fix-OneDrive-Zip/workflows/Macos%20build/badge.svg)](https://github.com/pmqs/Fix-OneDrive-Zip/actions)
[![Windows build](https://github.com/pmqs/Fix-OneDrive-Zip/workflows/Windows%20build/badge.svg)](https://github.com/pmqs/Fix-OneDrive-Zip/actions)
[![FreeBSD](https://api.cirrus-ci.com/github/pmqs/Fix-OneDrive-Zip.svg?task=FreeBSD)](https://cirrus-ci.com/github/pmqs/Fix-OneDrive-Zip?task=FreeBSD)

This program fixes an issue with Zip files larger than 4 Gig created by
`OneDrive` and also the Windows 10 right-click action "`Send-To/Compressed
(zip) folder`". At the time of writing these Zip files cannot be unzipped
using some of the well-know Zip archivers.

For a really detailed summary of the issue, see
[Does Microsoft OneDrive export large ZIP files that are corrupt?](https://www.bitsgalore.org/2020/03/11/does-microsoft-onedrive-export-large-ZIP-files-that-are-corrupt).

This program automates the manual process described in the referenced page.

**Notes**

1. This program will modify your Zip file, so it is good practice to take a
backup copy of the original file just in case.

2. You need a 64-bit build of `perl` installed on your system to run this program.

## Usage

    perl fix-onedrive-zip [--dry-run] file1.zip [file2.zip...]

The `--dry-run` option will simulate running of the program without making
any changes to the Zip file.

## Notes for Windows users

If you are running Windows and don't know what a perl script is, or how to run one, this section
will walk you through the process.

### Step 1: Check if you have perl already installed

The `fix-onedrive-zip` script is written in `perl`. To run it on your PC you need
the `perl` executable.

To check if it is already installed, create a terminal window by typing `Windows+R`.
In the pop-up window type `cmd`. You should now have a terminal window open.

Type `perl -v`.
If `perl` is installed you should see text like this. The Perl version doesn't matter.

```
C:\Users\me>perl -v

This is perl 5, version 32, subversion 1 (v5.32.1) built for MSWin32-x64-multi-thread

Copyright 1987-2021, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.
```

If you don't have `perl`, the output will look like this

```
'perl' is not recognized as an internal or external command,
operable program or batch file.
```

### Step 2: Install Perl if you don't already have it

There are a number of perl executables available for Windows.
For this tutorial I've used [Strawberry Perl](https://strawberryperl.com/), but there are others available.

Use the instructions [here](https://www.perltutorial.org/setting-up-perl-development-environment/) to install the 64-bit "*Recommended version*" of `perl` from the [Strawberry Perl](https://strawberryperl.com/) site.

Once the installation is complete, run `Step 1`, above, to check that the perl works ok
from the command-line in a terminal window.


### Step 3: Download the script

You now need to get the script `fix-onedrive-zip` downloaded from GitHub and stored on your PC. In a browser navigate to
[here](https://github.com/pmqs/Fix-OneDrive-Zip/blob/master/fix-onedrive-zip) and
select the "`Download raw file`" icon, as highlighted below

![](assets/download.png)

That should download the file `fix-onedrive-zip` into your `Downloads` directory.

### Step 4: Running the script

The easiest approach to running this script if you are not confortable with running from the command-line is to
put the `fix-onedrive-zip` script and the zip file you want to fix in the same folder. Lets assume you have both stored in the folder `C:\fixzip` and the name of the OneDrive zip file you want to fix is `myfile.zip`.

Start by creating a terminal window by typing `Windows+R` and typing `cmd` in the pop-up window.

Now run the command below in the terminal window to move to the folder where your zip file is stored, replacing
`C:\fixzip` with the name of the folder you are using

```
cd C:\fixzip
```

You can now run the `fix-onedrive-zip` script by typing this in the terminal window. Remember to change `myfile.zip` to the name of the zip file you want fixed.

```
perl fix-onedrive-zip myfile.zip
```

## What if this program doesn't fix the issue?

The most common issue reported with this script is the following error
message:

```Error: Cannot find Zip signature at end of 'somefile.zip'```

To understand the reson for this message you need to know a little bit
about the structure of a zip file.  Firstly, at the start of a zip file
there are 4 bytes called the "`local file header signature`" (which get
unpacked as the litte-endian value `0x04034b50`). For this error case these
signature bytes *will* be present, so the script knows it likely dealing
with a zip file.

Once that initial test is done, the script moves to 22 bytes before the end
of the file and checks that the 4 bytes of the "`end of central dir
signature`" (little-endian value `0x06054b50`) are present.  In this case
it doesn't find these signature bytes and terminates with the error message
shown above.

This typically means that the zip file has been either truncated or has
become corrupt.

If possible, try downloading the file again.

## Technical Details

If you want to understand more about the internal structuire of Zip files,
the primary reference is
[APPNOTE.TXT](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT).

The issue with the `OneNote`/`Windows` Zip files larger than 4 Gig is they
have an invalid `Total Number of Disks` field in the
`ZIP64 End Central Directory Locator` record (see [APPNOTE.TXT](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT) version 6.3.9, section 4.3.15).
The value in this field should be `1`, but `OneDrive`/`Windows` sets it to `0`.

This program simply changes the `Total Number of Disks` field value to `1`
if it finds it set to `0` in the Zip file.
## Support

https://github.com/pmqs/Fix-OneDrive-Zip/issues


## Copyright

Copyright (c) 2020-2023 Paul Marquess (pmqs@cpan.org). All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
