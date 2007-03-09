#!/usr/bin/perl

use Socket;
use DBI;
use strict;

my $job_dir = $ARGV[0];
my $rg = $ARGV[1];
my $study = $ARGV[2];

my $dbh = DBI->connect('DBI:Pg:dbname=userdbdev8085_2004_1215', "vdsdev8085", "vdsdev8085")
    or die "Failed to connect to user database: " . DBI->errstr;

my $jobs_ins = $dbh->prepare(
    "INSERT INTO jobs (rg_id,job_dir,job_type,num_jobs,run_location,jobs_completed,curr_status,submit_time) " .
    "VALUES(?,?,?,?,?,?,?,?)");
my $rg_query = $dbh->prepare(
    "SELECT id from research_group where name=?");
my $jobs_query = $dbh->prepare(
    "SELECT id from jobs where rg_id=? and job_dir=?");

# Make intial record in database.
$rg_query->execute($rg);
my @row = $rg_query->fetchrow_array;
my $rg_id = $row[0];

$jobs_ins->execute($rg_id,$job_dir,$study,0,"Nowhere",0,"Starting","'now'");
$jobs_query->execute($rg_id,$job_dir);
@row = $jobs_query->fetchrow_array;
my $job_id = $row[0];

$jobs_ins->finish;
$rg_query->finish;
$jobs_query->finish;
$dbh->disconnect;
sleep 15;

# Monitor tailstatd until it is done.
my $job_done = 0;
my $tail_string = `cat $job_dir/tailstatd.sock`;
chomp $tail_string;
my ($ip, $port) = split(/ /, $tail_string);
while (!$job_done) {
    if (! -e "$job_dir/tailstatd.sock") {
        $job_done = 1;
        next;
    }
    $dbh = DBI->connect('DBI:Pg:dbname=userdbdev8085_2004_1215', "vdsdev8085", "vdsdev8085")
        or die "Failed to connect to user database: " . DBI->errstr;
    my $jobs_update = $dbh->prepare("UPDATE jobs SET num_jobs=?, jobs_completed=?,curr_status=? where id=?");
    
    socket(SH, PF_INET, SOCK_STREAM, getprotobyname('tcp')) || die $!;
    my $sin = sockaddr_in ($port,inet_aton($ip));
    connect(SH,$sin) || next;

    my $old_fh = select(SH);
    $| = 1;
    select($old_fh);

    my $total_jobs = 0;
    my $unready_jobs = 0;
    print SH "GET JOB TSSP/1.0\n";
    while (<SH>) {
        next if /200 OK/;

        $total_jobs++;
        
        if (/UN_READY/) {
           $unready_jobs++;
        }
    }
    $jobs_update->execute($total_jobs, $total_jobs - $unready_jobs, "Running on Fermilab CMS Cluster.",$job_id);
    close(SH);
    $jobs_update->finish;
    $dbh->disconnect;
    sleep 15;
}
$dbh = DBI->connect('DBI:Pg:dbname=userdbdev8085_2004_1215', "vdsdev8085", "vdsdev8085")
    or die "Failed to connect to user database: " . DBI->errstr;
my $jobs_up_finish = $dbh->prepare("UPDATE jobs SET finish_time='now' WHERE id=?");
$jobs_up_finish->execute($job_id);
$dbh->disconnect;
