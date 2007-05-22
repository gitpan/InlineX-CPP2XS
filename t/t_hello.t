use warnings;
use strict;
use InlineX::CPP2XS qw(cpp2xs);

print "1..1\n";

cpp2xs('hello', 'hello',
       {PREFIX => 'remove_', BOOT => 'printf("Hi from bootstrap\n");'});

if(!rename('hello.xs', 'hello.txt')) {
  print "not ok 1 - couldn't rename hello.xs\n";
  exit;
}

my $ok = 1;

if(!open(RD1, "hello.txt")) {
  print "not ok 1 - unable to open hello.txt for reading: $!\n";
  exit;
}

if(!open(RD2, "expected_hello.txt")) {
  print "not ok 1 - unable to open expected_hello.txt for reading: $!\n";
  exit;
}

my @rd1 = <RD1>;
my @rd2 = <RD2>;

if(scalar(@rd1) != scalar(@rd2)) {
  print "not ok 1 - hello.txt does not have the expected number of lines\nGenerated: ", scalar(@rd1), "\nExpected: ", scalar(@rd2), "\n";
  close(RD1) or print "Unable to close hello.txt after reading: $!\n";
  close(RD2) or print "Unable to close expected_hello.txt after reading: $!\n";
  exit;
}

for(my $i = 0; $i < scalar(@rd1); $i++) {
   # Try to take care of platform-specific issues with line endings.
   $rd1[$i] =~ s/\n//g;
   $rd2[$i] =~ s/\n//g;
   $rd1[$i] =~ s/\r//g;
   $rd2[$i] =~ s/\r//g;

   if($rd1[$i] ne $rd2[$i]) {
     print $i, "\n", $rd1[$i], "*\n", $rd2[$i], "*\n";
     $ok = 0;
     last;
   }
}

if(!$ok) {
  print "not ok 1 - hello.txt does not match expected_hello.txt\n";
  close(RD1) or print "Unable to close hello.txt after reading: $!\n";
  close(RD2) or print "Unable to close expected_hello.txt after reading: $!\n";
  exit;
}

print "ok 1\n";

close(RD1) or print "Unable to close hello.txt after reading: $!\n";
close(RD2) or print "Unable to close expected_hello.txt after reading: $!\n";
if(!unlink('hello.txt')) { print "Couldn't unlink hello.txt\n"}

$ok = 1;