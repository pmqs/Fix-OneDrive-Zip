# Fix-OneDrive-Zip

[![Linux build](https://github.com/pmqs/Fix-OneDrive-Zip/workflows/Linux%20build/badge.svg)](https://github.com/pmqs/Fix-OneDrive-Zip/actions)
[![Macos build](https://github.com/pmqs/Fix-OneDrive-Zip/workflows/Macos%20build/badge.svg)](https://github.com/pmqs/Fix-OneDrive-Zip/actions)
[![Windows build](https://github.com/pmqs/Fix-OneDrive-Zip/workflows/Windows%20build/badge.svg)](https://github.com/pmqs/Fix-OneDrive-Zip/actions)
[![FreeBSD](https://api.cirrus-ci.com/github/pmqs/Fix-OneDrive-Zip.svg?task=FreeBSD)](https://cirrus-ci.com/github/pmqs/Fix-OneDrive-Zip?task=FreeBSD)

This program fixes an issue with Zip files larger than 4 Gig created by either
`OneDrive` or  the Windows 10 right-click action "`Send-To/Compressed
(zip) folder`". At the time of writing these Zip files cannot be unzipped
using some of the well-know Zip archivers.

For a really detailed summary of the issue, see
[Does Microsoft OneDrive export large ZIP files that are corrupt?](https://www.bitsgalore.org/2020/03/11/does-microsoft-onedrive-export-large-ZIP-files-that-are-corrupt).

This program automates the manual process described in the referenced page.

> [!NOTE]
>
> 1. It may be possible to work around this issue by updating the archiving program you are using to the latest version.
>
> 2. This program will modify your Zip file, so it is good practice to take a backup copy of the original file just in case.
>
> 3. You need a 64-bit build of `Perl` installed on your system to run this program.

## Usage

    perl fix-onedrive-zip [--dry-run] file1.zip [file2.zip...]

The `--dry-run` option will simulate running of the program without making
any changes to the Zip file.

<details>
<summary> <h2>Notes for Windows Users</h2></summary>

If you are running Windows and don't know what a perl script is, or how to run one, this section
will walk you through the process.

<details>
<summary> <b>Step 1: Check if you already have Perl installed</b></summary>
<p></p>

The `fix-onedrive-zip` script is written in `Perl`. To run it on your PC you need
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
</details>

<details>
<summary> <b>Step 2: Install Perl if you don't already have it</b></summary>
<p></p>

There are a number of Perl executables available for Windows.
For this tutorial I've used [Strawberry Perl](https://strawberryperl.com/), but there are others available.

Use the instructions [here](https://www.perltutorial.org/setting-up-perl-development-environment/) to install the 64-bit "*Recommended version*" of `perl` from the [Strawberry Perl](https://strawberryperl.com/) site.

Once the installation is complete, run `Step 1`, above, to check that the perl works ok
from the command-line in a terminal window.
</details>

<details>
<summary> <b>Step 3: Download the fix-onedrive-zip script</b></summary>
<p></p>

You now need to get the script `fix-onedrive-zip` downloaded from GitHub and stored on your PC. In a browser navigate to
[here](https://github.com/pmqs/Fix-OneDrive-Zip/blob/master/fix-onedrive-zip) and
select the "`Download raw file`" icon, as highlighted below

![](assets/download.png)

That should download the file `fix-onedrive-zip` into your `Downloads` directory.
</details>

<details>

<summary> <b>Step 4: Running the fix-onedrive-zip script</b></summary>
<p></p>

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
</details>
</details>


<details>
<summary><h2>What if this program does not fix the issue?</h2></summary>


The most common issue reported with this script is the following error
message:

```Error: Cannot find Zip signature at end of 'somefile.zip'```

To understand what this message means you first need to know a little bit
about the structure of the metadata in a zip file.

At the start of a zip file
there are 4 bytes called the "`local file header signature`". The majority of metedata values in a zip file are stored in little-endian byte order, so these 4 bytes are unpacked as the litte-endian value `0x04034b50`. For this error case these 4
signature bytes *will* be present, so the script knows it likely dealing
with a zip file.

Once that initial test is done, the script moves to 22 bytes before the end
of the file and checks that the 4 bytes of the "`end of central dir
signature`" (little-endian value `0x06054b50`) are present.  In this case
it *doesn't* find these signature bytes.

This program can only work with a well-formed zip file, so it now terminates immediately with the error message shown above.

The root-cause for this error is typically a zip file that has either been truncated or partially corrupted (i.e. the end the file has been overwritten with random data).

<details>
<summary><h3>Strategies for recovering data</h3></summary>


The most straightforward way to deal with a truncated/corrupt zip file is to download a fresh copy of the zip file.

If downloading is not an option it may be possible to recover some/all of the zip file payload data. It just depends on how badly damaged the file is. Be aware - if payload data has been overwritten or is absent there is no way that to retrieve this data from the zip file.

There are plenty of articles available online that discuss recovering data from corrupt zip files, so I'll only mention that the  [Info-ZIP](https://infozip.sourceforge.net/) implementaion of `zip` (most Unix/Mac systems ship with this program) has two commandline options,  `-F` and `-FF`,  that can be used to attempt to fix zip files.

</details>
</details>


<details>
<summary><h2>Zip File Technical Details</h2></summary>

If you want to understand more about the internal structure of Zip files,
the primary reference is
[APPNOTE.TXT](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT).

The issue with `OneNote`/`Windows` Zip files larger than 4 Gig is they
have an invalid `Total Number of Disks` field in the
`ZIP64 End Central Directory Locator` record (see [APPNOTE.TXT](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT) version 6.3.10, section 4.3.15).
The value in this field should be `1`, but `OneDrive`/`Windows` incorrectly sets it to `0`.

This program simply changes the `Total Number of Disks` field value to `1`
if it finds it set to `0` in a Zip file.

</details>

## Support

https://github.com/pmqs/Fix-OneDrive-Zip/issues


## Copyright

Copyright (c) 2020-2023 Paul Marquess (pmqs@cpan.org). All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
