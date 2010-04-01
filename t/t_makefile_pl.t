use warnings;
use strict;
use Cwd;
use Config;
use InlineX::CPP2XS qw(cpp2xs);

# We can't have this test script write its files to the cwd - because that will
# clobber the existing Makefile.PL. So ... we'll have it written to the cwd/src
# directory. The following 3 lines of code are just my attempt to ensure that
# the Makefile.PL does NOT get written to the cwd.  
my $cwd = getcwd;
my $build_dir = "${cwd}/src";
die "Can't run the t_makefile_pl.t test script" unless -d $build_dir;


print "1..4\n";

my %config_opts = (
                  'AUTOWRAP' => 1,
                  'AUTO_INCLUDE' => '#include <simple.h>' . "\n" .'#include "src/extra_simple.h"',
                  'TYPEMAPS' => ['src/simple_typemap.txt'],
                  'INC' => '-Isrc',
                  'WRITE_MAKEFILE_PL' => 1,
                  'WRITE_PM' => 1,
                  'USE' => ['strict'],
                  'LIBS' => ['-L/anywhere -lbogus'],
                  'VERSION' => 0.42,
                  'BUILD_NOISY' => 0,
                  'CC' => $Config{cc},
                  'CCFLAGS' => '-DMY_DEFINE ' . $Config{ccflags},
                  'LD' => $Config{ld},
                  'LDDLFLAGS' => $Config{lddlflags},
                  'MAKE' =>  $Config{make},
                  'MYEXTLIB' => 'MANIFEST', # this test needs *only* that the file exists
                  'OPTIMIZE' => '-g',
                  );

cpp2xs('test', 'test', $build_dir, \%config_opts);

my ($ok, $ok2) = (1, 1);
my @rd1;
my @rd2;

if(!rename('src/test.xs', 'src/test.txt')) {
  warn "couldn't rename src/test.xs\n";
  print "not ok 1\n";
  $ok = 0;
}

if($ok) {
  if(!open(RD1, "src/test.txt")) {
    warn "unable to open src/test.txt for reading: $!\n";
    print "not ok 1\n";
    $ok = 0;
  }
}

if($ok) {
  if(!open(RD2, "expected_autowrap.txt")) {
    warn "unable to open expected_autowrap.txt for reading: $!\n";
    print "not ok 1\n";
    $ok = 0;
  }
}

if($ok) {
  @rd1 = <RD1>;
  @rd2 = <RD2>;
}

if($ok) {
  if(scalar(@rd1) != scalar(@rd2)) {
    warn "src/test.txt does not have the expected number of lines\n";
    print "not ok 1\n";
    $ok = 0;
  }
}

if($ok) {
  for(my $i = 0; $i < scalar(@rd1); $i++) {
     # Try to take care of platform/machine-specific issues
     # regarding line endings and whitespace.
     $rd1[$i] =~ s/\s//g;
     $rd2[$i] =~ s/\s//g;
     #$rd1[$i] =~ s/\r//g;
     #$rd2[$i] =~ s/\r//g;

     if($rd1[$i] ne $rd2[$i]) {
       if($rd2[$i] =~/#include<iostream.h>/ && $rd1[$i] =~ /#include<iostream>/) {next}
       warn "At line ", $i + 1, ":\n     GOT:", $rd1[$i], "*\nEXPECTED:", $rd2[$i], "*\n";
       $ok2 = 0;
       last;
     }
  }
}

if(!$ok2) {
  warn "src/test.txt does not match expected_autowrap.txt\n";
  print "not ok 1\n";
}

elsif($ok) {print "ok 1\n"}

close(RD1) or warn "Unable to close src/test.txt after reading: $!\n";
close(RD2) or warn "Unable to close expected_autowrap.txt after reading: $!\n";
if(!unlink('src/test.txt')) { warn "Couldn't unlink src/test.txt\n"}

($ok, $ok2) = (1, 1);

###########################################################################

if(!open(RD1, "src/INLINE.h")) {
  warn "unable to open src/INLINE.h for reading: $!\n";
  print "not ok 2\n";
  $ok = 0;
}

if($ok) {
  if(!open(RD2, "expected.h")) {
    warn "unable to open expected.h for reading: $!\n";
    print "not ok 2\n";
    $ok = 0;
  }
}

if($ok) {
  @rd1 = <RD1>;
  @rd2 = <RD2>;
}

if($ok) {
  if(scalar(@rd1) != scalar(@rd2)) {
    warn "src/INLINE.h does not have the expected number of lines\n";
    print "not ok 2\n";
    $ok = 0;
  }
}

if($ok) {
  for(my $i = 0; $i < scalar(@rd1); $i++) {
     # Try to take care of platform/machine-specific issues
     # regarding line endings and whitespace.
     $rd1[$i] =~ s/\s//g;
     $rd2[$i] =~ s/\s//g;
     #$rd1[$i] =~ s/\r//g;
     #$rd2[$i] =~ s/\r//g;

     if($rd1[$i] ne $rd2[$i]) {
       if($rd2[$i] =~ /#include<iostream.h>/ && $rd1[$i] =~ /#include<iostream>/) {next}
       warn "At line ", $i + 1, ":\n     GOT:", $rd1[$i], "*\nEXPECTED:", $rd2[$i], "*\n";
       $ok2 = 0;
       last;
     }
  }
}

if(!$ok2) {
  warn "src/INLINE.h does not match expected.h\n";
  print "not ok 2\n";
}

elsif($ok) {print "ok 2\n"}

close(RD1) or warn "Unable to close src/INLINE.h after reading: $!\n";
close(RD2) or warn "Unable to close expected.h after reading: $!\n";
if(!unlink('src/INLINE.h')) { warn "Couldn't unlink src/INLINE.h\n"}

($ok, $ok2) = (1, 1);

###########################################################################

if(!open(RD1, "src/Makefile.PL")) {
  warn "unable to open src/Makefile.PL for reading: $!\n";
  print "not ok 3\n";
  $ok = 0;
}

if($ok) {@rd1 = <RD1>}

# Not sure how best to check that the generated Makefile.PL is ok.
# In the meantime we have the following crappy checks. If it passes
# these tests, it's probably ok ... otherwise it may not be.

my $res;

if($ok) {
  for(@rd1) {
     $_ =~ s/\\\\/\\/g; # Handle recent ActivePerls
     if ($_ =~ /use ExtUtils::MakeMaker;/) {$res .= 'a'}
     if ($_ =~ /my %options =/) {$res .= 'b'}
     if ($_ =~ /INC/) {$res .= 'c'}
     if ($_ =~ /\-Isrc/) {$res .= 'd'}
     if ($_ =~ /NAME/) {$res .= 'e'}
     if ($_ =~ /test/) {$res .= 'f'}
     if ($_ =~ /LIBS/) {$res .= 'g'}
     if ($_ =~ /\-L\/anywhere \-lbogus/) {$res .= 'h'}
     if ($_ =~ /TYPEMAPS/) {$res .= 'i'}
     if ($_ =~ /simple_typemap\.txt/) {$res .= 'j'}
     if ($_ =~ /VERSION/) {$res .= 'k'}
     if ($_ =~ /0.42/) {$res .= 'l'}
     if ($_ =~ /WriteMakefile\(%options\);/) {$res .= 'm'}
     if ($_ =~ /sub MY::makefile { '' }/) {$res .= 'n'}
     if ($_ =~ /CC/) {$res .= 'o'}
     if ($_ =~ /\Q$Config{cc}\E/) {$res .= 'p'}
     if ($_ =~ /CCFLAGS/) {$res .= 'q'}
     if ($_ =~ /\s\-DMY_DEFINE/) {$res .= 'r'}
     if ($_ =~ /LD/) {$res .= 's'}
     if ($_ =~ /\Q$Config{ld}\E/) {$res .= 't'}
     if ($_ =~ /LDDLFLAGS/) {$res .= 'u'}
     if ($_ =~ /MAKE/) {$res .= 'v'}
     if ($_ =~ /\Q$Config{make}\E/) {$res .= 'w'}
     if ($_ =~ /MYEXTLIB/) {$res .= 'x'}
     if ($_ =~ /MANIFEST/) {$res .= 'y'}
     if ($_ =~ /OPTIMIZE/) {$res .= 'z'}
     if ($_ =~ /\-g/) {$res .= 'A'}
  }
}

if($ok) {
  for('a' .. 'z', 'A') {
     if($res !~ $_) {
       warn "'$_' is missing\n";
       $ok2 = 0;
     }
  }
}

if(!$ok2) {
  warn "$res\n";
  print "not ok 3\n";
}

elsif($ok) {print "ok 3\n"}

close(RD1) or warn "Unable to close src/Makefile.PL after reading: $!\n";
if(!unlink('src/Makefile.PL')) { warn "Couldn't unlink src/Makefile.PL\n"}

$ok = '';

eval{open(RD, '<', 'src/test.pm') or die $!;};

if($@) {print $@, "\n"}
else {$ok .= 'a'}

if($ok eq 'a') {
  my @pm = <RD>;
  $ok .= 'b' if $pm[0] =~ /^## This file generated by InlineX::CPP2XS/;
  $ok .= 'c' if $pm[1] eq "package test;\n";
  $ok .= 'd' if $pm[2] eq "use strict;\n";
  $ok .= 'e' if $pm[3] eq "\n";
  $ok .= 'f' if $pm[4] eq "require Exporter;\n";
  $ok .= 'g' if $pm[5] eq "*import = \\&Exporter::import;\n";
  $ok .= 'h' if $pm[6] eq "require DynaLoader;\n";
  $ok .= 'i' if $pm[7] eq "\n";
  $ok .= 'j' if $pm[8] eq "\$test::VERSION = '0.42';\n";
  $ok .= 'k' if $pm[9] eq "\n";
  $ok .= 'l' if $pm[10] eq "DynaLoader::bootstrap test \$test::VERSION;\n";
  $ok .= 'm' if $pm[11] eq "\n";
  $ok .= 'n' if $pm[12] eq "\@test::EXPORT = ();\n";
  $ok .= 'o' if $pm[13] eq "\@test::EXPORT_OK = ();\n";
  $ok .= 'p' if $pm[14] eq "\n";
  $ok .= 'q' if $pm[15] eq "sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking\n";
  $ok .= 'r' if $pm[16] eq "\n";
  $ok .= 's' if $pm[17] eq "1;\n";
  eval{close(RD) or die $!;};
  if(!$@) {$ok .= 't'}
  else {warn $@, "\n"}
}

if(!unlink('src/test.pm')) { warn "Couldn't unlink src/test.pm\n"}

if($ok eq 'abcdefghijklmnopqrst') {print "ok 4\n"}
else {
  warn $ok, "\n";
  print "not ok 4\n";
}

