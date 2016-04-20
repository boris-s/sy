#encoding: utf-8

# SY Quantity subclass represented composed quantities.
# 
class SY::Quantity::Composed < SY::Quantity
  # Set up instantiation hook to make sure that composed quantites,
  # when named, will turn into an instance of
  # SY::Quantity::Composition
  instantiation_exec do
    named_exec do
      puts "Hello, quantity #{name} of class #{self.class} " +
           "has just been named!"
      puts "Now we will execute something like"
      puts "SY::Quantity" +
             ".add_to_composition_table( self, composition )"
    end
  end

  def initialize quantity_term
    @term = quantity_term
    @dimension = @term.dimension
    @function = @term.function

    fail NotImplementedError
    # Tell NameMagic to insert an instance of
    # SY::Quantity::Composition.new( quantity: self, term: @term )
    # into the composition table.
  end
end # class SY::Quantity::Composed
