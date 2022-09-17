# Fix-OneDrive-Zip

[![Linux build](https://github.com/pmqs/Fix-OneDrive-Zip/workflows/Linux%20build/badge.svg)](https://github.com/pmqs/Fix-OneDrive-Zip/actions)
[![Macos build](https://github.com/pmqs/Fix-OneDrive-Zip/workflows/Macos%20build/badge.svg)](https://github.com/pmqs/Fix-OneDrive-Zip/actions)
[![Windows build](https://github.com/pmqs/Fix-OneDrive-Zip/workflows/Windows%20build/badge.svg)](https://github.com/pmqs/Fix-OneDrive-Zip/actions)

This program fixes an issue with Zip files larger than 4 Gig created by
`OneDrive` and also the Windows 10 right-click action `Send-To/Compressed
(zip) folder`. At the time of writing these Zip files cannot be unzipped
using some of the well-know Zip archivers.

For a really detailed summary of the issue, see
[Does Microsoft OneDrive export large ZIP files that are corrupt?](https://www.bitsgalore.org/2020/03/11/does-microsoft-onedrive-export-large-ZIP-files-that-are-corrupt).

This program automates the manual process described in the referenced page.

**Notes**

1. This program will modify your Zip file, so it is good practice to take a
backup copy of the original file just in case.

2. You need a 64-bit build of `perl` to run this program.

## Usage

    perl fix-onedrive-zip [--dry-run] file1.zip [file2.zip...]

The `--dry-run` option will simulate running of the program without making any changes to the Zip file.

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

Copyright (c) 2020-2022 Paul Marquess (pmqs@cpan.org). All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
