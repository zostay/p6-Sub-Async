use v6;

unit module Sub::Async;

multi trait_mod:<is> (Routine $r, :$async!) is export {
    $r.wrap(sub (|c --> Promise) { my $next = nextcallee; start { $next.(|c) } });
}
