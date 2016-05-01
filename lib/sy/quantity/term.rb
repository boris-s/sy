# encoding: utf-8

# This class represents a product of a number of quantities raised
# to certain exponents. It is a hash subclass, whose keys are
# quantities and values exponents. Not every quantity can form
# products with other quantities. It is required that the function
# of the quantity be of SY::Quantity::Ratio subclass in order to be
# able of multiplication with other quantities.
#
class SY::Quantity::Term < Hash
  require_relative 'term/multiplication_table'
  require_relative 'term/nullary'
  require_relative 'term/unary'
  require_relative 'term/binary'

  class << self
    # Class Term keeps a registry of its instances. It is an array
    # stored in @instances variable available via this selector.
    # 
    def instances
      return @instances ||= []
    end

    undef_method :new

    # A constructor of +SY::Quantity::Term+. Always returns the
    # same object for the same combination of quantities and their
    # exponents.
    # 
    def [] *ordered, **named
      # Validate arguments and enable variable input.
      input = ordered_args ordered do
        case size
        when 0 then named
        when 1 then fetch 0
        else
          fail "Quantity term .[] constructor admits at most " +
               "1 ordered argument."
        end
      end

      # If input is a Term instance, return it unchanged.
      return input if input.is_a? self

      # If input is a Quantity instance, return its base term.
      return input.base_term if input.is_a? SY::Quantity
      # # Alternatively:
      # return base( input ) if input.is_a? SY::Quantity

      # From now on, we assume input is a hash { quantity => exp }
      # 
      # FIXME: It would seem we have to ensure that all quantities
      # have ratio-type functions. It is defined that in SY,
      # quantities with other than ratio-type functions cannot
      # form products with other quantities, and thus also cannot
      # take part in quantity terms. The question is to what extent
      # would duck typing take care of this problem at this
      # particular spot. I have tendency to perform type checking
      # here, but since I'm just exploring how to establish the
      # abstraction of the elusive concept of "quantity", I'll just
      # assume the supplied term is OK. For now, that is. That's
      # why that FIXME shines on the top of this paragraph.

      # Let's make sure we don't construct more than one term for
      # the same combinations of quantities and their exponents.
      instance = instances.find { |i| i == input }

      unless instance           # If instance wasn't found...
        # ... take use of the constructor inherited from Hash.
        instance = super input
        # And insert the instance to the registry.
        instances << instance
      end

      # Whether found or constructed, return the instance.
      return instance
    end

    # def base quantity
    #   fail NotImplementedError
    # end

    # def empty
    #   fail NotImplementedError
    # end
  end

  # Negates hash exponents.
  # 
  def invert
    fail NotImplementedError
  end

  # For each term, there is at least one way of reducing it to
  # quantity. Empty term reduces to the standard dimensionless
  # quantity. Base terms reduce to their component quantity (they
  # have only one). And as for other terms, if no better reduction
  # is available, they reduce to the quantity implied by the sum of
  # their dimensions and the product of their functions (which must
  # be of Quantity::Ratio type).
  #
  # Sometimes, better reductions are available. These are implied
  # by quantity compositions.
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

  def arity
    fail NotImplementedError
  end
end
