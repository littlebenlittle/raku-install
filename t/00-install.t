use v6;
use Test;

require Install;

my $tmpdir-path;
INIT {
    $tmpdir-path = "$*TMPDIR/{now.Int}";
    note "trying to make $tmpdir-path";
    mkdir $tmpdir-path
      and note "created $tmpdir-path"
      or  die "could not create $tmpdir-path: $!"
    unless $tmpdir-path.IO.d;
}
LEAVE {
    note "cannot find $tmpdir-path for deletion"
    unless $tmpdir-path.?d;
    $tmpdir-path.unlink
      and note "deleted $tmpdir-path"
      or  die "could not delete $tmpdir-path: $!"
    if $tmpdir-path.?d;
}

try require ::('META6');
plan 1;
skip-rest("No META6 package") and exit if ::('META6') ~~ Failure;
subtest 'can extract module names and paths from META6.json' => {
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
    my $meta6-file = "$tmpdir-path/META6.json".IO;
    $meta6-file.spurt($meta6.to-json);
    my %modules = Install::extract-provided-modules($meta6-file.parent);
    is-deeply %modules, %provides;
};

done-testing();

