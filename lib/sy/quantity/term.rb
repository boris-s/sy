# encoding: utf-8

# This class represents a product of a number of quantities raised to certain
# exponents. Represented as a hash subclass, whose keys are quantities and
# values are exponents. Please note that not all quantities can form products
# with other quantities. In order to be suitable for multiplication with
# other quantities, the function of a quantity needs to be a simple ratio
# (SY::Quantity::Ratio class).
#
class SY::Quantity::Term < Hash
  class << self
    # Presents class-owned instances (array)
    # 
    def instances
      return @instances ||= []
    end
    
    undef_method :new
    
    # A constructor of +SY::Quantity::Term+. Always returns the same object
    # for the same combination of quantities and their exponents.
    # 
    def [] *ordered_args, **hash
      # Validate arguments and enable variable input.
      input = if ordered_args.size == 0 then hash_args
              elsif ordered_args.size > 1 then
                fail ArgumentError, "SY::Quantity::Term[] constructor admits " +
                                    "at most 1 ordered argument!"
              else ordered[0] end
      # If input is a Term instance, return it unchanged.
      return input if input.is_a? self
      # It is assumed that input is a hash of pairs { quantity => exponent }.
      # Let's get rid of the edge case:
      return empty if input.size == 0
      # If there is only one quantity with exponent 1, return its base term.
      if input.size == 1 then
        quantity, exp = input.to_a.first
        return base( quantity ) if exp == 1
      end

      # FIXME: Now we have to ensure that all quantities have ratio-type
      # functions. Let's just assume they do for now.

      instance = instances.find { |i| i == input }
      unless instance
        instance = super input
        instances << instance
      end
      return instance
    end

    # def base quantity
    #   fail NotImplementedError
    # end

    # def empty
    #   fail NotImplementedError
    # end
  end

  # Base terms consist of only one quantity with exponent 1.
  # FIXME: Or do they consist of only one *standard* quantity with exponent 1?
  # 
  def base?
    fail NotImplementedError
  end

  # Negates hash exponents.
  # 
  def -@
    fail NotImplementedError
  end

  # For each term, there is at least one way of reducing it to
  # quantity. Empty term reduces to the standard dimensionless quantity. Base
  # terms reduce to their component quantity (they have only one). And as for
  # other terms, if no better reduction is available, they reduce to the
  # quantity implied by the sum of their dimensions and the product of their
  # functions (which must be of Quantity::Ratio type).
  #
  # Sometimes, better reductions are available. These are implied by quantity
  # compositions.
  # 
  def reduce_to_quantity
    return SY::Dimension.zero.standard_quantity if empty?
    return to_a.first.first if base?
    quantity_compositions.each { |composition|
     try_it_on self, :both_ways # that's depth 1 search
     # FIXME: more in-depth search is possible
     # the search is also not overly difficult.
     # Search is cached, but as soon as new quantity composition
     # is added, the cache should be cleared.

     # quantity compositions are added ... upon creation
     # of non-disposable (ie. named) quantities by quantity
     # multiplication or division, both by another quantity
     # and a number.
     #
     # ie. quantity compositions are created upon naming.
     # as soon as new quantity composition is defined,
     # caches need to be cleared (both Term reduce cache
     # and Quantity multiplication table).
    }
  end
end
