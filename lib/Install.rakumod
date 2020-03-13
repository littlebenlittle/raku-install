use v6;

unit package Install:auth<littlebenlittle>:ver<0.0.0>;

my $RAKULIB     = '/raku/lib';
my $RAKUBIN     = '/raku/bin';
my $MOD-SUFFIX  = '.rakumod';

sub from-json { Rakudo::Internals::JSON.from-json($^a) }
sub join-path(|a) { a.flat.join( '/' ).IO }

sub MAIN(IO() $repo) is export {
    my %modules = extract-provided-modules($repo);
    for %modules.kv -> $name, $relative-path {
        next unless $name ~~ rx:r:i/ $<path>=(<.alnum>+)+ % '::' /;
        my $from = join-path($repo, $relative-path);
        my $to   = join-path($RAKULIB, $/<path>.map: *.Str) ~ $MOD-SUFFIX;
        install-file($from, $to);
    }
    for $repo.dir -> $path {
        if $path.basename eq 'bin' {
            for $path.dir -> $path {
                next unless $path.f;
                my $from = $path;
                my $to   = join-path($RAKUBIN, $path.basename);
                install-file($from, $to) && $to.chmod: 0o744;
            }
        }
    }
}

our sub install-file(IO() $from, IO() $to) {
    mkdir $to.dirname unless $to.parent.d;
    if $to.e {
        if $from.modified < $to.modified {
            note "path $to already exists and is newer than $from; skipping";
            return;
        }
        note "$from is newer than $to; deleting and copying";
        $to.unlink;
    }
    $from.copy: $to;
    note "copied $from => $to";
    return
}

our sub extract-provided-modules(IO() $repo) {
    my $meta6-path = join-path($repo, 'META6.json');
    die "No META6.json found in $repo" unless $meta6-path.IO.f;
    try require ::('META6');
    if ::('META6') ~~ Failure {
        my %config = from-json($meta6-path.IO.slurp);
        return %config<provides>.list;
    }
    my $meta6 = ::('META6').new($meta6-path);
    return $meta6.provides.list;
}

