use v6;

unit module Sub::Async;

=begin pod

=head1 NAME

Sub::Async - trait to turn any routine asynchronous

=head1 SYNOPSIS

    use Sub::Async;

    sub add(Numeric $x, Numeric $y --> Numeric) is async { $x + $y }

    class NumberThing {
        has Numeric $.value;

        method classy-add(NumberThing $o --> NumberThing) is async {
            NumberThing.new(value => $!value + $o.value);
        }
    }

    my $sum = await add(1, 2);

    my $number1 = NumberThing.new(:1value);
    my $number2 = NumberThing.new(:2value);
    my $number3 = await $number1.classy-add($number2);

=head1 DESCRIPTION

This module provides a trait that can turn any generic method into an
asynchronous method. Without this module, you might write:

    sub add($x, $y) { start { $x + $y } }

but with this module, this is effectively identical:

    sub add($x, $y) is async { $x + $y }

You may find the latter more appealing.

This works on any routine, so you can apply this trait to subroutines, multis,
or methods, but not to code blocks or generic callables.

=head1 CAVEATS

This interface is not problem free. The routine that has this trait applied will
lose the specificity of its signature. This is because the wrapper is, as of
this writing, pretty dumb. The signature of the wrapper is basically always:

    :(| --> Promise:D)

So, the wrapped routine will accept any arguments without causing a type error.
The type error will occur, but it will occur when the caller performs the
C<await> on the returned L<Promise>. When that is performed, the exception
thrown by the incorrect arguments will appear. This also means all argument
checking will be performed at runtime rather than compile time.

If any of that is a problem for you, you should stick to using an explicit
C<start {}> block or suggest send me a pull request with a patch that makes this
trait able to generate a matching signature on the wrapping routine.

=end pod

multi trait_mod:<is> (Routine $r, :$async!) is export {
    $r.wrap(sub (|c --> Promise:D) { my $next = nextcallee; start { $next.(|c) } });
}
