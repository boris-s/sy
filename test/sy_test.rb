#encoding: utf-8
#! /usr/bin/ruby

# **************************************************************************
# THIS IS SPEC-STYLE TEST FILE FOR SY PHYSICAL UNITS LIBRARY
# **************************************************************************

# The following will load Ruby spec-style library
require 'mathn'
require 'minitest/spec'
require 'minitest/autorun'

# The following will load SY library
require './../lib/sy'

# **************************************************************************
# THE SPECIFICATIONS START HERE
# **************************************************************************

describe SY do
  it "should have basic assets" do
    # The following test specifies basic physical dimensions.
    # 
    SY::BASE_DIMENSIONS.to_a.sort
      .must_equal [ [:L, :LENGTH], [:M, :MASS], [:T, :TIME],
                    [:Q, :ELECTRIC_CHARGE], [:Θ, :TEMPERATURE] ].sort
    
    # The following test ensures that SY has constant PREFIX_TABLE,
    # with standard unit prefixes
    # 
    SY::PREFIX_TABLE.map{|row| row[:full] }.sort
      .must_equal [ "exa", "peta", "tera", "giga", "mega", "kilo",
                    "mili", "micro", "nano", "pico", "femto", "atto",
                    "hecto", "deka","deci", "centi", "" ].sort
  end
end

describe SY::Dimension do
  it "should work" do
    # #new should return same instance when asked twice.
    # 
    SY::Dimension.new( 'L' ).object_id
      .must_equal SY::Dimension.new( 'L' ).object_id

    # Other constructors: #basic and #zero.
    # 
    SY::Dimension.basic( :L ).must_equal SY::Dimension.new( :L )
    SY::Dimension.zero.must_equal SY::Dimension.new

    # SY should have table of standard quantities.
    # 
    q = SY::Dimension.standard_quantities[ 'L' ]
    q.dimension.must_equal SY::Dimension.new( 'L' )

    # Instance should have access to base dimensions.
    # 
    assert_equal [0, 1], [:L, :M].map { |ß| SY.Dimension( :M ).send ß }
    assert_equal [1, 0], [:L, :M].map { |ß| SY.Dimension( :L )[ß] }

    # #to_a, #to_hash, #zero?, 
    SY.Dimension( :M ).to_a
      .must_equal SY::BASE_DIMENSIONS.letters.map { |l| l == :M ? 1 : 0 }
    SY.Dimension( :M ).to_hash
      .must_equal Hash[ SY::BASE_DIMENSIONS.letters.map do |l|
                          [ l, l == :M ? 1 : 0 ]
                        end ]
    SY.Dimension( :M ).zero?.must_equal false
    SY::Dimension.zero.zero?.must_equal true
    SY.Dimension( nil ).to_a.must_equal [ 0, 0, 0, 0, 0 ]

    # Dimension arithmetic
    # 
    assert SY.Dimension( :L ) + SY.Dimension( :M ) == SY.Dimension( 'L.M' )
    assert SY.Dimension( :L ) - SY.Dimension( :M ) == SY.Dimension( 'L.M⁻¹' )
    assert SY.Dimension( :L ) * 2 == SY.Dimension( 'L²' )
    assert SY.Dimension( M: 2 ) / 2 == SY.Dimension( :M )

    # #to_s and #inspect
    # 
    SY.Dimension( L: 1, Θ: -1 ).to_s.must_equal 'L.Θ⁻¹'
    SY.Dimension( L: 1, Θ: -1 ).inspect.must_equal '#<Dimension: L.Θ⁻¹ >'
  end
end

describe SY::Quantity do

end

describe SY::Unit do
  it "should have certain practical instances" do
    
  end
end

# describe SY do
#   describe "classes" do
#     before do
#       # Some dimensions to serve as test fixtures:
#       # 
#       @dim_l_per_t = SY::Dimension.new L: 1, M: 0, T: -1
#       @dim_l_per_temperature = SY::Dimension.new L: 1, Θ: -1

#       # Zero dimension (for dimensionless quantities)
#       # 
#       @dim_null = SY::Dimension.new
#     end

#     describe "Dimension instance methods" do
#       # it "Dimension's #initialize method should be flexible" do

#       #   # There should be two ways to invoke a new Dimension instance.
#       #   # By providing named parameters { LETTER: exponent }
#       #   # 
#       #   d = SY::Dimension.new L: 1, T: -1 # using named parameters
#       #   d.inspect.must_equal "#<Dimension: L.T⁻¹ >"

#       #   # And by providing a superscripted product string:
#       #   # 
#       #   d = SY::Dimension.new "Θ.L³.T⁻¹" # using SPS
#       #   d.inspect.must_equal "#<Dimension: L³.Θ.T⁻¹ >"
#       # end

#       # it "should have readers of the basic dim. components" do

#       #   # A dimension should respond to five methods #L, #M, #T, #Q and #Θ
#       #   # by returning its exponent in the corresponding basic dimension:

#       #   # Test that @dim_l_per_t responds to all five letters:
#       #   # 
#       #   @dim_l_per_t.must_respond_to :L
#       #   @dim_l_per_t.must_respond_to :M
#       #   @dim_l_per_t.must_respond_to :T
#       #   @dim_l_per_t.must_respond_to :Q
#       #   @dim_l_per_t.must_respond_to :Θ

#       #   # Test that each of the five letters used as method returns correct
#       #   # exponent:
#       #   # 
#       #   @dim_l_per_t.L.must_equal 1
#       #   @dim_l_per_t.M.must_equal 0
#       #   @dim_l_per_t.T.must_equal -1
#       #   @dim_l_per_t.Q.must_equal 0
#       #   @dim_l_per_t.Θ.must_equal 0

#       #   # Test that both @dim_l_per_temperature and @dim_null respond to all
#       #   # five letters:
#       #   # 
#       #   [ @dim_l_per_temperature, @dim_null ].each{ |dimension|
#       #     dimension.must_respond_to :L
#       #     dimension.must_respond_to :M
#       #     dimension.must_respond_to :T
#       #     dimension.must_respond_to :Q
#       #     dimension.must_respond_to :Θ
#       #   }

#       #   # Test that the five letters return correct exponents for
#       #   # @dim_l_per_temperature:
#       #   # 
#       #   [:L, :M, :T, :Q, :Θ]
#       #     .map{ |letter|
#       #           @dim_l_per_temperature.send letter
#       #         }
#       #     .must_equal [ 1, 0, 0, 0, -1 ]

#       #   # Test that the five letters return correct exponents for @dim_null
#       #   # 
#       #   [:L, :M, :T, :Q, :Θ]
#       #     .map{ |letter|
#       #           @dim_null.send letter
#       #         }
#       #     .must_equal [ 0, 0, 0, 0, 0 ] # zero vector
#       # end

#       # it "should have #[] dim. component reader" do

#       #   # using method "square brackets" on Dimension class objects should,
#       #   # given a dimension letter, return its exponent. A few examples:
#       #   # 
#       #   @dim_l_per_t[:L].must_equal 1
#       #   @dim_l_per_t[:M].must_equal 0
#       #   @dim_l_per_t[:Θ].must_equal 0
#       #   @dim_l_per_temperature[:Θ].must_equal -1
#       #   @dim_null[:Θ].must_equal 0
#       # end

#       # it "should have #== comparator" do

#       #   # '==' method is used to compare object for equality. A Dimension
#       #   # class object is equal to another Dimesion class object if and only
#       #   # if all of its exponents match.

#       #   # So, for example, @dim_l_per_t must declare equality to another
#       #   # brand new instantiated Dimension object with same exponents:
#       #   # 
#       #   @dim_l_per_t.==( SY::Dimension.new L: 1, T: -1 )
#       #     .must_equal true

#       #   # The same must be valid for @dim_l_per_temperature
#       #   # 
#       #   ( @dim_l_per_temperature == SY::Dimension.new( "L.Θ⁻¹" ) )
#       #     .must_equal true
#       #   # Note that above, more usual way to invoke #== method was used,
#       #   # by writing
#       #   # a == b
#       #   # instead of conformist, but awkward
#       #   # a.==( b )

#       #   # ... and for @dim_null
#       #   # 
#       #   ( @dim_null == SY::Dimension.new( "" ) ).must_equal true

#       #   # Let us also make negative test
#       #   # 
#       #   ( @dim_l_per_t == SY::Dimension.new( "M" ) ).must_equal false
#       # end

#       # it "should have #to_a, #to_hash, #to_s convertors" do

#       #   # Dimensions should be able to convert themselves to array:
#       #   # 
#       #   @dim_l_per_t.to_a
#       #     .must_equal [1, 0, 0, 0, -1]

#       #   # to a hash:
#       #   # 
#       #   @dim_l_per_t.to_hash
#       #     .must_equal( { L: 1,
#       #                    M: 0,
#       #                    T: -1,
#       #                    Q: 0,
#       #                    Θ: 0} )

#       #   # and to string:
#       #   # 
#       #   @dim_l_per_t.to_s.must_equal "L.T⁻¹"
#       # end

#       # it "should have +, -, *, / operators" do

#       #   # Dimension '+' means addition of the dimension vectors, '-' means
#       #   # their subtraction. * and / only work with numbers, and mean
#       #   # multiplication or division of the dimension vector by scalar.

#       #   # Testing #+ operator method
#       #   # 
#       #   ( @dim_l_per_t + @dim_l_per_temperature )
#       #     .must_equal SY::Dimension.new( L: 2, T: -1, Θ: -1 )

#       #   # Testing #* operator method
#       #   # 
#       #   ( @dim_l_per_t * 2 )
#       #     .must_equal SY::Dimension.new( L: 2, T: -2 )

#       #   # Testing #- operator method
#       #   # 
#       #   ( @dim_l_per_t - @dim_l_per_temperature )
#       #     .must_equal SY::Dimension.new( T: -1, Θ: 1 )

#       #   # Testing #/ operator method
#       #   # 
#       #   ( ( @dim_l_per_t * 4 ) / 2 )
#       #     .must_equal SY::Dimension.new( L: 2, T: -2 )
#       # end

#       # it "should have zero? inquirer" do

#       #   # Method #zero? will answer true if the dimension is null, false
#       #   # otherwise:
#       #   # 
#       #   @dim_l_per_t.zero?.must_equal false
#       #   @dim_null.zero?.must_equal true
#       # end

#       # it "should know its favored quantities" do

#       #   # To test this, we first need to make quantities of the dimensions:
#       #   # 
#       #   @quantity_1 = SY::Quantity.new of: @dim_l_per_t
#       #   @quantity_2 = SY::Quantity.new of: @dim_l_per_temperature
#       #   @quantity_3 = SY::Quantity.new of: @dim_null

#       #   # Then, we need to set these quantities as standard quantities for
#       #   # their respective dimensions:
#       #   # 
#       #   @quantity_1.set_as_standard
#       #   @quantity_2.set_as_standard
#       #   @quantity_3.set_as_standard

#       #   # And now, the dimensions should recognize them as their standard
#       #   # quantities:
#       #   # 
#       #   @dim_l_per_t.standard_quantity
#       #     .must_equal @quantity_1
#       #   @dim_l_per_temperature.standard_quantity
#       #     .must_equal @quantity_2
#       #   @dim_null.standard_quantity
#       #     .must_equal @quantity_3
#       # end

#       # it "should have nice #inspect" do

#       #   # Inspect method serves the purpose of making beautiful text
#       #   # representation of the object.
#       #   # 
#       #   @dim_l_per_t.inspect.must_equal "#<Dimension: L.T⁻¹ >"
#       #   @dim_l_per_temperature.inspect.must_equal "#<Dimension: L.Θ⁻¹ >"

#       #   # And now there is specialy, null dimension will introduce itself as
#       #   # 
#       #   @dim_null.inspect.must_equal "#<Dimension: ∅ >"
#       # end

#       # it "should have #coerce" do

#       #   # Coerce method takes another object or quantity as its argument and
#       #   # returns a pair [ compatible_object_other, compatible_object_self ]
#       #   # usable for arithmetic, comparison and such.
#       #   # 
#       #   p, q = SY::Quantity.dimensionless, SY::Quantity.dimensionless
#       #   assert_equal :TE_raised, begin
#       #                              q.coerce( p )
#       #                            rescue TypeError
#       #                              :TE_raised
#       #                            end
#       # end
#     end

#     describe "Dimension class methods" do

#       # ********************************************************************
#       # INTRODUCTION TO PUBLIC CLASS METHODS
#       #
#       # Normally, instance of a class is first made by calling 'new' method
#       #
#       # d = Dimension.new "L.T⁻²"
#       #
#       # And then, instance methods are called on thus created object:
#       #
#       # d.instance_method_1
#       # d.instance_method_2
#       # etc.
#       #
#       # Compared to this, public class methods are called directly on the
#       # class:
#       #
#       # Dimension.public_class_method_1
#       # Dimension.public_class_method_2
#       # etc.
#       #
#       # ********************************************************************

#       it "should provide #basic, #zero special dimension constructors" do

#         # Two public class methods are defined on Dimension class:
#         # #basic
#         # and
#         # #zero

#         # #basic method is a shorthand for creating basic dimensions.
#         # Instead of writing
#         # Dimension.new L: 1
#         # we can write just
#         # Dimension.basic :L
#         # or
#         # Dimension.basic "L"
#         # 
#         SY::Dimension.basic( "L" )
#           .must_equal( SY::Dimension.new( L: 1 ) )

#         # Zero method is another way to explicitly create null dimension.
#         # Instead of writing
#         # Dimension.new( )
#         # we can write more expressively
#         # Dimension.zero
#         # 
#         SY::Dimension.zero
#           .must_equal SY::Dimension.new()
#       end
#     end
#   end # describe Dimension class

#   describe "Quantity class" do
#     before do

#       # We will set up some fixture quantities, that will be used
#       # throughout this test library:
#       # 
#       @speed = begin
#                  SY::Quantity.instance :Speed
#                rescue NameError
#                  SY::Quantity.of 'L.T⁻¹', name: "Speed"
#                end
#       @thermal_distension = begin
#                               SY::Quantity.instance :Thermal_distension
#                             rescue NameError
#                               SY::Quantity.of 'L.Θ⁻¹', ɴ: "Thermal_distension"
#                             end
#       @q_dimensionless = begin
#                            SY::Quantity.instance :Dimensionless_quantity
#                          rescue NameError
#                            SY::Quantity.dimensionless name: "Count"
#                          end
#     end

#     describe "instance methods" do
#       it "has flexible #initialize" do

#         # That is, to instantiate a new quantity, we don't have to write
#         # clumsily
#         # 
#         # SY::Quantity.new( dimension: SY::Dimension.new( Θ: -1 ),
#         #                   name: "reciprocal temperature" )
#         # 
#         # but we can write instead:
#         # 
#         q = SY::Quantity.new of: "Θ⁻¹", name: "Reciprocal_temperature"

#         # Let us see that we indeed obtained desired Quantity instance
#         # 
#         q.must_be_kind_of SY::Quantity
#         q.name.must_equal :Reciprocal_temperature
#         # (Note that dimension names are all upcase, such as "LENGTH",
#         # quantity names are capitalized first letter, such as "Electric
#         # current", and units are all downcase, such as "ampere".)
#       end

#       # it "should have attr_readers for dimension, basic unit and name" do

#       #   # Should know its dimension:
#       #   # 
#       #   @q_speed.dimension.inspect.must_equal "#<Dimension: L.T⁻¹ >"
#       #   @q_thermal_distension.dimension.inspect.must_equal "#<Dimension: L.Θ⁻¹ >"
#       #   @q_dimensionless.dimension.inspect.must_equal "#<Dimension: ∅ >"

#       #   # Should know its name
#       #   # 
#       #   @q_speed.name.must_equal :Speed
#       #   @q_thermal_distension.name.must_equal :Thermal_distension
#       #   @q_dimensionless.name.must_equal :Dimensionless_quantity
#       # end

#       # it "should have working * operator" do

#       #   # Multiplication of quantities means addition of the dimension
#       #   # exponent vectors.
#       #   # 
#       #   ( @q_speed * @q_thermal_distension ).dimension.inspect
#       #     .must_equal "#<Dimension: L².Θ⁻¹.T⁻¹ >"
#       # end

#       # it "should have working / operator" do

#       #   # Division of quantities means subtraction of the dimension exponent
#       #   # vectors.
#       #   # 
#       #   ( @q_speed / @q_thermal_distension ).dimension.inspect
#       #     .must_equal "#<Dimension: Θ.T⁻¹ >"
#       # end

#       # it "should have working ** operator" do

#       #   # Raising quantity to an integer means multiplication of the
#       #   # dimension by that integer.
#       #   # 
#       #   ( @q_speed ** 2 ).dimension.inspect
#       #     .must_equal "#<Dimension: L².T⁻² >"
#       # end

#       # it "should have #name_basic_unit, #inspect, #to_s" do

#       #   # Ever since a Quantity instance is born, it has its standard unit,
#       #   # which can be named immediately, or later.

#       #   # Name of the basic unit is nil at the beginning
#       #   # 
#       #   SY::Quantity.dimensionless.standard_unit.name.must_equal nil

#       #   # Now, we will name the basic unit of "Speed" snail (abbr. 1.sn):
#       #   # 
#       #   unless defined? SY::Unit::SNAIL
#       #     @q_speed.standard_unit.name = "snail"
#       #     @q_speed.standard_unit.abbreviation = "sn"
#       #   end
          
#       #   # Since now, basic unit of speed will be called "snail":
#       #   # 
#       #   @q_speed.units.map( &:name ).must_include :snail

#       #   # Unit symbol need not be given:
#       #   # 
#       #   @q_dimensionless.standard_unit.name = "amount"

#       #   # Now, let's write expectation about the #inspect method
#       #   # 
#       #   @q_speed.inspect.must_equal '#<Quantity: Speed >'

#       #   # Expectation about the #to_s (conversion to string)
#       #   # 
#       #   @q_speed.to_s.must_equal 'Speed'

#       #   # Expectation about #inspect of a quantity without name:
#       #   # 
#       #   SY::Quantity.new( dimension: SY::Dimension.new("L⁻¹") ).inspect
#       #     .must_equal "#<Quantity: L⁻¹ >"
#       # end

#       # it "should have #set_as_standard method" do

#       #   # This method, which has already been used above, is here
#       #   # defined formally by test expectations.

#       #   # Let us first set "Speed" as standard quantity for its dimension:
#       #   # 
#       #   @q_speed.set_as_standard

#       #   # Now let us instantiate a brand new LENGTH/TIME dimension:
#       #   # 
#       #   new_dim = SY::Dimension.new("L.T⁻¹")

#       #   # And let's write expectation about its standard quantity:
#       #   #
#       #   new_dim.standard_quantity.must_equal @q_speed
#       #   # (it must be "Speed")
#       # end

#       # it "should have #fav_units reader" do

#       #   # Each quantity should have its favored units. For example,
#       #   # "Pressure" quantity should favor 'pascal' unit over 'psi'
#       #   # (pounds per square inch). So far, the only favored unit is
#       #   # the basic unit, so if we name basic unit properly:
#       #   # 
#       #   begin
#       #     @q_speed = SY::Unit::KNOT.dimension.standard_quantity
#       #   rescue NameError
#       #     @q_speed.standard_unit.name = "knot"
#       #     @q_speed.standard_unit.abbreviation = "kn"
#       #   end

#       #   # Then the fav_units should return an array with a single
#       #   # member: metre
#       #   # 
#       #   result = @q_speed.units
#       #   result.must_be_kind_of Array
#       #   result[0].must_be_kind_of SY::Unit
#       #   assert result.any? { |unit| unit.name == :knot }
#       # end
#     end

#     # describe "public class methods" do

#     #   # Again, Quantity class has 2 public class methods:
#     #   # #of
#     #   # and
#     #   # #zero

#     #   it "should have #of constructor" do
        
#     #     # Expectation about #of class method
#     #     # 
#     #     new_quantity = SY::Quantity.of "L.T⁻¹", ɴ: "Growth_rate" 
#     #     new_quantity.dimension.inspect.must_equal "#<Dimension: L.T⁻¹ >"
#     #   end

#     #   it "should have dimensionless quantity constructor" do

#     #     # Expectation about #zero class method
#     #     # 
#     #     new_quantity = SY::Quantity.dimensionless name: "Happiness"
#     #     new_quantity.inspect
#     #       .must_equal '#<Quantity: Happiness >'
#     #   end
#     # end

#     # describe "Magnitude and SignedMagnitude classes" do
#     #   before do

#     #     # Let us set up 3 magnitudes of the 3 quantities defined earlier
#     #     # 
#     #     @m1 = SY::Magnitude.new amount: 3.3, quantity: @q_speed
#     #     @m2 = SY::Magnitude.new amount: 1, quantity: @q_thermal_distension
#     #     @m3 = SY::Magnitude.new amount: 2.0, quantity: @q_dimensionless
#     #     @sm1 = SY::SignedMagnitude.new amount: 3.3, quantity: @q_speed
#     #     @sm2 = SY::SignedMagnitude.new amount: -3.3, quantity: @q_speed
#     #     @sm3 = SY::SignedMagnitude.new amount: 2.0, quantity: @q_dimensionless
#     #   end

#     #   it "should have flexible initialization" do

#     #     # Instead of number:, we can just say n:
#     #     # Instead of quantity:, we can just say of:
#     #     # 
#     #     ( SY::Magnitude.new of: @q_speed, amount: 3.3 ).must_equal @m1
#     #   end

#     #   it "should have comparison methods" do

#     #     ( SY::Magnitude.new of: @q_speed, amount: 3 ).must_be :<, @m1
#     #     ( SY::Magnitude.new of: @q_speed, amount: 3.3 ).must_be :==, @m1
#     #     ( SY::Magnitude.new of: @q_speed, amount: 4 ).must_be :>, @m1
#     #   end

#     #   it "should have #abs method" do

#     #     # Firstly, negative Magnitude proper doesn't exist.
#     #     # 
#     #     begin
#     #       SY::Magnitude.new of: @q_speed, amount: -3
#     #     rescue SY::NegativeAmountError
#     #       :negative_amount_error_raised
#     #     end.must_equal :negative_amount_error_raised

#     #     # Secondly, for existing magnitudes, absolute value equals themselves.
#     #     # 
#     #     @m1.abs.must_equal @m1

#     #     # Thirdly, for signed magnitudes, it should work as expected.
#     #     assert_equal @sm3, @sm3.abs
#     #     assert_equal SY::Magnitude.new( amount: 3.3, of: @q_speed ), @sm1
#     #     assert_equal @sm1, @sm2.abs
#     #   end

#     #   it "should know #quantity, #number, #basic_unit" do
        
#     #     @m1.quantity.inspect.must_equal '#<Quantity: Speed >'
#     #     @m1.amount.must_equal 3.3
#     #     @m1.quantity.standard_unit.inspect
#     #       .must_equal "#<Unit: 1.m.s⁻¹ >"
#     #   end
      
#     #   it "should delegate dimension method to quantity" do
#     #     @m1.dimension.must_equal @m1.quantity.dimension
#     #   end

#     #   it "has #inspect and #to_s methods" do
#     #     @m1.quantity.must_equal SY::Quantity::Speed
#     #     @m1.dimension.to_hash.must_equal( { L: 1, M: 0, T: -1, Q: 0, Θ: 0 } )
#     #     SY::Dimension.basic( :L ).standard_unit.must_equal SY::Unit::METRE
#     #     @m1.inspect.must_equal "#<Magnitude: 3.3.m.s⁻¹ >"
#     #     @m1.to_s.must_equal "3.3.m.s⁻¹"
#     #   end
      
#     #   it "has #numeric_value_in working with magnitudes of the same " +
#     #     "quantity and returning a number" do
#     #     m = SY::Magnitude.of @q_speed, amount: 9.9
#     #     m.numeric_value_in( @m1 ).must_be_within_epsilon 3.0, 1e-6
#     #   end

#     #   it "has #numeric_value_in_basic_unit alias #to_f method" do
#     #     m = SY::Magnitude.of @q_speed, amount: 6.6
#     #     m.numeric_value_in_standard_unit.must_equal 6.6
#     #     m.to_f.must_equal 6.6
#     #   end

#     #   it "should be capable of arithmetic" do
#     #     m = SY::Magnitude.of @q_speed, amount: 1.0
#     #     ( m + @m1 ).amount.must_equal 4.3
#     #     ( @m1 - m ).amount.must_equal 2.3
#     #     ( @m1 * @m2 ).inspect
#     #       .must_equal "#<Magnitude: 3.3.m².K⁻¹.s⁻¹ >"
#     #     ( @m1 / @m2 ).inspect
#     #       .must_equal "#<Magnitude: 3.3.K.s⁻¹ >"
#     #   end

#     #   it "should be comparable" do
#     #     m = SY::Magnitude.of @q_speed, amount: 1.0
#     #     ( @m1 == m * 3.3 ).must_equal true
#     #   end
      
#     #   describe "class methods" do
#     #     it "should have #of constructor" do
#     #       # I already did this above:
#     #       # 
#     #       m = SY::Magnitude.of @q_speed, amount: 1
#     #       m.must_be_kind_of SY::Magnitude
#     #       m.amount.must_equal 1
#     #     end
#     #   end
#     # end # describe Magnitude

#     # describe "Unit class" do
#     #   before do
#     #     @u = SY::Unit.new( quantity: @q_speed,
#     #                        amount: 0.1 )
#     #   end

#     #   describe "instance methods" do
#     #     it "should respond to #short, alias #abbreviation" do
#     #       @u.must_respond_to :short
#     #       @u.must_respond_to :abbreviation
#     #     end
#     #   end

#     #   describe "class methods" do
#     #     it "should have #standard constructor" do
#     #       assert_respond_to SY::Unit, :standard
#     #     end
#     #   end
#     # end # describe Unit class
#   end # describe Quantity class

#   describe "Magnitude() constructor" do

#     # not essential
#     # Serves the purpos that we can say not just
#     #
#     # Magnitude.of ELECTRIC_CHARGE, amount: 3.3e-9
#     #
#     # but also
#     #
#     # Magnitude 3.3e-9 of: ELECTRIC_CHARGE
#     #
#     # but this is not that important, as typically, we'll just
#     # say only:
#     #
#     # 3.3e-9.C
#     # or
#     # 3.3.nanocoulomb
#     # or such
#   end

describe Numeric do
  it "should provide metrological units" do
    # Length
    SY::METRE.must_be_kind_of SY::Unit
    assert SY::Length.standard_unit.equal?( SY::METRE )
    1.metre.must_be_kind_of SY::Magnitude
    1.metre.quantity.must_equal SY::Length
    1.m.must_equal 1.metre
    1.mm.must_equal 0.001.metre
    1.cm.must_equal 0.01.m
    1.dm.must_equal 0.1.m
    1.km.must_equal 1000.m
    # Mass
    SY::KILOGRAM.must_be_kind_of SY::Unit
    SY::GRAM.must_be_kind_of SY::Unit
    assert SY::Mass.standard_unit.equal?( SY::KILOGRAM )
    1.kilogram.must_be_kind_of SY::Magnitude
    1.gram.must_be_kind_of SY::Magnitude
    1.kilogram.quantity.must_equal SY::Mass
    1.gram.quantity.must_equal SY::Mass
    1.kilogram.must_equal 1000.g
    1.miligram.must_equal 0.001.g
    1.mg.must_equal 1.miligram
    1.µg.must_equal 0.001.miligram
    1.ng.must_equal 0.001.microgram
    1.pg.must_equal 0.001.nanogram
    SY::TON.must_be_kind_of SY::Unit
    1.ton.must_equal 1000.kg
    1.t.must_equal 1.ton
    1.kt.must_equal 1000.ton
    1.Mt.must_equal 1000.kiloton
    1.mm.quantity.units[0].name.must_equal :metre
    1.mm.to_s.must_equal "0.001.m"
    # 1.mm.inspect.must_equal "#<Magnitude: 0.001.m >"
    # 1.µs.inspect.must_equal "#<Magnitude: 1e-06.s >"
    # SY::AMPERE.name.must_equal :ampere
    # SY::AMPERE.abbreviation.must_equal :A
    # SY::AMPERE.dimension.must_equal 1.A.dimension
    # 1.A.quantity.units[0].amount.must_equal 1
    # SY::Magnitude.new( of: SY::ElectricCurrent, amount: 1 ).must_equal 1.A
    # 1.A.quantity.units[0].name.must_equal :ampere
    # 1.A.to_s( SY::AMPERE ).must_equal "1.A"
    # 1.A.to_s.must_equal "1.A"
    # 1.A.amount.must_equal 1
    # 1.A.quantity.standard_unit.abbreviation.must_equal :A
    # 1.A.inspect.must_equal "#<Magnitude: 1.A >"
    # 1.l⁻¹.( SY::Molarity ).quantity.must_equal SY::Molarity
    # x = ( SY::UNIT * SY::Nᴀ / SY::LITRE ).reframe( SY::Molarity )
    # y = 1.molar
    # y.must_equal x
    # 7.µM
    #   .must_be_within_epsilon( 5.µM + 2.µM, 1e-9 )
    # +1.s.must_equal 1.s
    # # -1.s.must_equal -1 * 1.s # must raise
    # assert_equal -(1.s), +(1.s)
    # ( 1 / 1.s )
    #   .must_equal 1.s⁻¹
    # 1.s⁻¹.( SY::Frequency ).must_equal 1.Hz
    # # 7.°C.must_equal( 8.°C - 1.K )
    # # (-15).°C.must_equal 258.15.K
    # # 7000.µM.must_be_within_epsilon( 7.mM, 1e-9 )
    # ::SY::Unit.instances.map do |i|
    #   begin
    #     i.abbreviation
    #   rescue
    #   end
    # end.must_include :M
    # SY::Unit.instance_names.must_include :mol
    # # Avogadro's number is defined directly in SY
    # assert 1.mol == SY::Nᴀ.unit

    # 0.7.M.must_equal( 0.7.mol.l⁻¹.reframe( SY::Molarity ) )
    # # (if #reframe conversion method is not used, different quantities
    # # do not compare. Arithmetics is possible because Magnitude operators
    # # mostly give their results only in standard quantities.

    # # Avogadro's number is defined directly in SY
    # 1.mol
    #   .must_equal SY::Nᴀ.unit

    # 0.7.M
    #   .must_equal( 0.7.mol.l⁻¹.is_actually!( MOLARITY ) )
    # # (if #is_actually! conversion method is not used, current
    # # implementation will refuse to compare different quantities,
    # # even if their dimensions match)

    # 30.Hz
    #   .must_equal 30.s⁻¹.( FREQUENCY )

    # # Dalton * Avogadro must be 1 gram
    # ( 1.Da * Nᴀ )
    #   .must_be_within_epsilon( 1.g, 1e-6 )

    # # kilogram
    # 1.kg.must_equal 1000.g
    # ( 1.kg * 1.m.s⁻² ).is_actually!( FORCE ).must_be_within_epsilon 1.N, 1e-9

    # # joule
    # ( 1.N * 1.m ).is_actually!( ENERGY ).must_equal 1.J
    # 1e-23.J.K⁻¹.must_equal 1.0e-20.mJ.K⁻¹

    # # pascal
    # ( 1.N / 1.m ** 2 ).is_actually!( PRESSURE ).must_be_within_epsilon 1.Pa, 1e-9

    # # watt
    # ( 1.V * 1.A ).is_actually!( POWER ).must_be_within_epsilon 1.W, 1e-9

    # # pretty representation
    # ( 1.m / 3.s ).to_s.must_equal( "0.33.m.s⁻¹" )
    # ( 1.m / 7.01e7.s ).to_s.must_equal( "1.4e-08.m.s⁻¹" )
  end
end
