use v6;

my $INSTALL-DIR = $*ENV<RAKULIB>  // '/raku/lib';
my $MOD-SUFFIX  = '.rakumod';

sub from-json { Rakudo::Internals::JSON.from-json($^a) }
sub join-path(|a) { a.flat.join( '/' ) }

sub MAIN($repo) is export {
    my %modules = extract-provided-modules($repo);
    for %modules.kv -> $name, $relative-path {
        next unless $name ~~ rx:r:i/ $<path>=(<.alpha>+)+ % '::' /;
        my $from = join-path($repo, $relative-path);
        my $to   = join-path($INSTALL-DIR, $/<path>.map: *.Str) ~ $MOD-SUFFIX;
        install-module($from, $to);
    }
}

sub install-module(IO() $from, IO() $to) {
    mkdir $to.dirname unless $to.parent.d;
    if $to.e {
        note "path $to already exists";
    }
    else {
        $from.copy: $to;
    }
}

sub extract-provided-modules($repo) {
    my $path = join-path($repo, 'META6.json');
    die "Path not found: $path" unless $path.IO.f;
    my %config = from-json($path.IO.slurp);
    return %config<provides>;
}

