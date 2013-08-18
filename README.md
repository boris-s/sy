# SY - The physical units library.

The most prominent feature of `SY` is, that it extends the `Numeric` class with
methods corresponding to units and their abbreviations. At this place, let me
also make a polite mention of the other good library of physical units in Ruby,
[phys-units](https://github.com/masa16/phys-units), inspired by GNU units.

## Usage

Upon `require 'sy'`, we can say `5.metre`, or `Rational( 5, 2 ).metre`, and
the computer will understand, that these numbers represent magnitudes of
the physical quantity `SY::Length` expressed in the unit `SY::METRE`. Equally,
we can use abbreviations (such as `5.m`, `2.5.m`), prefixes (such as `5.km`,
`5.kilometre`, `5.km`), exponents (such as `5.m²` for 5 square metres), and
chaining (such as `5.m.s⁻¹` to denote speed of 5 metres per second). Please
read also the code file lib/sy.rb for the DSL statements defining default
quantities and their units.

## Unicode exponents

You should definitely learn how to type Unicode exponent characters, such
as `²`, `³`, `⁻¹` etc. It is possible to use alterantive syntax, such as
`5.m.s(-1)` instead of `5.m.s⁻¹`, but Unicode exponents should be used
everywere except non-reused code. Unicode exponents make the physical models
that you will be constructing with SY much more readable. And we know that
code is (typically) write once, read many times. So it pays off to type an
extra keystroke when writing to increase readability for the many subsequent
revisions.

## Method collisions

As a tribute to pragmatism (I like to think), `SY` extends Numeric with unit
methods and their abbreviations. The downside is, that since many of these are
short and common words, there can be collisions. For example, `ActiveSupport`
already provides handling for time units (hour, minute, second etc.), which
would collide with SY methods of the same name. Since `SY` relies on `method
_missing`, if these methods are already defined for numerics, `SY`'s
method_missing will not activate and ActiveSupport methods will be used. In
this particular case, `SY` methods still can be invoked using abbreviations
(`5.s`, `5.h`, `5.min`).

## Contributing

`SY` has been written emphasizing the object model over plentitude of defined
units. There is plenty of room for defining units thus far not defined by `SY`.
Also, the object model, though advanced, could possibly be refactored, eg. with
respect to the way that parametrized descendants of `Magnitude` are introduced.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request