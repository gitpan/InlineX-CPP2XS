use warnings;
use strict;
use InlineX::CPP2XS qw(cpp2xs);

print "1..1\n";

cpp2xs('hello', 'hello',
       {PREFIX => 'remove_', BOOT => 'printf("Hi from bootstrap\n");'});

my ($ok, $ok2) = (1, 1);
my @rd1;
my @rd2;

if(!rename('hello.xs', 'hello.txt')) {
  warn "couldn't rename hello.xs\n";
  print "not ok 1\n";
  $ok = 0;
}

if($ok) {
  if(!open(RD1, "hello.txt")) {
    warn "unable to open hello.txt for reading: $!\n";
    print "not ok 1\n";
    $ok = 0;
  }
}

if($ok) {
  if(!open(RD2, "expected_hello.txt")) {
    warn "unable to open expected_hello.txt for reading: $!\n";
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
    warn "hello.txt does not have the expected number of lines\nGenerated: ", scalar(@rd1), "\nExpected: ", scalar(@rd2), "\n";
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
       if($rd2[$i] =~ /#include<iostream.h>/ && $rd1[$i] =~ /#include<iostream>/) {next}
       warn "At line ", $i + 1, ":\n     GOT:", $rd1[$i], "*\nEXPECTED:", $rd2[$i], "*\n";
       $ok2 = 0;
       last;
     }
  }
}

if(!$ok2) {
  warn "hello.txt does not match expected_hello.txt\n";
  print "not ok 1\n";
}

elsif($ok) {print "ok 1\n"}

close(RD1) or warn "Unable to close hello.txt after reading: $!\n";
close(RD2) or warn "Unable to close expected_hello.txt after reading: $!\n";
if(!unlink('hello.txt')) { warn "Couldn't unlink hello.txt\n"}

