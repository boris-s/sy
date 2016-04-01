# coding: utf-8
# coding utf-8

# Multiplication table of quantities. It caches the results of reduction of
# the quantity terms (Quantity::Term instances) to the most favorable form.
# In general, a quantity term has quite infinite number of equivalents --
# quantity terms which express basically the same meaning. For example,
# the physical quantity of energy can be expressed as "Mass.Length.Time⁻²", or
# equivalently as "Mass.Acceleration", or as "Energy", or as "Power.Time" etc.
# It is easily seen that one could produce infinite number of such equivalent
# terms, and choosing the best can be difficult if we try to be serious about
# respecting the conventions of physics, chemistry and other user disciplines.
# The above mentioned quite intuitively represents quantity SY::Energy, but
# how about "Length.Time"? There is no well-known quantity corresponding to
# the term "Length.Time". We could expand the term into infinitely many forms,
# such as "Speed.Time²", or "Length.Speed.Acceleration⁻¹", but all of these
# somehow represent unnecessary complication as compared to "Length.Time".
# For that reason, the reduction result will be the unnamed quantity
# SY::Quantity[ Length: 1, Time: 1 ]. Combining physical, chemical and other
# quantities, I found, is the art filled with idiosyncrasies, which I am
# unable to formalize in advance, since I do not even know all possible units
# and quantities by heart, not talking about their multiplication rules. For
# that reason I reckon the multiplication table the best means of capturing
# these rules.
#
class SY::Quantity
  MULTIPLICATION_TABLE = Hash.new { |h, term|
    # The input of the multiplication table must be a quantity term.
    # We will try to simplify it first, and when it does not simplify
    # anymore, we will expand it. When no change can be produced by either
    # procedure, we will convert the result into a Quantity instance and
    # cache it in the table.
    simplified_term = term.simplify
    result = if simplified_term != term then
               # Change was produced by #simplify. Apply recursion.
               h[ simplified_term ]
             else
               # No change was produced by #simplify. Let's try #expand.
               expanded_term = term.expand
               if expanded_term != term then
                 # Change was produced by #expand. Apply recursion.
                 h[ expanded_term ]
               else
                 # No change was produced by #expand. We cannot reduce the term.
                 if term.empty? then
                   SY::Dimension.zero.standard_quantity
                 elsif term.size == 1 and term.values[0] == 1 then
                   # The term is of form { SomeQuantity: 1 }
                   term.keys[0] # unwrap the quantity
                 else
                   # We have to create new unnamed quantity.
                   SY::Quantity.new composition: term
                 end
               end
             end

    # FIXME: The above is a fairly naive algorithm in the spirit of
    # programmer's mathemathics. Think about it.

    # Now that I'm thinking about it, one way I let SY know the
    # conventions of the user fields is through :composition parameter
    # of SY::Quantity.new.
  }
end
