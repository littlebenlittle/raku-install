use v6;

require Install;

sub get-temp-dir(IO() $path) {
    my $dir = "$*TMPDIR/{now.Int}/$path".IO;
    mkdir $dir unless $dir.d;
    $dir;
}

sub rm-temp-dir(IO() $path) {
    # TODO: implement 🤣 2020-03-12T13:20:17Z
    # This sub is not needed if running in a stateless environment
}

use Test;
plan 2;

# TODO: This may be deprecated if the structure META6.json changes 2020-03-12T12:31:23Z
subtest 'works without META6 package' => {
    INIT  my $temp-dir = get-temp-dir('install-wo-META6');
    LEAVE rm-temp-dir($temp-dir);
    plan 1;
    my %provides = (
        "Test::Thing" => "lib/some/thing",
        "Hello2" => "lib/world",
    );
    my $meta6-file = "$temp-dir/META6.json".IO;
    my $json-string = Rakudo::Internals::JSON.to-json((
        provides => %provides,
    ));
    $json-string ~~ rx:r/ '[' $<meta6>=(<-[ \] ]>+) ']' /;
    $meta6-file.spurt($/<meta6>.Str);
    my $repo = $meta6-file.parent.path;
    my %modules = Install::extract-provided-modules($repo);
    is-deeply %modules, %provides, 'can extract module names and paths from META6.json';
}

try require ::('META6');
skip-rest("No META6 package") and exit if ::('META6') ~~ Failure;
subtest 'works with META6 package' => {
    INIT  my $temp-dir = get-temp-dir('install-with-META6');
    LEAVE rm-temp-dir($temp-dir);
    plan 1;
    my %provides = (
        "Test::Thing" => "lib/some/thing",
        "Hello2" => "lib/world",
    );
    my $meta6 = ::('META6').new(
        perl-version => Version.new('6'),
        version => Version.new('0.0.0'),
        name => 'test',
        description => 'a test',
        provides => %provides,
    );
    my $meta6-file = $temp-dir.join('META6.json').IO;
    $meta6-file.spurt($meta6.to-json);
    my %modules = Install::extract-provided-modules($meta6-file.parent);
    is-deeply %modules, %provides, 'can extract module names and paths from META6.json';
};

done-testing();

