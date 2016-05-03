# coding: utf-8
# coding utf-8

# Multiplication table of quantities is a composition table that
# caches the optimum term reductions. Simplifying quantity terms is
# no simple matter and when a proper simplification of a term is
# found, we want to cache it so as not to repeat the work later.
# This strategy works well as soon as the predefined quantity
# compositions (defined whenever a composed quantity is introduced)
# are stable. However, this cache must be emptied whenever a new
# composed quantity is defined and, consequently, table of standard
# compositions is updated.
#
class SY::Quantity
  # Multiplication table is kept in @table class-owned instance
  # variable. We do not really like constants, do we?
  @table = SY::Quantity::Composition::Table.new

  class << self
    selector :table
    alias multiplication_table table
  end
end # SY::Quantity.table

# Legacy code.
# 
class SY::Quantity
  MULTIPLICATION_TABLE = Hash.new { |h, term|
    # The input of the multiplication table must be a quantity
    # term.  We will try to simplify it first, and when it does not
    # simplify anymore, we will expand it. When no change can be
    # produced by either procedure, we will convert the result into
    # a Quantity instance and cache it in the table.
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
end # SY::Quantity legacy code
