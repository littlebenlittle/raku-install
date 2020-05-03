use v6;

use lib $?FILE.IO.dirname;
require Install;
use Util;
use Test;
plan 1;

subtest 'get the urls corresponding to package names' => {
    INIT  my $temp-dir = get-temp-dir('dependency-repos');
    LEAVE rm-temp-dir($temp-dir);
    plan 1;
    my $package-directory-file = "$temp-dir/directory.kv";
    $package-directory-file.IO.spurt(qq:to/EOS/);
    Test::Thing=https://github.com/someuser/raku-test-thing
    Hello2=git@git-service/h2
    EOS
    my $repo = $temp-dir.IO.add('META6.json');
    emit-meta6(
        $repo,
        perl-version    => Version.new('6'),
        version         => Version.new('0.0.0'),
        name            => 'test',
        description     => 'a test',
        provides        => %( "Nothing" => "lib/nothing.rakumod" ),
        depends         => [ "Test::Thing", "Hello2" ],
    );
    my $urls = Install::get-dependency-urls($repo.dirname, $package-directory-file);
    is-deeply $urls, {
        'Test::Thing' => 'https://github.com/someuser/raku-test-thing',
        'Hello2'      => 'git@git-service/h2',
    }, 'urls look good';
};

done-testing();

