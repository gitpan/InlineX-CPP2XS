use warnings;
use strict;
use InlineX::CPP2XS qw(cpp2xs);

print "1..2\n";

my %config_opts = (
                  'AUTOWRAP' => 1,
                  'AUTO_INCLUDE' => '#include <simple.h>' . "\n" .'#include "src/extra_simple.h"',
                  'TYPEMAPS' => ['src/simple_typemap.txt'],
                  'INC' => '-Isrc',
                  'SRC_LOCATION' => './src/test.alt',
                  );

cpp2xs('testc', 'testc', '.', \%config_opts);

my ($ok, $ok2) = (1, 1);
my @rd1;
my @rd2;

if(!rename('testc.xs', 'testc_cpp.txt')) {
  warn "couldn't rename testc.xs\n";
  print "not ok 1\n";
  $ok = 0;
}

if($ok) {
  if(!open(RD1, "testc_cpp.txt")) {
    warn "unable to open testc_cpp.txt for reading: $!\n";
    print "not ok 1\n";
    $ok = 0;
  }
}

if($ok) {
  if(!open(RD2, "expected_autowrap_c.txt")) {
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
    warn "testc_cpp.txt does not have the expected number of lines\n";
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
  warn "testc_cpp.txt does not match expected_autowrap.txt\n";
  print "not ok 1\n";
}

elsif($ok) {print "ok 1\n"}

close(RD1) or warn "Unable to close testc_cpp.txt after reading: $!\n";
close(RD2) or warn "Unable to close expected_autowrap.txt after reading: $!\n";
if(!unlink('testc_cpp.txt')) { warn "Couldn't unlink testc_cpp.txt\n"}

($ok, $ok2) = (1, 1);

###########################################################################

if(!open(RD1, "INLINE.h")) {
  warn "unable to open INLINE.h for reading: $!\n";
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
    warn "INLINE.h does not have the expected number of lines\n";
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
  warn "INLINE.h does not match expected.h\n";
  print "not ok 2\n";
}

elsif($ok) {print "ok 2\n"}

close(RD1) or warn "Unable to close INLINE.h after reading: $!\n";
close(RD2) or warn "Unable to close expected.h after reading: $!\n";
if(!unlink('INLINE.h')) { warn "Couldn't unlink INLINE.h\n"}


