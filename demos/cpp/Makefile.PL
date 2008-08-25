use ExtUtils::MakeMaker;
my %options = %{       
{
  'TYPEMAPS' => [
    'C:\\perl58_M\\lib\\ExtUtils\\typemap',
    'C:\\_32\\working\\inlinex-cpp2xs\\InlineX-CPP2XS-0.13\\demos\\cpp\\CPP.map'
  ],
  'NAME' => 'Math::Geometry::Planar::GPC::Inherit',
  'CC' => 'g++',
  'LIBS' => [
    '-lstdc++'
  ],
  'INC' => '-IC:/_32/working/inlinex-cpp2xs/InlineX-CPP2XS-0.13/demos/cpp',
  'VERSION' => '0.11'
}
};
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
