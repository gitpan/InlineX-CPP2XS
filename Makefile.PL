use ExtUtils::MakeMaker;

my %options =
  (
  NAME     => 'InlineX::CPP2XS',
  PREREQ_PM => {
                'Inline'  => 0.45,
                'Inline::CPP'  => 0.25,
               },
  VERSION_FROM => 'CPP2XS.pm',
  );

WriteMakefile(%options);

eval {require Parse::RecDescent;};
unless($@) {
  if("$Parse::RecDescent::VERSION" > 1.94){
      warn "

      WARNING: 
        You have version $Parse::RecDescent::VERSION of Parse-RecDescent.
        If this module fails its tests (as is generally
        the case with this version of Parse-RecDescent),
        try installing version 1.94.

";
  }
}


