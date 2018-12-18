use v6;

use Test;
use Sub::Async;

sub sum(Numeric $x, Numeric $y --> Numeric) is async {
    $x + $y;
}

my $p = sum(4, 11);
isa-ok $p, Promise;

my $i = await $p;
isa-ok $i, Int;

is $i, 15, 'awaited async method';
