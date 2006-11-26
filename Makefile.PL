use ExtUtils::MakeMaker;

my %options =
  (
  NAME     => 'InlineX::CPP2XS',
  PREREQ_PM => {
                'Inline::CPP'  => 0.25,
               },
  VERSION_FROM => 'CPP2XS.pm',
  );

WriteMakefile(%options);
