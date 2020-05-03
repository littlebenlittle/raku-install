use v6;

use lib $?FILE.IO.dirname;
require Install;
use Util;
use Test;
plan 1;

# TODO: This may be deprecated if the structure META6.json changes 2020-03-12T12:31:23Z
subtest 'works without META6 package' => {
    INIT  my $temp-dir = get-temp-dir('install-wo-META6');
    LEAVE rm-temp-dir($temp-dir);
    plan 1;
    my %provides = (
        "Test::Thing" => "lib/some/thing",
        "Hello2" => "lib/world",
    );
    my @deps = [ "Test::Thing", "Hello2" ];
    my $meta6-file = "$temp-dir/META6.json".IO;
    my $json-string = Rakudo::Internals::JSON.to-json(%(
        provides => %provides,
        depends  => @deps,
    ));
    $meta6-file.spurt($json-string);
    my $repo = $meta6-file.parent.path;
    my %modules = Install::extract-provided-modules($repo);
    is-deeply %modules, %provides, 'can extract module names and paths from META6.json';
}

done-testing();

