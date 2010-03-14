use inc::Module::Install;
  
  # Define metadata
name           'Action-Generic';
license        'perl';
all_from       'lib/Action/Generic.pm';
  
  # Specific dependencies
requires       'File::Find::Rule'  => '0.32';
requires       'Moose'             => '0.98';
requires       'Module::Pluggable' => 0;
requires       'Carp'              => 0;
test_requires  'Test::More'  => '0.42';

WriteAll;
