# SY - The physical units library.

`SY` is a domain model of physical units. It can be used in two modes:

  * When loaded by `require 'sy'`, Numeric class is extended with methods
    corresponding to units and their abbreviations.
  * When loaded by `require 'sy/noinclude'`, built-in classes are not modified,
    while physical magnitudes can still be contructed explicitly from the
    appropriate physical quantities.

At this place, good manners require me to mention the other good library of
physical units in Ruby, [phys-units](https://github.com/masa16/phys-units).

## Usage

Upon `require 'sy'`, we can say `5.metre`, or `Rational( 5, 2 ).metre`, and the
computer will understand, that these numbers represent magnitudes of the
physical quantity `SY::Length` expressed in the unit `SY::METRE`. Equally,
we can use abbreviations (such as `5.m`, `2.5.m`), prefixes (such as `5.km`,
`5.kilometre`, `5.km`), exponents (such as `5.m²` for 5 square metres), and
chaining (such as `5.m.s⁻¹` to denote speed of 5 metres per second). Please
read also the code file lib/sy.rb for the DSL statements defining default
quantities and their units.

## Unicode exponents

Users of `sy` should learn how to type Unicode exponent characters, such as `²`,
 `³`, `⁻¹` etc. It is possible to use alterantive syntax, such as `5.m.s(-1)`
instead of `5.m.s⁻¹`, but Unicode exponents should be used everywere except
non-reused code. Unicode exponents make the physical models that you will be
constructing with SY much more readable. And we know that code is (typically)
write once, read many times. So it pays off to type an extra keystroke when
writing to increase readability for the many subsequent revisions.

## Method collisions

If `sy` is used in the mode that extends Numeric with unit methods, then since
many of these are short and common words, there can be collisions. For example,
`ActiveSupport` already provides handling for time units (hour, minute, second
etc.), which would collide with SY methods of the same name. Since `SY` relies
on `method_missing`, if these methods are already defined for numerics, `SY`'s
method_missing will not activate and ActiveSupport methods will be used. In this
particular case, `SY` methods still can be invoked using abbreviations (`5.s`,
`5.h`, `5.min`).

## Noinclude mode

When _noinclude_ mode is activated by calling `require 'sy/noinclude'`, methods
such as `5.metre` cannot be used. Instead, the magnitude has to be constructed
explicitly:
```ruby
  mgn = SY::Length.magnitude( 5 )
```
Another effect of _noinclude_ mode is, that one cannot perform conversions using
unit symbols, as in `SY::WATTHOUR.in( :J )`, but instead one has to write:
```ruby
  SY::WATTHOUR.in( SY::JOULE )
```

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