#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Acceptance tests for SY::Quantity.
# **************************************************************************

require_relative 'test_loader'

describe SY::Quantity do
  before do
    @T = SY::Dimension[ :TIME ]
    @L = SY::Dimension[ :LENGTH ]
  end

  describe "constructors" do
    it "should have .of constructor" do
      SY::Quantity.of( @T ).must_be_kind_of SY::Quantity
      SY::Quantity.of( @T ).dimension.must_equal @T
    end

    it "should have .dimensionless constructor" do
      SY::Quantity.dimensionless.must_be_kind_of SY::Quantity
      assert SY::Quantity.dimensionless.dimension.zero?
    end
  end

  describe ".standard accessor of standard quantity for a given dimension" do
    it "should work" do
      SY::Quantity.standard( of: @T ).must_be_kind_of SY::Quantity
      SY::Quantity.standard( of: @T ).dimension.must_equal @T
      assert SY::Quantity.standard( of: @T ).equal? @T.standard_quantity
    end
  end

  describe "quantity-specific parametrized subclass of SY::Magnitude" do
    before do
      @q = SY::Quantity.of( @T )
    end

    it "should be accessible through SY::Quantity#Magnitude method" do
      assert @q.Magnitude < SY::Magnitude
      assert @q.Magnitude.quantity.equal? @q
    end
  end

  describe "quantity arithmetics" do
    before do
      @Time = SY::Quantity.of @T
      @Length = SY::Quantity.of @L
      @Amount = SY::Quantity.dimensionless
    end

    describe "multiplication" do
      it "should work for any quantities" do
        ( @Time * @Amount ).must_be_kind_of SY::Quantity
        ( @Time * @Amount ).must_be_kind_of SY::Quantity
        ( @Time * @Amount ).must_be_kind_of SY::Quantity
      end

      it "should not work for other types of objects" do
        skip
        flunk "Tests not written!"
      end

      # FIXME: Now let's get to the important business. As explained in the
      # file sy/quantity/term.rb, multiplication of quantities is not a simple
      # business. Paying attention to dimensionality is a useful crutch, but
      # the actual algebraic structure of quantities together with their
      # multiplication operator (whatever it is called) relies not on dimensions,
      # but on established quantity multiplication rules. Each rule is an
      # equation with a quantity term on the left hand side and a quantity on the
      # right hand side. Any term can be transformed, at any moment, by any
      # rule. In this sense, the rules are dimensions of a grid in which we
      # can perform walks, and in which every node is equivalent to others.
      # Given a certain node (implied by the supplied term), we must perform
      # search of the grid in order to find such node, that is sufficiently
      # beautiful to be presented as the result. If no more beautiful node
      # can be found than the one supplied, the supplied node is returned back
      # as the result. So there is always some result, the question only is
      # when to give up.
      #
      # In order for quantity multiplication to work, two things are needed:
      # Quantity term class (to which the quantities being multiplied together
      # are converted) and a set of quantity composition rules.

      describe "setting a quantity composition rule" do
        before do
          # Let us first construct 2 brand new, dimensionless, nameless quantities.
          @q1 = SY::Quantity.dimensionless
          @q2 = SY::Quantity.dimensionless
        end

        it "we now set the composition rule simply by constructing another " +
           "quantity from their product" do
          # Since nothing else is known about @q1 and @q2 yet, if the terms
          # containing them are submitted for reduction (which should actually
          # be called "beautification"), nothing happens.

          skip

          Term[ @q1 => 1, @q2 => 1 ].beautify.must_equal Term[ @q1 => 1, @q2 => 1 ]
          Term[ @q1 => 1, @q2 => 2 ].beautify.must_equal Term[ @q1 => 1, @q2 => 2 ]
          Term[ @q1 => 2, @q2 => 1 ].beautify.must_equal Term[ @q1 => 2, @q2 => 1 ]
          Term[ @q1 => 1, @q2 => -1 ].beautify.must_equal Term[ @q1 => 1, @q2 => -1 ]
          Term[ @q1 => -1, @q2 => 1 ].beautify.must_equal Term[ @q1 => -1, @q2 => 1 ]

          # And perhaps

          Term[ @q1 => 1, @q2 => 1 ].reduce.must_equal Quantity[ @q1 => 1, @q2 => 1 ]
          # etc.

          # To understand, with term such as

          Term[ @q1 => 1, @q2 => 2 ]

          # The system should already consider the possibilities such as

          Term[ Quantity[ @q1 => 1, @q2 => 2 ] => 1 ]
          # or
          Term[ Quantity[ @q1 => 1, @q2 => 1 ] => 1, @q2 => 1 ]

          # But should reject these possibilities on the grounds of them not being
          # more beautiful than the starting term, because there is nothing special
          # about quantity Quantity[ @q1 => 1, @q2 => 1 ] or quantity
          # Quantity[ @q1 => 1, @q2 => 2 ]

          # It is interesting to note that each new considered node in fact represents
          # a new dimension, which leads to very quick explosion of the nodes to
          # search. But this is the systematic way of doing it.

          # So nothing changes by simply writing
          q3 = @q1 * @q2
          # because the system already knew and thought (or could potentially think)
          # about @q1 * @q2 before, and the fact that we assigned it to the local
          # variable q3 is not making it any more beautiful to the system.

          # However, if we name q3
          q3.name = "SomethingSpecial"
          # The system might (depending on the exact coding) have a reason to prefer
          # term
          Term[ q3 => 1 ]
          # to term
          Term[ @q1 => 1, @q2 => 1 ]
          
          # What made @q1 and @q2 special and beautiful (in term-making sense) was
          # the fact that we defined them through special constructor

          Quantity.dimensionless

          # The question is, do we need the table of quantities? Can't we do with
          # the multiplication table? I think it's better not to keep the table
          # of quantities (or at least not consider it when simplifying terms) exactly
          # because for some reason, the user might decide to define disposable
          # quantities, of which already a small number would make work considerably
          # more difficult for the multiplication table. NameMagic already keeps
          # the registry of instances by default, which is not a big problem,
          # because user is not expected to go on defining infinite number of disposable
          # quantities, but anyway... Perhaps what if NameMagic could be told not to
          # keep the registry of instances in some situations? And use slower ObjectSpace
          # sweep to find the instances instead? And make each object hold its own name
          # in @name instance variable instead of keeping it centrally in the instance
          # registry? That way the garbage collection wouldn't be impeded...

          # Going back to the above, the quantities @q1 and @q2 either themselves answer
          # the question about wheter they are special or not, or term-beautifying
          # algorithm finds them beautiful through instance registry and the fact that
          # they were defined via Quantity.dimensionless constructor, or it finds them
          # special by the fact that the user asked the question using them, such as

          Term[ @q1 => 1, @q2 => 1 ].beautify

          # Since the beautificator never heard about @q1 and @q2 before, it is possible
          # to make the mere fact that the user uses these objects in the query make
          # the beautificator start thinking that they are special. So in this third
          # option, the beautificator would itself have the table of quantity instances,
          # but not of all instances ever created in the system, but only of the instances
          # submitted to the beautificator (or multiplication table, as we call it now)
          # as factors of the terms to beautify. (This seems to call for making
          # a Quantity::MultiplicationTable class rather than using a hash sitting in
          # a constant. The class can be instantiated, played with and discarded. On the
          # other hand, the hash sitting in a constant would remember all the quantities
          # we ever presented to it.)
          
          # Another idea: The beautificator should not go for reducing

          Term[ @q1 => 6 ].beautify

          # into

          Term[ Quantity[ @q1 => 3 ] => 2 ]

          # in spite of the fact that the sum of the exponents in the second case is
          # less than 6. The big difference is, @q1 is special (not composed, mentioned
          # to the beautificator by the user or whatever), while Quantity[ @q1 => 3 ]
          # is composed.

          # So what should happen now when the user, for the first time,
          # asks the beautificator to
          
          Term[ Quantity[ @q1 => 3 ] => 2 ].beautify

          # This is a tough call, because the system would earlier prefer

          Term[ @q1 => 6 ]

          # but the user allmighty now explicitly mentioned Quantity[ @q1 => 3 ] in
          # the query! I think that user allmighty should be required to go into
          # further lengths to make the beautificator think that Quantity[ @q1 => 3 ]
          # is special. Even naming, such as

          @q1.name = :Length
          Quantity[ @q1 => 3 ].name = :Volume

          # should not make the beautificator too eager to simplify eg.

          Term[ Length: 4 ]

          # into

          Term[ Volume: 1, Length: 1 ]
          
          # or even

          Term[ Length: 6 ]

          # into

          Term[ Volume: 2 ]

          # Volume in the sense of cubic metres is not such a favorite physical
          # quantity at all. The user will probably appreciate output

          Term[ Length: 1, Mass: 1, Time: -2 ] #=> Term[ Energy: 1 ]

          # and maybe also

          Term[ Length: 3 ].beautify  #=> Term[ Volume: 1 ]

          # But the question is ... no, I took the right approach originally.
          # I took thoroughly right approach originally.
          # Perhaps the above contains some good ideas, but the beautificator
          # as of now does a lot of work automatically, plus it allows the user
          # to specify more rules.
        end
      end
    end
  end

  describe "#to_s" do
    it "..." do
      skip
      flunk "Tests not written!"
    end
  end

  describe "#inspect" do
    it "should return specific strings" do
      # FIXME: These tests were stolen from dimension_test.rb
      # @Z.inspect.must_equal "#<Dimension:∅>"
      # @L.inspect.must_equal "#<Dimension:L>"
      # ( @L - 2 * @T ).inspect.must_equal "#<Dimension:L.T⁻²>"
    end
  end
end

# FIXME: These acceptance tests are legacy from SY 2.0.
# 
describe SY::Quantity do
  before do
    # @q1 = SY::Quantity.new of: '∅'
    # @q2 = SY::Quantity.dimensionless
    # @amount_in_dozens = begin
    #                       SY.Quantity( "AmountInDozens" )
    #                     rescue
    #                       SY::Quantity.dimensionless amount: 12, ɴ: "AmountInDozens"
    #                     end
    # @inch_length = begin
    #                  SY.Quantity( "InchLength" )
    #                rescue NameError
    #                  SY::Quantity.of SY::Length.dimension, ɴ: "InchLength"
    #                end
  end

  it "should behave as expected" do
    skip
    refute_equal @q1, @q2
    assert @q1.absolute? && @q2.absolute?
    assert @q1 == @q1.absolute
    assert_equal false, @q1.relative?
    assert_equal SY::Composition.new, @q1.composition
    @q1.set_composition SY::Composition[ SY::Amount => 1 ]
    assert_equal SY::Composition[ SY::Amount => 1 ], @q1.composition
    @amount_in_dozens.must_be_kind_of SY::Quantity
    d1 = @amount_in_dozens.magnitude 1
    a12 = SY::Amount.magnitude 12
    mda = @amount_in_dozens.measure of: SY::Amount
    r, w = mda.r, mda.w
    ra = r.( a12.amount )
    @amount_in_dozens.magnitude ra
    ra = @amount_in_dozens.read( a12 )
    assert_equal @amount_in_dozens.magnitude( 1 ),
                 @amount_in_dozens.read( SY::Amount.magnitude( 12 ) )
    assert_equal SY::Amount.magnitude( 12 ),
                 @amount_in_dozens.write( 1, SY::Amount )
    SY::Length.composition.must_equal SY::Composition.singular( :Length )
  end
end
