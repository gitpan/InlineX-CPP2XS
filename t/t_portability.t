use warnings;
use strict;
use InlineX::CPP2XS qw(cpp2xs);

print "1..64\n";

my $bd = 'demos/cpp2xs_utility';
my ($emanif, $epm, $exs, $eauto, $etest, $emap, $emake);
my @w = qw(FastSieve.pm FastSieve.xs MANIFEST CPP.map ilcpptest.cpp auto_include.in Makefile.PL);

my %config_opts = (
                  'DIST' => 1,
                  'VERSION' => 0.07,
                  'EXPORT_OK_ALL' => 1,
                  'SRC_LOCATION' => "demos/cpp2xs_utility/src/FastSieve.cpp",
                  );

cpp2xs('Math::Prime::FastSieve', 'Math::Prime::FastSieve', $bd, \%config_opts);

if(-f "$bd/MANIFEST") {
  $emanif = 1;
  print "ok 1\n";
}
else {print "not ok 1\n"}

if($emanif) {
  open RDM, '<', "$bd/MANIFEST" or die "Can't open $bd/MANIFEST for reading: $!";
  my @h = <RDM>;
  close RDM or die "Can't close ./$bd/MANIFEST after reading: $!";
  chomp for @h;
  my $i = 2;
  ##############
  for my $w(@w) {
    my $ok = 0;
    for my $h(@h) {
      $ok = 1 if $h eq $w;
    }
    if($ok) {print "ok $i\n"}
    else {
      warn "Couldn't find $w in the MANIFEST file\n";
      print "not ok $i\n";
    }
    $i++;   
  }
  ##############
  for my $h(@h) {
    my $ok = 0;
    for my $w(@w) {
      $ok = 1 if $h eq $w;
    }
    if($ok) {print "ok $i\n"}
    else {
      warn "Couldn't find $h in the list of expected files\n";
      print "not ok $i\n";
    }
    $i++;   
  }
  ##############
}
else {
warn "\nSkipping tests 2 to 15 - no MANIFEST was written\n";
for(2 .. 15) {print "ok $_\n"}
}

if(!unlink "$bd/MANIFEST") {warn "Failed to unlink $bd/MANIFEST : $!\n"}
if(-f "$bd/MANIFEST") {
  print "not ok 16\n";
}
else {print "ok 16\n"}

if(-f "$bd/FastSieve.pm") {
  $epm = 1;
  print "ok 17\n";
}
else {print "not ok 17\n"}

if($epm) {
  my $nok = system $^X, '-c', "$bd/FastSieve.pm";
  if($nok) {
    warn "Unable to successfully compile $bd/FastSieve.pm: $nok\n";
    print "not ok 18\n";
  }
  else {print "ok 18\n"}
}
else {
  warn "\nSkipping test 18 - FastSieve.pm was not written\n";
  print "ok 18\n";
}

if(!unlink "$bd/FastSieve.pm") {warn "Failed to unlink $bd/FastSieve.pm : $!\n"}
if(-f "$bd/FastSieve.pm") {
  print "not ok 19n";
}
else {print "ok 19\n"}

if(-f "$bd/FastSieve.xs") {
  $exs = 1;
  print "ok 20\n";
}
else {print "not ok 20\n"}

if($exs) {
  open RDXS, '<', "$bd/FastSieve.xs" or die "Couldn't open $bd/FastSieve.xs for reading: $!";
  my @rdxs = <RDXS>;
  close RDXS or die "Couldn't close $bd/FastSieve.xs after reading: $!";
  if(@rdxs < 200) {
    warn "$bd/FastSieve.xs is too small\n";
    print "not ok 21\n";
  }
  else {print "ok 21\n"}
  my $ok = 1;
  for(@rdxs) {$ok = 0 if $_ =~ /__INLINE_CPP/}
  if($ok) {print "ok 22\n"}
  else {print "not ok 22\n"}
}
else {
  warn "\nSkipping tests 21 and 22 - $bd/FastSieve.xs was not written\n";
  print "ok 21\n";
  print "ok 22\n";
}

if(!unlink "$bd/FastSieve.xs") {warn "Failed to unlink $bd/FastSieve.xs : $!\n"}
if(-f "$bd/FastSieve.pm") {
  print "not ok 23\n";
}
else {print "ok 23\n"}

if(-f "$bd/auto_include.in") {
  $eauto = 1;
  print "ok 24\n";
}
else {print "not ok 24\n"}

if($eauto) {
  open RDAUTO, '<', "$bd/auto_include.in" or die "Couldn't open $bd/auto_include.in for reading: $!";
  my @rdauto = <RDAUTO>;
  close RDAUTO or die "Couldn't close $bd/auto_include.in for reading: $!";
  if(@rdauto < 12) {
    warn "$bd/auto_include.in is too small\n";
    print "not ok 25\n";
  }
  else {
    print "ok 25\n";
  }
  my $ok = 1;
  for(@rdauto) {
    if($_ =~ /__INLINE_CPP/) {$ok = 0}
  }
  if($ok) {print "ok 26\n"}
  else {print "not ok 26\n"}
}
else {
  warn "\nSkipping tests 25 and 26 - no auto_include.in was written\n";
  print "ok 25\n";
  print "ok 26\n";
}

if(!unlink "$bd/auto_include.in") {warn "Failed to unlink $bd/auto_include.in : $!\n"}
if(-f "$bd/auto_include.in") {
  print "not ok 27\n";
}
else {print "ok 27\n"}

if(-f "$bd/Makefile.PL") {
  $emake = 1;
  print "ok 28\n";
}
else {print "not ok 28\n"}

if($emake) {
  open RDMAKE, '<', "$bd/Makefile.PL" or die "Can't open $bd/Makefile.PL for reading: $!";
  my @rdmake = <RDMAKE>;
  close RDMAKE or die "Can't close $bd/Makefile.PL after reading: $!";
  if(@rdmake < 120) {
    warn "$bd/Makefile.PL is too small\n";
    print "not ok 29\n";
  }
  else {print "ok 29\n"}

  my $nok = system $^X, '-c', "$bd/Makefile.PL";
  if($nok) {
    warn "Unable to successfully compile $bd/Makefile.PL: $nok\n";
    print "not ok 30\n";
  }
  else {print "ok 30\n"}
}
else {
  warn "\nSkipping tests 29 and 30 - no Makefile.PL written\n";
  print "ok 29\n";
  print "ok 30\n";
}

if(!unlink "$bd/Makefile.PL") {warn "Failed to unlink $bd/Makefile.PL : $!\n"}
if(-f "$bd/Makefile.PL") {
  print "not ok 31\n";
}
else {print "ok 31\n"}

if(-f "$bd/CPP.map") {
  $emap = 1;
  print "ok 32\n";
}
else {print "not ok 32\n"}

if($emap) {
  open RDMAP, '<',"$bd/CPP.map" or die "Couldn't open $bd/CPP.map for reading: $!";
  my @rdmap = <RDMAP>;
  close RDMAP or die "Couldn't close $bd/CPP.map after reading: $!";
  if(@rdmap < 6) {
    warn "$bd/CPP.map is too small\n";
    print "not ok 33\n";
  }
  else {print "ok 33\n"}
}
else {
  warn "\nSkipping test 33 - no $bd/CPP.map was written\n";
  print "ok 33\n";
}

if(!unlink "$bd/CPP.map") {warn "Failed to unlink $bd/CPP.map : $!\n"}
if(-f "$bd/CPP.map") {
  print "not ok 34\n";
}
else {print "ok 34\n"}

if(-f "$bd/ilcpptest.cpp") {
  $etest = 1;
  print "ok 35\n";
}
else {print "not ok 35\n"}

if($etest) {
  open RDTEST, '<',"$bd/ilcpptest.cpp" or die "Couldn't open $bd/ilcpptest.cpp for reading: $!";
  my @rdtest = <RDTEST>;
  close RDTEST or die "Couldn't close $bd/ilcpptest.cpp after reading: $!";
  if(@rdtest < 3) {
    warn "$bd/ilcpptest.cpp is too small\n";
    print "not ok 36\n";
  }
  else {print "ok 36\n"}
}
else {
  warn "\nSkipping test 36 - no $bd/ilcpptest.cpp was written\n";
  print "ok 36\n";
}

if(!unlink "$bd/ilcpptest.cpp") {warn "Failed to unlink $bd/ilcpptest.cpp: $!\n"}
if(-f "$bd/ilcpptest.cpp") {
  print "not ok 37\n";
}
else {print "ok 37\n"}

#########  ###########     ################ ###   
#########  ###########     ################ ###
#########  ###########     ################ ###
#########  ###########     ################ ###

$bd = 'demos/cpp2xs_utility/mybuild';
($emanif, $epm, $exs, $emap, $emake) = (0, 0, 0, 0, 0);
@w = qw(FastSieve.pm FastSieve.xs MANIFEST CPP.map Makefile.PL);

%config_opts =    (
                  'WRITE_MAKEFILE_PL' => 1,
                  'WRITE_PM' => 1,
                  'MANIF' => 1,
                  'VERSION' => 0.07,
                  'EXPORT_OK_ALL' => 1,
                  'SRC_LOCATION' => "demos/cpp2xs_utility/src/FastSieve.cpp",
                  );

cpp2xs('Math::Prime::FastSieve', 'Math::Prime::FastSieve', $bd, \%config_opts);

if(-f "$bd/MANIFEST") {
  $emanif = 1;
  print "ok 38\n";
}
else {print "not ok 38\n"}

if($emanif) {
  open RDM, '<', "$bd/MANIFEST" or die "Can't open $bd/MANIFEST for reading: $!";
  my @h = <RDM>;
  close RDM or die "Can't close ./$bd/MANIFEST after reading: $!";
  chomp for @h;
  my $i = 39;
  ##############
  for my $w(@w) {
    my $ok = 0;
    for my $h(@h) {
      $ok = 1 if $h eq $w;
    }
    if($ok) {print "ok $i\n"}
    else {
      warn "Couldn't find $w in the MANIFEST file\n";
      print "not ok $i\n";
    }
    $i++;   
  }
  ##############
  for my $h(@h) {
    my $ok = 0;
    for my $w(@w) {
      $ok = 1 if $h eq $w;
    }
    if($ok) {print "ok $i\n"}
    else {
      warn "Couldn't find $h in the list of expected files\n";
      print "not ok $i\n";
    }
    $i++;   
  }
  ##############
}
else {
warn "\nSkipping tests 2 to 15 - no MANIFEST was written\n";
for(39 .. 48) {print "ok $_\n"}
}

if(!unlink "$bd/MANIFEST") {warn "Failed to unlink $bd/MANIFEST : $!\n"}
if(-f "$bd/MANIFEST") {
  print "not ok 49\n";
}
else {print "ok 49\n"}

if(-f "$bd/FastSieve.pm") {
  $epm = 1;
  print "ok 50\n";
}
else {print "not ok 50\n"}

if($epm) {
  my $nok = system $^X, '-c', "$bd/FastSieve.pm";
  if($nok) {
    warn "Unable to successfully compile $bd/FastSieve.pm: $nok\n";
    print "not ok 51\n";
  }
  else {print "ok 51\n"}
}
else {
  warn "\nSkipping test 51 - FastSieve.pm was not written\n";
  print "ok 51\n";
}

if(!unlink "$bd/FastSieve.pm") {warn "Failed to unlink $bd/FastSieve.pm : $!\n"}
if(-f "$bd/FastSieve.pm") {
  print "not ok 52n";
}
else {print "ok 52\n"}

if(-f "$bd/FastSieve.xs") {
  $exs = 1;
  print "ok 53\n";
}
else {print "not ok 53\n"}

if($exs) {
  open RDXS, '<', "$bd/FastSieve.xs" or die "Couldn't open $bd/FastSieve.xs for reading: $!";
  my @rdxs = <RDXS>;
  close RDXS or die "Couldn't close $bd/FastSieve.xs after reading: $!";
  if(@rdxs < 200) {
    warn "$bd/FastSieve.xs is too small\n";
    print "not ok 54\n";
  }
  else {print "ok 54\n"}
  my $ok = $Inline::CPP::Config::cpp_flavor_defs;
  $ok = 0;
  if($Inline::CPP::Config::cpp_flavor_defs =~ /__INLINE_CPP/) {
    for(@rdxs) {
      $ok = 1 if $_ =~ /__INLINE_CPP/;
    }
  }
  else {
    $ok = 1;
    for(@rdxs) {
      $ok = 0 if $_ =~ /__INLINE_CPP/;
    }
  }

  if($ok) {print "ok 55\n"}
  else {print "not ok 55\n"}
}
else {
  warn "\nSkipping tests 54 and 55 - $bd/FastSieve.xs was not written\n";
  print "ok 54\n";
  print "ok 55\n";
}

if(!unlink "$bd/FastSieve.xs") {warn "Failed to unlink $bd/FastSieve.xs : $!\n"}
if(-f "$bd/FastSieve.pm") {
  print "not ok 56\n;"
}
else {print "ok 56\n"}

if(-f "$bd/auto_include.in") {
  print "not ok 57\n";
  warn "Couldn't unlink $bd/auto_include.in\n"
    unless unlink "$bd/auto_include.in";
}
else {print "ok 57\n"}

if(-f "$bd/Makefile.PL") {
  $emake = 1;
  print "ok 58\n";
}
else {print "not ok 58\n"}

if($emake) {
  open RDMAKE, '<', "$bd/Makefile.PL" or die "Can't open $bd/Makefile.PL for reading: $!";
  my @rdmake = <RDMAKE>;
  close RDMAKE or die "Can't close $bd/Makefile.PL after reading: $!";
  if(@rdmake < 4 || @rdmake > 50) {
    warn "$bd/Makefile.PL is not the right size\n";
    print "not ok 59\n";
  }
  else {print "ok 59\n"}

  my $nok = system $^X, '-c', "$bd/Makefile.PL";
  if($nok) {
    warn "Unable to successfully compile $bd/Makefile.PL: $nok\n";
    print "not ok 60\n";
  }
  else {print "ok 60\n"}
}
else {
  warn "\nSkipping tests 59 and 60 - no Makefile.PL written\n";
  print "ok 59\n";
  print "ok 60\n";
}

if(!unlink "$bd/Makefile.PL") {warn "Failed to unlink $bd/Makefile.PL : $!\n"}
if(-f "$bd/Makefile.PL") {
  print "not ok 61\n";
}
else {print "ok 61\n"}

if(-f "$bd/CPP.map") {
  $emap = 1;
  print "ok 62\n";
}
else {print "not ok 62\n"}

if($emap) {
  open RDMAP, '<',"$bd/CPP.map" or die "Couldn't open $bd/CPP.map for reading: $!";
  my @rdmap = <RDMAP>;
  close RDMAP or die "Couldn't close $bd/CPP.map after reading: $!";
  if(@rdmap < 6) {
    warn "$bd/CPP.map is too small\n";
    print "not ok 63\n";
  }
  else {print "ok 63\n"}
}
else {
  warn "\nSkipping test 63 - no $bd/CPP.map was written\n";
  print "ok 63\n";
}

if(!unlink "$bd/CPP.map") {warn "Failed to unlink $bd/CPP.map : $!\n"}
if(-f "$bd/CPP.map") {
  print "not ok 64\n";
}
else {print "ok 64\n"}

