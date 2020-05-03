use v6;

use lib $?FILE.IO.dirname;
require Install;
use Util;
use Test;
plan 2;

subtest 'parse a kv directory file' => {
    INIT  my $temp-dir = get-temp-dir('install-wo-META6');
    LEAVE rm-temp-dir($temp-dir);
    plan 1;
    my $package-directory = "$temp-dir/directory.kv";
    # emit a directory file in kv format
    $package-directory.IO.spurt(qq:to/EOS/);
    MyModule=https://git-service/raku-my-module
    Some::Thing=https://other-git-service:3333/raku-some-thing
    My2=https://github.com/my2
    EOS
    # read the kv from it using the Install API
    my $packages = Install::parse-package-directory-file($package-directory);
    # verify they match what was emitted
    is-deeply $packages, {
        'MyModule'    => 'https://git-service/raku-my-module',
        'Some::Thing' => 'https://other-git-service:3333/raku-some-thing',
        'My2'         => 'https://github.com/my2',
    }, 'correctly parse package urls';
};

subtest 'parse another kv directory file' => {
    INIT  my $temp-dir = get-temp-dir('install-wo-META6');
    LEAVE rm-temp-dir($temp-dir);
    plan 1;
    my $package-directory = "$temp-dir/other-directory.kv";
    $package-directory.IO.spurt(qq:to/EOS/);
    Mod::Here=https://git-service/mod-here
    EOS
    # read the kv from it using the Install API
    my $packages = Install::parse-package-directory-file($package-directory);
    # verify they match what was emitted
    is-deeply $packages, {
        'Mod::Here' => 'https://git-service/mod-here'
    }, 'correctly parse package urls';
};

done-testing();

