use v6;

use lib $?FILE.IO.dirname;
require Install;
use Util;
use Test;
plan 1;

try require ::('META6');
skip-rest("No META6 package") and exit if ::('META6') ~~ Failure;
subtest 'works with META6 package' => {
    INIT  my $temp-dir = get-temp-dir('install-with-META6');
    LEAVE rm-temp-dir($temp-dir);
    plan 2;
    my %provides = (
        "Test::Thing" => "lib/some/thing",
        "Hello2" => "lib/world",
    );
    my @deps = [ "Test::Thing", "Hello2" ];
    my $meta6 = ::('META6').new(
        perl-version    => Version.new('6'),
        version         => Version.new('0.0.0'),
        name            => 'test',
        description     => 'a test',
        provides        => %provides,
        depends         => @deps,
    );
    my $meta6-file = $temp-dir.join('META6.json').IO;
    $meta6-file.spurt($meta6.to-json);

    my %modules = Install::extract-provided-modules($meta6-file.parent);
    is-deeply %modules, %provides, 'can extract module names and paths from META6.json';
    my @meta6-deps = Install::extract-dependencies($meta6-file.parent);
    is-deeply @meta6-deps, @deps, 'can extract dependencies from META6.json';
};

done-testing();

