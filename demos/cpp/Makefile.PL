use ExtUtils::MakeMaker;
my %options = %{       
{
  'TYPEMAPS' => [
    'F:\\Perl58_M\\5.8.8\\lib\\ExtUtils\\typemap',
    'CPP.map',
    'F:\\InlineX-C2XS\\InlineX-CPP2XS-0.10\\demos\\cpp\\CPP.map'
  ],
  'NAME' => 'Math::Geometry::Planar::GPC::Inherit',
  'CC' => 'g++',
  'LIBS' => [
    '-lstdc++'
  ],
  'INC' => '-IF:/InlineX-C2XS/InlineX-CPP2XS-0.10/demos/cpp',
  'VERSION' => '0.11'
}
};
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
