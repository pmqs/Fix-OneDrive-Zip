# Fix-OneDrive-Zip

    Usage: fix-onedrive-zip [--dry-run] file1.zip [file2.zip...]

Fix OneDrive Zip files larger than 4Gig that have an invalid `Total Number
of Disks` field in the `ZIP64 End Central Directory Locator`. The value in
this field should be 1, but OneDrive sets it to 0. This makes it difficult
to work with these files using standard unzip utilities.

This program changes the 'Total Number of Disks' field value to 1.

Copyright (c) 2020 Paul Marquess (pmqs@cpan.org). All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
