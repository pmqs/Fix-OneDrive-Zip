
use strict;
use warnings;

use File::Temp qw(tempdir);
use Test::More tests => 17;
use File::Copy;
use Cwd;

my $HERE = getcwd();
my $testDir = $HERE . '/test';
my $FixZip = $HERE . '/fix-onedrive-zip';
my $BadZIP = 'zero.zip';

my ($status, $stdout, $stderr) ;

my $dir = tempdir(CLEANUP => 1);
# my $dir = "/tmp/fix"; mkdir "/tmp/fix";

chdir $dir
    or die "Cannot chdir to '$dir': $!\n";

{
    # Error: zip file does not exist
    ################################
    diag "Zip file does not exist";
    my $not_there = "not-exist";
    ($status, $stdout, $stderr) = run("perl $FixZip $not_there");

    isnt $status, 0, "fix-onedrive-zip returned non-zero" ;
    is $stdout, "", "no stdout";
    like $stderr, qr/Error: Cannot open '$not_there': No such file or directory/, "'$not_there' does not exist";
}

{
    # Error: zip file is empty
    ##########################
    diag "Zip file is empty";
    my $empty = "empty";
    open my $fh,  ">", $empty
        or die "Error: Cannot open '$empty': $!\n";

    close $fh;

    is -s $empty, 0, "test file is empty";

    ($status, $stdout, $stderr) = run("perl $FixZip $empty");

    isnt $status, 0, "fix-onedrive-zip returned non-zero" ;
    is $stdout, "", "no stdout";
    like $stderr, qr/Error: zip file '$empty' is empty/, "'$empty' is empty";
}

{
    # Fix a zip file
    ################

    copy($testDir . '/' . $BadZIP, $BadZIP)
        or die "Cannot copy $BadZIP to $dir: $!\n";

    ($status, $stdout, $stderr) = run("perl $FixZip $BadZIP");

    is $status, 0, "fix-onedrive-zip returned zero" ;

    # Now check that the zip file has been fixed
    #############################################
    ($status, $stdout, $stderr) = run("unzip -l $BadZIP");

    is $status, 0, "unzip -l returned zero for fixed zip file";

    # Output should be like this
    #
    # Archive:  $BadZIP
    #   Length      Date    Time    Name
    # ---------  ---------- -----   ----
    #        15  2020-06-01 16:03   data.txt
    # ---------                     -------
    #        15                     1 file
    # EOM

    like $stdout, qr/:03\s+data.txt/, "unzip -l shows data.txt";


    is $stderr, "", "No stderr";

    ok ! -e "data.txt", "data.txt does not exist yet";

    ($status, $stdout, $stderr) = run("unzip $BadZIP");

    is $status, 0, "unzip returned zero for extraction";
    is $stderr, "", "stderr empty";
    like $stdout, qr/extracting: data.txt/, "stdout ok";

    ok -e "data.txt", "data.txt now exists";
    is readFile("data.txt"), "this is a test\n", "File contents ok";
}

chdir $HERE ;

exit ;

sub removeHour
{
    my $string = shift;
    $string =~ s/15  2020-06-01 \d\d:03   data.txt/15  2020-06-01 XX:03   data.txt/;

    $string;
}

sub readFile
{
    my $f = shift ;

    my @strings ;

    open (F, "<$f")
        or die "Cannot open $f: $!\n" ;
    binmode F;
    @strings = <F> ;
    close F ;


    return @strings if wantarray ;
    return join "", @strings ;
}

sub run
{
    my $command = shift ;

    my $cmd = "$command 2>stderr";
    my $stdout = `$cmd` ;

    my $status = $?;
    my $stderr = readFile('stderr') ;

    return ($status, $stdout, $stderr);
}
