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

    # The main constructor of +SY::Quantity::Term+. Always returns
    # the same object for the same combination of quantities and
    # their exponents.
    # 
    def [] *ordered, **named
      input = ordered_args ordered do
        » "processing arguments of constructor Quantity::Term#[]"
        case size
        when 0 then
          » "the input was a hash assumed to consist of pairs " +
            "{ quantity => exp}, indicating a valid quantity term"
          "a quantity term expressed as a hash".( named )
        when 1 then
          » "the input was a single ordered argument"
          "arg. of Quantity::Term#[] constructor".( fetch 0 )
        else
          fail "Quantity term .[] constructor admits at most " +
               "1 ordered argument."
        end
      end.try do
        case self
        when SY::Quantity::Term then return itself
        when SY::Quantity then return base_term # or base( itself )
        when String then
          » "the arg. was found to be a string and assumed " +
            "to be a valid superscripted product string" 
          SY::Quantity::Sps.parse( itself )
        else
          » "the argument was assumed to be non-hash collection " +
            "of pairs indicating a quantity term"
          itself
        end
      end
      # Make sure the same instance is returned for the same input.
      instance = instances.find { |i| i == input }
      # If no instance is found, create it and register it.
      if instance.nil? then
        instance = super input
        instances << instance
      end
      # Whether found or created, return the instance.
      return instance
      # FIXME: It would seem we have to ensure that all quantities
      # have ratio-type functions. It is defined that in SY,
      # quantities with other than ratio-type functions cannot form
      # products with other quantities, and thus also cannot take
      # part in quantity terms. The question is to what extent
      # would duck typing take care of this problem at this
      # particular spot. I have tendency to perform type checking
      # here, but since I'm just exploring how to establish the
      # abstraction of the elusive concept of "quantity", I'll just
      # assume the supplied term is OK. For now, that is. That's
      # why that FIXME shines on the top of this paragraph.
    end # def []

    # Constructs a base quantity term (unary term with exponent 1).
    # 
    def base quantity
      # FIXME: Write the tests.
      self[ quantity => 1 ]
    end
    alias simple base

    # Constructs a null (empty) quantity term.
    def empty
      # FIXME: Write the tests.
      self[ {} ]
    end
    alias null empty
  end # class << self

  # Inquirer whether the term is simple. The terms are simple when
  # they are of arity 1 (consist of only one quantity) and their
  # exponent is 1.
  # 
  def simple?
    size == 1 and first[1] == 1
  end
  alias base? simple?

  # Inquire whether the term is nullary, ie. empty.
  # 
  alias nullary? empty?
  alias null? nullary?

  # Negates hash exponents.
  # 
  def invert
    fail NotImplementedError
  end

  # For each term, infinitely many equivalent terms can be found,
  # but some are better than others. Conversion of mathematical
  # expressions into the preferrable form is generally called
  # "simplification", and therefrom comes the name of this method.
  # It does not mean that an apparently more complex term may never
  # be preferred to its apparently simpler equivalent.
  # 
  # For example, quantity term "Mass.Length².Time⁻²" is equivalent
  # to "Force.Length" or "Power.Time", but the simplest way to
  # express it is by "Energy". But this only holds if a composed
  # quantity named energy is already defined. Otherwise, we do not
  # want to wantonly simplify "Mass.Length².Time⁻² into
  # "Force.Length" or "Momentum.Time⁻¹.Length" just because the sum
  # of their exponents is smaller. If the term can't be simplified
  # all the way down to "Energy", the version consisting of the
  # standard quantities of the base dimensions is preferred.
  #
  # FIXME: It seems that simplification of quantity terms is no
  # simple matter and we'll have to proceed by writing the examples
  # and precedents into acceptance tests and hacking and tweaking
  # this method until it complies with as many of such tests as we
  # dare to write.
  # 
  def simplify
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

  # Every term can be converted to a composed quantity using itself
  # as the quantity composition. This is done by this
  # method. However, simple terms (consisting of only one quantity
  # with exponent 1) are converted directly to that quantity.
  # 
  def to_quantity
    # FIXME: Write tests for this method!
    if simple? then first.first
    elsif null? then SY::Amount
    else
      # Call that constructor of composed quantities, which I have
      # not either written or even thought about what its exact
      # syntax would be.
      fail NotImplementedError
    end
  end

  # This method defines the complexity function is defined on the
  # domain of quantity terms. Intuitively, it would seem that the
  # sum of the absolute values of the exponents is a good initial
  # approximation of the term's complexity.
  #
  # FIXME: Surely, this complexity function will have to be
  # improved.
  # 
  def complexity
    # FIXME: Define this function better and write the tests.
    return 1
  end

  # Goodness function to choose between equivalent terms.
  # Generally, the simpler the term the better. Therefore, goodness
  # is for now defined as the negative value of complexity.
  # 
  def goodness
    # FIXME: Write the tests tests tests.
    -complexity
  end

  # Arity of the term is the number of its factors.
  # 
  def arity
    # FIXME: Write the tests.
    size
  end
end # SY::Quantity::Term
