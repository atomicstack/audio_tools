#!/usr/bin/env perl

use 5.14.0;

use strict;
use warnings;

use Audio::Wav;
use Data::Dumper;

sub sound_hooks {
  my ($orig_filename) = @_;

  die "filename doesn't match profile" unless $orig_filename =~ m/\A
    [0-9]+ # file ID
    \s
    (.+?) # instrument name
    \s
    123Bpm
    \s
    ([A-Z]\S+) # key
    (\sUncut)?
    [ ]-[ ]NY90H[ ]Zenhiser[.]wav
  \z/xms;

  return "$2 $1";
}

sub drum_beats {
  my ($orig_filename) = @_;

  die "filename doesn't match profile" unless $orig_filename =~ m/\A
    0([0-9]{2}) # numeric id
    [(]
      ([a-z]) # alpha id
    [)]
  /xms;

  return "Beat $1$2";
}

sub basslines {
  my ($orig_filename) = @_;

  die "filename doesn't match profile" unless $orig_filename =~ m/\A
    [0-9]+ # file ID
    \s
    (Bassline)
    \s
    123Bpm
    \s
    ([A-Z]\S+) # key
    [ ]-[ ]NY90H[ ]Zenhiser[.]wav
  \z/xms;

  return "$2 $1";
}


my %dir_map = (
  'NY90H - Basslines'   => \&basslines,
  'NY90H - Drum Beats'  => \&drum_beats,
  'NY90H - Sound Hooks' => \&sound_hooks,
);

foreach my $dir ( keys %dir_map ) {
  chdir $dir;
  my @filenames = glob '*.wav';
  my %rename;
  @rename{@filenames} = map { "NY90H " . $dir_map{$dir}->($_) } @filenames;
  IO::File->new('titles.hash' => 'w')->print(Dumper(\%rename));
  chdir '..';
}
