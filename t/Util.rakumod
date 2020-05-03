
#| Utility functions for Install tests
unit module Util;

our sub get-temp-dir(IO() $path) is export {
    my $dir = "$*TMPDIR/{now.Int}/$path".IO;
    mkdir $dir unless $dir.d;
    $dir;
}

our sub rm-temp-dir(IO() $path) is export {
    # TODO: implement 🤣 2020-03-12T13:20:17Z
    # This sub is not needed if running in a stateless environment
}

our sub emit-meta6(IO() $path, *%args) is export {
    try require ::('META6');
    my $out = ::('META6') ~~ Failure
           ?? Rakudo::Internals::JSON.to-json(%args)
           !! ::('META6').new(%args).to-json;
    $path.spurt($out);
}

