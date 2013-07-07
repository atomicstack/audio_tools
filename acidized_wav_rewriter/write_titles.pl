#!/usr/bin/env perl

use 5.14.0;

use strict;
use warnings;

$|++;

use Audio::Wav;
use Data::Dumper;
use File::Temp qw/tempfile/;
use File::Basename qw/dirname/;

BEGIN {
  $ENV{QUIET} and open STDERR, '>', '/dev/null';
}

my @dirs;

if (grep { -d $_ } @ARGV) {
  @dirs = @ARGV;
}
else {
  die "no dirs specified!";
}

my $wav = Audio::Wav->new;

foreach my $dir (@dirs) {
  next unless -f "$dir/titles.hash";
  chdir $dir;
  my $titles = eval "no strict; do 'titles.hash'";
  
  foreach my $filename ( keys %$titles ) {
    do_file($filename, $titles, $wav);
  }

  chdir '..';
}

sub do_file {
  my ($filename, $titles, $wav) = @_;

  my $read = $wav->read($filename);

  my ($temp_fh, $temp_filename) = tempfile(".$filename.XXXXXXXXX");

  my $write = $wav->write($temp_filename, $read->details);

  $write->set_info(
    name      => $titles->{$filename},
    genre     => 'House',
    copyright => undef,
  );

  while ( defined( my $data = $read->read_raw(1048576) ) ) {
      $write->write_raw($data);
  }

  $write->finish;

  rename $temp_filename, $filename;
  ($temp_fh, $temp_filename) = (undef, undef);

  say "$filename done";

  return 1;
}
