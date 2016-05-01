#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Acceptance tests for SY::Quantity.
# *****************************************************************

require_relative 'test_loader'

describe SY::Quantity do
  before do
    @Q, @D = SY::Quantity, SY::Dimension
    @T, @L = SY::Dimension[ :T ], SY::Dimension[ :L ]
  end

  describe "construction" do
    describe ".new" do
      it "can construct quantity from a dimension alone" do
        q = @Q.new dimension: @L
        q.must_be_kind_of @Q
        q.dimension.must_equal @L
      end

      it "can construct all other types of quantities" do
        skip
        flunk "Tests not written!"
      end
    end # describe ".new"

    describe ".of" do
      it "constructs a quantity from a dimension" do
        q = @Q.of( dimension: "LENGTH" )
        q.must_be_kind_of @Q
        q.dimension.must_equal @L
      end
    end # describe ".of"

    describe ".dimensionless" do
      it "constructs a dimensionless quantity" do
        q = @Q.dimensionless
        q.must_be_kind_of @Q
        assert q.dimension.zero?
      end
    end # describe ".dimensionless"

    describe ".standard" do
      it "imitates a constructor of standard quantities, " +
         "however, it actually relies on " +
         "Dimension#standard_quantity, which in turn relies on " +
         "Quantity.of constructor" do
        q = @Q.standard of: "L"
        q.must_equal @D[ "L" ].standard_quantity
      end
      
      it "allows naming via :name / :ɴ / :name! parameters" do
        @Q.standard( of: :L⁷, name: "Foobar" )
        @Q.standard( of: :L⁷, name: "Foobar" )
        @D[ "L⁷" ].standard_quantity.name.must_equal :Foobar
        @Q.standard( of: "L⁷", name!: "Foobar" )
        @D[ "L⁷" ].standard_quantity.name.must_equal :Foobar
        # Quantities have permanent names.
        -> { @Q.standard of: "L⁷", ɴ: "Baz" }.must_raise NameError
      end

      it "rejects malformed arguments" do
        -> { @Q.standard of: :TIME, ɴ: :Length, name!: :Length }
          .must_raise ArgumentError
        -> { @Q.standard of: :TIME, ɴ: :Length, foo: :bar }
          .must_raise ArgumentError
        -> { @Q.standard of: :TIME, ɴ: :Length, name: :foo }
          .must_raise ArgumentError
      end
    end # describe ".standard"

    describe ".scaled" do
      it "constructs a scaled quantity from a parent quantity" do
        length = @Q.standard of: :LENGTH
        # dm_length, meaning DecimetreLength, is upscaled from
        # length by a factor of 10. This is because the same
        # distance in dm_length is expressed by a 10 times greater
        # number than in metre length.
        dmLength = @Q.scaled from: length, factor: 10
        skip
        length.magnitude( 4.2 ).must_equal dmLength.magnitude( 42 )
      end # describe ".standard"
    end # describe ".scaled"

    describe ".derived" do
      it "..." do
        skip
        flunk "Tests not written!"
      end
    end

    describe ".composed" do
      it "..." do
        skip
        flunk "Tests not written!"
      end
    end

    describe "ways to name quantities" do
      it "works as usual when relying on NameMagic" do
        assert @Q.permanent_names?
        q = @Q.of dimension: "L", name: "Foo"
        q.name.must_equal :Foo
        r = @Q.of dimension: "L"
        r.name.must_be_nil
        -> { r.name = :Foo }.must_raise NameMagic::NameTaken
      end
    end
  end # describe "construction"

  describe SY::Quantity::Error do
    it "is available" do
      assert @Q::Error < StandardError
    end
  end

  describe SY::Quantity::NotRelated do
    it "is available" do
      assert @Q::NotRelated < @Q::Error
    end
  end

  describe "type inquirers" do
    describe "#derived?" do
      it "..." do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#scaled?" do
      it "..." do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#nonstandard?" do
      it "..." do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#composed?" do
      it "..." do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#basic?" do
      it "..." do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#standard?" do
      it "tells whether the quantity is standard" do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#dimensionless?" do
      it "tells whether the quantity is dimensionless" do
        skip
        flunk "Tests not written!"
      end
    end
  end # describe "type inquirers"

  describe "Quantity.function" do
    # FIXME: I feel uncertain about this particular describe block.
    it "must be specifiable" do
      skip
      f = SY::Quantity::Function.ratio( 3600 )
      time_in_hours = SY::Quantity.of( @T, function: f )
      time_in_hours.function.( 1 ).must_equal 3600
      time_in_hours.function.inverse.( 3600 ).must_equal 1
    end

    it "must be behave as identity unless specified otherwise" do
      skip
      q = SY::Quantity.of( @T )
      q.function.( 42 ).must_equal 42
      q.function.inverse_closure.( 42 ).must_equal 42
    end
  end

  # FIXME: Now let's get to the important business. As explained in
  # the file sy/quantity/term.rb, multiplication of quantities is
  # not a simple business. Paying attention to dimensionality is a
  # useful crutch, but the actual algebraic structure of quantities
  # together with their multiplication operator (whatever it is
  # called) relies not on dimensions, but on established quantity
  # multiplication rules. Each rule is an equation with a quantity
  # term on the left hand side and a quantity on the right hand
  # side. Any term can be transformed, at any moment, by any
  # rule. In this sense, the rules are dimensions of a grid in
  # which we can perform walks, and in which every node is
  # equivalent to others.  Given a certain node (implied by the
  # supplied term), we must perform search of the grid in order to
  # find such node, that is sufficiently beautiful to be presented
  # as the result. If no more beautiful node can be found than the
  # one supplied, the supplied node is returned back as the
  # result. So there is always some result, the question only is
  # when to give up.
  #
  # In order for quantity multiplication to work, two things are
  # needed: Quantity term class (to which the quantities being
  # multiplied together are converted) and a set of quantity
  # composition rules.
  
  describe "setting a quantity composition rule" do
    before do
      # Let us first construct 2 brand new, dimensionless, nameless
      # quantities.
      @q1 = SY::Quantity.dimensionless
      @q2 = SY::Quantity.dimensionless
    end
    
    it "we now set the composition rule simply by constructing " +
       "another quantity from their product" do
      # Since nothing else is known about @q1 and @q2 yet, if the
      # terms containing them are submitted for reduction (which
      # should actually be called "beautification"), nothing
      # happens.
      
      skip
      
      Term[ @q1 => 1, @q2 => 1 ].beautify
        .must_equal Term[ @q1 => 1, @q2 => 1 ]
      Term[ @q1 => 1, @q2 => 2 ].beautify
        .must_equal Term[ @q1 => 1, @q2 => 2 ]
      Term[ @q1 => 2, @q2 => 1 ].beautify
        .must_equal Term[ @q1 => 2, @q2 => 1 ]
      Term[ @q1 => 1, @q2 => -1 ].beautify
        .must_equal Term[ @q1 => 1, @q2 => -1 ]
      Term[ @q1 => -1, @q2 => 1 ].beautify
        .must_equal Term[ @q1 => -1, @q2 => 1 ]
      
      # And perhaps
      
      Term[ @q1 => 1, @q2 => 1 ].reduce
        .must_equal Quantity[ @q1 => 1, @q2 => 1 ]
      # etc.
      
      # To understand, with term such as
      
      Term[ @q1 => 1, @q2 => 2 ]
      
      # The system should already consider the possibilities such
      # as
      
      Term[ Quantity[ @q1 => 1, @q2 => 2 ] => 1 ]

      # or

      Term[ Quantity[ @q1 => 1, @q2 => 1 ] => 1, @q2 => 1 ]
      
      # But should reject these possibilities on the grounds of
      # them not being more beautiful than the starting term,
      # because there is nothing special about quantity
      # 
      # Quantity[ @q1 => 1, @q2 => 1 ]
      #
      # or quantity
      #
      # Quantity[ @q1 => 1, @q2 => 2 ]
      # 
      # It is interesting to note that each new considered node in
      # fact represents a new dimension, which leads to very quick
      # explosion of the nodes to search. But this is the
      # systematic way of doing it.
      # 
      # So nothing changes by simply writing

      q3 = @q1 * @q2

      # because the system already knew and thought (or could
      # potentially think) about @q1 * @q2 before, and the fact
      # that we assigned it to the local variable q3 is not making
      # it any more beautiful to the system.
      
      # However, if we name q3

      q3.name = "SomethingSpecial"

      # The system might (depending on the exact coding) have a
      # reason to prefer term

      Term[ q3 => 1 ]

      # to term

      Term[ @q1 => 1, @q2 => 1 ]
      
      # What made @q1 and @q2 special and beautiful (in term-making
      # sense) was the fact that we defined them through special
      # constructor
      
      Quantity.dimensionless
      
      # The question is, do we need the table of quantities? Can't
      # we do with the multiplication table? I think it's better
      # not to keep the table of quantities (or at least not
      # consider it when simplifying terms) exactly because for
      # some reason, the user might decide to define disposable
      # quantities, of which already a small number would make work
      # considerably more difficult for the multiplication
      # table. NameMagic already keeps the registry of instances by
      # default, which is not a big problem, because user is not
      # expected to go on defining infinite number of disposable
      # quantities, but anyway... Perhaps what if NameMagic could
      # be told not to keep the registry of instances in some
      # situations? And use slower ObjectSpace sweep to find the
      # instances instead? And make each object holdp its own name
      # in @name instance variable instead of keeping it centrally
      # in the instance registry? That way the garbage collection
      # wouldn't be impeded...
      
      # Going back to the above, the quantities @q1 and @q2 either
      # themselves answer the question about wheter they are
      # special or not, or term-beautifying algorithm finds them
      # beautiful through instance registry and the fact that they
      # were defined via Quantity.dimensionless constructor, or it
      # finds them special by the fact that the user asked the
      # question using them, such as
      
      Term[ @q1 => 1, @q2 => 1 ].beautify
      
      # Since the beautificator never heard about @q1 and @q2
      # before, it is possible to make the mere fact that the user
      # uses these objects in the query make the beautificator
      # start thinking that they are special. So in this third
      # option, the beautificator would itself have the table of
      # quantity instances, but not of all instances ever created
      # in the system, but only of the instances submitted to the
      # beautificator (or multiplication table, as we call it now)
      # as factors of the terms to beautify. (This seems to call
      # for making a Quantity::MultiplicationTable class rather
      # than using a hash sitting in a constant. The class can be
      # instantiated, played with and discarded. On the other hand,
      # the hash sitting in a constant would remember all the
      # quantities we ever presented to it.)
      
      # Another idea: The beautificator should not go for reducing
      
      Term[ @q1 => 6 ].beautify
      
      # into
      
      Term[ Quantity[ @q1 => 3 ] => 2 ]
      
      # in spite of the fact that the sum of the exponents in the
      # second case is less than 6. The big difference is, @q1 is
      # special (not composed, mentioned to the beautificator by
      # the user or whatever), while Quantity[ @q1 => 3 ] is
      # composed.
      
      # So what should happen now when the user, for the first
      # time, asks the beautificator to
      
      Term[ Quantity[ @q1 => 3 ] => 2 ].beautify
      
      # This is a tough call, because the system would earlier
      # prefer
      
      Term[ @q1 => 6 ]
      
      # but the user allmighty now explicitly mentioned
      #
      # Quantity[ @q1 => 3 ]
      # in the query! I think that user allmighty should be
      # required to go into further lengths to make the
      # beautificator think that
      #
      # Quantity[ @q1 => 3 ]
      # 
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
      
      # Volume in the sense of cubic metres is not such a favorite
      # physical quantity at all. The user will probably appreciate
      # output
      
      Term[ Length: 1, Mass: 1, Time: -2 ] #=> Term[ Energy: 1 ]
      
      # and maybe also
      
      Term[ Length: 3 ].beautify  #=> Term[ Volume: 1 ]
      
      # But the question is ... no, I took the right approach
      # originally.  I took thoroughly right approach originally.
      # Perhaps the above contains some good ideas, but the
      # beautificator as of now does a lot of work automatically,
      # plus it allows the user to specify more rules.
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

  describe "#*" do
    it "should always return the same quantity instance" do
      skip
      product = @Time * @Length
      product.must_be_kind_of @Q
      product.dimension.must_equal SY::Dimension[ "T.L" ]
      assert product.equal? @Time * @Length
      assert product.equal? @Length * @Time
    end

    it "should perform composition of the quantities' functions" do
      skip
      f3600 = SY::Quantity::Function.ratio 3600
      time_in_hours = SY::Quantity.of @T, function: f3600
      time_in_hours.function.( 1 ).must_equal 3600
      f1000 = SY::Quantity::Function.ratio 1000
      length_in_km = SY::Quantity.of @L, function: f1000
      product = time_in_hours * length_in_km
      product.function.( 1 ).must_equal 3_600_000
      product.function.inverse_closure.( 3_600_000 ).must_equal 1
      
      speed_km_per_h = length_in_km / time_in_hours
      speed_km_per_h.function.inverse_closure( 10 ).must_equal 36
      speed_km_per_h.function.( 36 ).must_equal 10
    end
    
    describe "multiplication of standard quantities" do
      it "should return a the standard quantity" do
        skip
        product = @T.standard_quantity * @L.standard_quantity
        assert product.equal? ( @T + @L ).standard_quantity
      end
    end
  end # describe "multiplication of two quantities"
  
  describe "division of two quantities" do
    it "should always return the same quantity instance" do
      skip
      result = @Length / @Time
      result.must_be_kind_of SY::Quantity
      result.dimension.must_equal SY::Dimension[ "L.T⁻¹" ]
      assert result.equal? @Length / @Time
    end
    
    it "should perform composition of the quantities' functions" do
      skip
      f3600 = SY::Quantity::Function.ratio 3600
      time_in_hours = SY::Quantity.of @T, function: f3600
      time_in_hours.function.( 1 ).must_equal 3600
      f1000 = SY::Quantity::Function.ratio 1000
      length_in_km = SY::Quantity.of @L, function: f1000
      speed_km_per_h = length_in_km / time_in_hours
      speed_km_per_h.function.inverse_closure.( 10 ).must_equal 36
      speed_km_per_h.function.( 36 ).must_equal 10

      dozen_amount = @Amount / 12
      price = Quantity.dimensionless
      price_per_dozen = price / dozen_amount
    end

    describe "multiplication of standard quantities" do
      it "should return a the standard quantity" do
        skip
        product = @T.standard_quantity * @L.standard_quantity
        assert product.equal? ( @T + @L ).standard_quantity
      end
    end
  end # describe "division of two quantities"

  describe "addition of two quantities" do
    it "generally works only when both quantities are the same" do
      skip
      -> { @Time + @Length }
        .must_raise SY::Dimension::Error
      -> { @Time + SY::Quantity.of( @T ) }
        .must_raise SY::Quantity::Error
      assert @Time.equal? @Time + @Time
    end

    it "works when two equidimensional quantites are declared " +
       "compatible" do
      skip
      flunk "Tests not written, features not ripe!"
    end
  end # describe "addition of two quantities"

  describe "subtraction of two quantities" do
    it "generally works only when both quantities are the same" do
      skip
      -> { @Time - @Length }
        .must_raise SY::Dimension::Error
      -> { @Time - SY::Quantity.of( @T ) }
        .must_raise SY::Quantity::Error
      assert @Time.equal? @Time - @Time
    end

    it "works when two equidimensional quantites are declared " +
       "compatible" do
      skip
      flunk "Tests not written, features not ripe!"
    end
  end # describe "subtraction of two quantities"

  describe "multiplication of a quantity by a number" do
    it "should result in another, rescaled quantity" do
      skip
      flunk "Tests not written!"
    end

    it "also works when number is the first operand" do
      skip
      flunk "Tests not written!"
    end
  end

  describe "division of a quantity by a number" do
    it "should result in another, rescaled quantity" do
      skip
      flunk "Tests not written!"
      dozen_amount = @Amount / 12
    end
  end

  describe "inverting a quantity" do
    it "should be possible by #inverse method" do
      skip
      flunk "Tests not written!"
    end
  end

  describe "division of a number by a quantity" do
    it "should result in another, rescaled quantity" do
      skip
      flunk "Tests not written!"
      frequency = 1 / time
      dozens_frequency = 12 / time
    end
  end

  describe "addition of a number to a quantity" do
    it "should result in another quantity with specified offset" do
      skip
      flunk "Tests not written!"
    end

    it "should be commutative" do
      skip
      flunk "Tests not written!"
    end
  end

  describe "subtraction of a number from a quantity" do
    it "should result in another quantity with specified offset" do
      skip
      flunk "Tests not written!"
    end
  end

  describe "negation of a quantity" do
    it "should work like multiplying the quantity with -1" do
      skip
      flunk "Tests not written!"
    end
  end

  describe "subtraction of a quantity from a number" do
    it "should also be possible and behave as expected" do
      skip
      flunk "Tests not written!"
    end
  end

  describe "raising a quantity to a power" do
    it "should work for integer exponents" do
      skip
      flunk "Tests not written!"
    end
  end

  describe "parametrized subclass Quantity#Magnitude" do
    it "should be present" do
      skip
      q = SY::Quantity.of( @T )
      assert q.Magnitude < SY::Magnitude
      assert q.Magnitude.quantity.equal? q
      q.Magnitude.inspect.must_equal "something.Magnitude"
    end
  end

  describe "#magnitude" do
    it "should return a magnitude of the receiver quantity" do
      q = @Q.standard( of: "L" )
      m = q.magnitude( 42 )
      m.must_be_kind_of SY::Magnitude
      m.quantity.must_equal( q )
      m.number.must_equal( 42 )
    end
  end

  describe "other public methods" do
    before do
      @Length, @Time = @Q.standard( of: @L ), @Q.standard( of: @T )
    end
    
    describe "#conversion_function_to" do
      it "returns the conversion function to a related quantity" do
        skip
        flunk "Tests not written!"
      end
    end
    
    describe "#conversion_function_from" do
      it "returns the required conversion function" do
        i = @Time.conversion_function_from @Time
        i.( 1.0 ).must_equal 1.0
        skip
        dm_length = @Q.scaled from: @q1, factor: 10.0
        d = @q1.conversion_function to: dm_length
        d.( 1.0 ).must_equal 10.0
        d = @q1.conversion_function from: dm_length
        d.( 10.0 ).must_equal 1.0
        cm_length = @Q.scaled from: dm_length, factor: 10.0
        km_length = @Q.scaled from: @q1, factor: 0.001
        f = cm_length.conversion_function from: km_length
        f.( 1.0 ).must_equal 100_000
        g = cm_length.conversion_function to: km_length
        g.( 200_000 ).must_equal 2.0
      end
      
      it "raises error if the quantities are not related" do
        skip
        -> { @Time.conversion_function_from @Length }
          .must_raise SY::Quantity::Error
      end
    end
  end # describe "other public methods" 

  describe "protected methods" do
    before do
      @Length, @Time = @Q.standard( of: @L ), @Q.standard( of: @T )
      @dm_Length = @Q.scaled from: @Length,
                                       factor: 10.0
      @cm_Length = @Q.scaled from: @cm_Length,
                                       factor: 10.0
      @km_Length = @Q.scaled from: @Length,
                                       factor: 0.001
    end

    describe "#function_sequence_to" do
      it "..." do
        skip
        flunk "Test not written!"
      end
    end
    
    describe "#path_to" do
      it "returns a path to another quantity" do
        skip
        flunk "Test not written!"
      end

      it "raises error when the quantities are not related" do
        skip
        begin
          @Time.send :path_to, @Length
        rescue SY::Quantity::Error => error
          error.message.must_include "not related"
        else flunk "SY::Quantity::Error expected!" end
      end
    end

    describe "#path_from" do
      it "returns a path from another quantity to self" do
        @Time.send( :path_from, @Time ).must_equal []
        skip
        flunk "Test not finished!"
      end
      
      it "raises error when the quantities are not related" do
        skip
        begin
          @Time.send :path_from, @Length
        rescue SY::Quantity::Error => error
          error.message.must_include "not related"
        else flunk "SY::Quantity::Error expected!" end
      end
    end
  end # describe "protected mathods"

  describe "private methods" do
    describe "private method #multiply_by_number" do
      it "constructs a scaled quantity" do
        skip
        dm_length = @Q.of dimension: "L", factor: 0.1
        cm_length = dm_length.send :multiply_by_number, 10
        dm_length.magnitude( 1 )
          .must_equal cm_length.magnitude( 10 )
      end
    end
    
    describe "private method #divide_by_number" do
      it "..." do
        skip
        flunk "Tests not written!"
      end
    end
    
    describe "private method #multiply_by_quantity" do
      it "..." do
        skip
        # FIXME: This is the difficult part. #multiply_by_quantity
        # delegates its work to SY::Quantity::Term. The latter
        # performs term reduction to a quantity, the hard part of
        # SY.
        flunk "Tests not written!"
      end
    end
    
    describe "private method #divide_by_quantity" do
      it "..." do
        skip
        # FIXME:  Like  #multiply_by_quantity,  #divide_by_quantity
        # also  delegates its  work to  SY::Quantity::Term and  its
        # multiplication  table. Quantities  form  a  graph ...  an
        # infinite grid  whose nodes  correspond to  the individual
        # terms connected along the dimensions corresponding to the
        # established quantity compositions. A quantity composition
        # is an  equation t1 ==  t2, where  t1 and t2  are quantity
        # terms t1  ≠ t2. Using such  equation, given a term  t, an
        # infinite number of  equivalent terms can be  found of the
        # form t  * t1**n  * t2**(-n),  where n  is an  integer. In
        # other words, when the number of known compositions is nc,
        # the   number  of   terms   with   -1  <=   n   <=  1   is
        # 3**nc.  Practically,  if  there   is  10  known  quantity
        # compositions, we have 50_049 term expansions to search if
        # we limit ourselves to -1 <= n <= 1. What we are searching
        # for  is good  simplification. Should  we want  to perform
        # more thorough search and go eg. for -4 <= n <= 4, with 10
        # compositions, we would have to  search by brute force 3.5
        # billion terms compositions. Brute  force does not seem to
        # be good enough.
        # 
        # However, since terms are composed of named or otherwise
        # officially introduced quantities, it may often happen
        # that some of the term expansions to search, especially
        # when the number of known compositions is high, could be
        # rejected on the grounds of having officially introduced
        # quantities in too high exponents. In this way, we would
        # limit the search space to the volume where exponents e of
        # known quantities are -l <= e <= l, where l is the chosen
        # limit. This would seem to help a bit.
        #
        # Let's prepare the classes with basic functionality first.
        flunk "Tests not written!"
      end
    end    
  end # describe "private methods"
end # describe SY::Quantity

# FIXME: These acceptance tests are legacy from SY 2.0.
# 
# Fortunately, this is just a short sequence of tests, so once
# the new set of the acceptance tests is done, it should be
# possible to go through these earlier tests line by line and make
# sure that no line brings anything new to the testing
# table. (After which they can be deleted.)
# 
describe SY::Quantity do
  before do
    skip
    @q1 = SY::Quantity.new of: '∅'
    @q2 = SY::Quantity.dimensionless
    skip
    @amount_in_dozens =
      begin
        SY.Quantity( "AmountInDozens" )
      rescue
        SY::Quantity.dimensionless amount: 12, ɴ: "AmountInDozens"
      end
    @inch_length = 
      begin
        SY.Quantity( "InchLength" )
      rescue NameError
        SY::Quantity.of SY::Length.dimension, ɴ: "InchLength"
      end
  end

  it "should behave as expected" do
    skip
    refute_equal @q1, @q2
    assert @q1.absolute? && @q2.absolute?
    assert @q1 == @q1.absolute
    assert_equal false, @q1.relative?
    assert_equal SY::Composition.new, @q1.composition
    @q1.set_composition SY::Composition[ SY::Amount => 1 ]
    assert_equal SY::Composition[ SY::Amount => 1 ],
                 @q1.composition
    @amount_in_dozens.must_be_kind_of SY::Quantity
    d1 = @amount_in_dozens.magnitude 1
    a12 = SY::Amount.magnitude 12
    mda = @amount_in_dozens.measure of: SY::Amount
    r, w = mda.r, mda.w
    ra = r.( a12.amount )
    @amount_in_dozens.magnitude ra
    ra = @amount_in_dozens.read( a12 )
    @amount_in_dozens.read( SY::Amount.magnitude( 12 ) )
      .must_equal @amount_in_dozens.magnitude( 1 )
    assert_equal SY::Amount.magnitude( 12 ),
                 @amount_in_dozens.write( 1, SY::Amount )
    SY::Length.composition
      .must_equal SY::Composition.singular( :Length )
  end
end
