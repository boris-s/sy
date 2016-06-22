#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# THIS IS SPEC-STYLE TEST FILE FOR SY PHYSICAL UNITS LIBRARY
# *****************************************************************

# The following will load Ruby spec-style library
require 'mathn'
require 'minitest/autorun'

# The following will load SY library
# require 'sy'
require './../lib/sy'

# *****************************************************************
# THE SPECIFICATIONS START HERE
# *****************************************************************
describe SY do
  it "should have basic assets" do
    # Basic physical dimensions:
    SY::BASE_DIMENSIONS.to_a.sort
      .must_equal [ [:L, :LENGTH], [:M, :MASS], [:T, :TIME],
                    [:Q, :ELECTRIC_CHARGE], [:Θ, :TEMPERATURE] ].sort
    
    # Standard unit prefixes:
    SY::PREFIX_TABLE.map{|row| row[:full] }.sort
      .must_equal [ "exa", "peta", "tera", "giga", "mega", "kilo",
                    "mili", "micro", "nano", "pico", "femto", "atto",
                    "hecto", "deka","deci", "centi", "" ].sort
  end
end

describe SY::Dimension do
  it "should" do
    # Dimension#new should return same instance when asked twice.
    assert_equal *[ :L, :L ].map { |d| SY::Dimension.new( d ).object_id }

    # Other Dimension constructors: #basic and #zero.
    SY::Dimension.basic( :L ).must_equal SY.Dimension( :L )
    SY::Dimension.zero.must_equal SY::Dimension.new( '' )

    # SY should have table of standard quantities.
    assert SY.Dimension( :L ).standard_quantity.is_a? SY::Quantity

    # Instances should provide access to base dimensions.
    assert_equal [0, 1], [:L, :M].map { |ß| SY.Dimension( :M ).send ß }
    assert_equal [1, 0], [:L, :M].map { |ß| SY.Dimension( :L )[ß] }

    # #to_a, #to_hash, #zero?
    ll = SY::BASE_DIMENSIONS.letters
    SY.Dimension( :M ).to_a.must_equal ll.map { |l| l == :M ? 1 : 0 }
    SY.Dimension( :M ).to_hash.must_equal Hash[ ll.zip SY.Dimension( :M ).to_a ]
    SY.Dimension( :M ).zero?.must_equal false
    SY::Dimension.zero.zero?.must_equal true
    SY.Dimension( nil ).to_a.must_equal [ 0, 0, 0, 0, 0 ]

    # Dimension arithmetic
    assert SY.Dimension( :L ) + SY.Dimension( :M ) == SY.Dimension( 'L.M' )
    assert SY.Dimension( :L ) - SY.Dimension( :M ) == SY.Dimension( 'L.M⁻¹' )
    assert SY.Dimension( :L ) * 2 == SY.Dimension( 'L²' )
    assert SY.Dimension( M: 2 ) / 2 == SY.Dimension( :M )
  end
end

describe SY::Measure do
  it "should" do
    i = SY::Measure.identity
    a, b = SY::Measure.new( ratio: 2 ), SY::Measure.new( ratio: 3 )
    assert_equal 1, i.ratio
    assert_equal 4, a.r.( 8 )
    assert_equal 3, b.w.( 1 )
    assert_equal 6, (a * b).w.( 1 )
    assert_equal 2, (a * b / b).w.( 1 )
    assert_equal 4, (a ** 2).w.( 1 )
    assert_equal 2, a.inverse.r.( 1 )
  end
end

describe SY::Composition do
  it "should" do
    assert_equal SY::Amount, SY.Dimension( :∅ ).standard_quantity
    a = SY::Composition[ SY::Amount => 1 ]
    l = SY::Composition[ SY::Length => 1 ]
    assert SY::Composition.new.empty?
    assert a.singular?
    assert l.atomic?
    assert_equal SY::Composition[ SY::Amount => 1, SY::Length => 1 ], a + l
    assert_equal SY::Composition[ SY::Amount => 1, SY::Length => -1 ], a - l
    assert_equal SY::Composition[ SY::Length => 2 ], l * 2
    assert_equal l, l * 2 / 2
    assert_equal l.to_hash, (a + l).simplify.to_hash
    assert_equal SY::Amount, a.to_quantity
    assert_equal SY::Length, l.to_quantity
    assert_equal( SY.Dimension( 'L' ),
                  SY::Composition[ SY::Amount => 1, SY::Length => 1 ]
                    .to_quantity.dimension )
    assert_equal SY.Dimension( 'L' ), l.dimension
    assert_kind_of SY::Measure, a.infer_measure
  end
end

describe SY::Quantity, SY::Magnitude do
  before do
    @q1 = SY::Quantity.new of: '∅'
    @q2 = SY::Quantity.dimensionless
    @amount_in_dozens = begin
                          SY.Quantity( "AmountInDozens" )
                        rescue
                          SY::Quantity.dimensionless amount: 12, ɴ: "AmountInDozens"
                        end
    @inch_length = begin
                     SY.Quantity( "InchLength" )
                   rescue NameError
                     SY::Quantity.of SY::Length.dimension, ɴ: "InchLength"
                   end
  end

  it "should" do
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

  describe "Magnitude, Unit" do
    before do
      @m1 = 1.metre
      @inch = SY::Unit.standard( of: @inch_length, amount: 2.54.cm,
                                 ɴ: 'inch', short: '”' )
      @i1 = @inch_length.magnitude 1
      @il_measure = @inch_length.measure( of: SY::Length )
    end
    
    it "should" do
      @m1.quantity.must_equal SY::Length.relative
      @inch_length.colleague.name.must_equal :InchLength±
      @m1.to_s.must_equal "1.m"
      @i1.amount.must_equal 1
      assert_kind_of SY::Measure, @il_measure
      assert_kind_of Numeric, @il_measure.ratio
      assert_in_epsilon 0.0254, @il_measure.ratio
      @il_measure.w.( 1 ).must_be_within_epsilon 0.0254
      begin
        impossible_mapping = @inch_length.measure( of: SY::Amount )
      rescue SY::DimensionError
        :dimension_error
      end.must_equal :dimension_error
      # reframing
      1.inch.reframe( @inch_length ).amount.must_equal 1
      1.inch.( @inch_length ).must_equal 1.inch
      1.inch.( SY::Length ).must_equal 2.54.cm
      @inch_length.magnitude( 1 ).to_s.must_equal "1.”"
      1.inch.in( :mm ).must_be_within_epsilon 25.4
      assert_equal SY::Unit.instance( :SECOND ), SY::Unit.instance( :second )
    end
  end

  describe "expected behavior" do
    it "should" do
      assert_equal SY::Unit.instance( :SECOND ), SY::Unit.instance( :second )

      # Length quantity and typical units
      SY::METRE.must_be_kind_of SY::Unit
      SY::METRE.absolute?.must_equal true
      1.metre.absolute.must_equal SY::METRE
      # FIXME
      # assert 1.metre.absolute != 1.metre.relative
      1.metre.relative.relative?.must_equal true
      
      
      SY::METRE.relative.must_equal 1.metre
      1.m.must_equal 1.metre
      1.m.must_equal 1000.mm
      SY::METRE.quantity.name.must_equal :Length
      assert_in_delta 0.9.µm, 900.nm, 1e-6.nm
      [ 1.m, 1.m ].min.must_equal 1.m
      1.m + 1.m == 1.m
      assert_in_epsilon 1.m, 1.m, 0.1
      600.m.must_equal 0.6.km
      SY::METRE.quantity.must_equal SY::Length
      SY::Length.dimension.must_equal SY.Dimension( :L )
      SY.Dimension( :L ).standard_quantity.must_equal SY::Length
      SY::Length.standard_unit.must_equal SY::METRE
      SY::METRE.amount.must_equal 1
      SY::METRE.mili.amount.must_equal 0.001
      3.km.in( :dm ).must_equal 30_000
      ( 1.m + 20.cm ).must_equal 1_200.mm
      assert 1.mm.object_id != 1.mm.object_id
      assert 1.mm == 1.mm
      assert 1.01.m != 1.m
      assert_equal 1, 1.01.m <=> 1.m
      assert_equal 0, 1.00.m <=> 1.m
      assert_equal -1, 0.99.m <=> 1.m
      assert 0.9.mm < 1.mm
      assert 1.1.mm > 1.09.mm
      assert ( 0.1.m - ( 1.m - 0.9.m ) ).abs < 1.nm.abs
      # Mass quantity and typical units
      SY::KILOGRAM.must_be_kind_of SY::Unit
      SY::GRAM.must_be_kind_of SY::Unit
      assert SY::Mass.standard_unit.equal?( SY::KILOGRAM )
      1.kilogram.must_be_kind_of SY::Magnitude
      1.gram.must_be_kind_of SY::Magnitude
      1.kilogram.absolute.quantity.must_equal SY::Mass
      1.gram.absolute.quantity.must_equal SY::Mass
      ( SY::KILOGRAM * 1 ).must_equal SY::GRAM * 1000
      1.kilogram.must_equal 1000.g
      1.kg.to_f.must_equal 1
      1.g.to_f.must_equal 0.001
      1.miligram.must_equal 0.001.g
      1.mg.must_equal 1.miligram
      1.µg.must_equal 0.001.miligram
      1.ng.must_equal 0.001.microgram
      1.pg.quantity.must_equal 0.001.nanogram.quantity
      1.pg.amount.must_be_within_epsilon 0.001.nanogram.amount, 1e-6
      assert_equal 1.g, [1.g, 2.g].min
      assert_equal 1.mg, 1.g * 0.001
      1.pg.abs.must_be_within_epsilon 0.001.nanogram.abs, 1e-6
      SY::TON.must_be_kind_of SY::Unit
      1.ton.must_equal 1000.kg
      1.t.must_equal 1.ton
      1.kt.must_equal 1000.ton
      1.Mt.must_equal 1000.kiloton
      1.mm.quantity.name.must_equal :Length±
      SY::Length.standard_unit.must_equal SY::METRE
      SY::Length.standard_unit.name.must_equal :METRE
      SY::Length.standard_unit.must_equal SY::METRE
      SY.Quantity( :Length ).object_id.must_equal SY::Length.object_id
      SY::Length.relative.object_id.must_equal SY.Quantity( :Length± ).object_id
      SY.Quantity( :Length± ).colleague.name.must_equal :Length
      SY.Quantity( :Length± ).colleague.class.must_equal SY::Quantity
      SY.Quantity( :Length± ).colleague.object_id.must_equal SY::Length.object_id
      SY.Quantity( :Length± ).send( :Unit ).object_id
        .must_equal SY::Length.send( :Unit ).object_id
      1.mm.quantity.standard_unit.name.must_equal :METRE
      1.mm.to_s.must_equal "0.001.m"
      1.mm.inspect.must_equal "#<±Magnitude: 0.001.m >"
      1.µs.inspect.must_equal "#<±Magnitude: 1e-06.s >"

      SY::Area.dimension.must_equal SY.Dimension( :L² )
      SY::Area.composition.must_equal SY::Composition[ SY::Length => 2 ]
      
      SY::AMPERE.name.must_equal :AMPERE
      SY::AMPERE.abbreviation.must_equal :A
      SY::AMPERE.dimension.must_equal 1.A.dimension
      SY.Magnitude( of: SY::ElectricCurrent, amount: 1 ).must_equal 1.A.absolute
      1.A.quantity.must_equal SY::ElectricCurrent.relative
      1.A.quantity.standard_unit.name.must_equal :AMPERE
      1.A.to_s( SY::AMPERE ).must_equal "1.A"
      1.A.to_s.must_equal "1.A"
      1.A.amount.must_equal 1
      1.A.quantity.standard_unit.abbreviation.must_equal :A
      1.A.inspect.must_equal "#<±Magnitude: 1.A >"
      
      1.l⁻¹.reframe( SY::Molarity ).quantity.must_equal SY::Molarity
      x = ( SY::Nᴀ / SY::LITRE )
      x = x.reframe( SY::Molarity )
      y = 1.molar.absolute
      y.quantity.must_equal x.quantity
      y.amount.must_equal y.amount
      SY::MoleAmount.protected?.must_equal true
      SY::LitreVolume.protected?.must_equal true
      SY::MOLAR.quantity.name.must_equal :Molarity
      m = 1.µM
      1.µM.quantity.relative?.must_equal true
      1.µM.quantity.name.must_equal :Molarity±
      1.µM.quantity.absolute.name.must_equal :Molarity
      7.µM.must_be_within_epsilon 5.µM + 2.µM, 1e-6
      +1.s.must_equal 1.s
      -1.s.must_equal -1 * 1.s # must raisen
      assert_equal -(-(1.s)), +(1.s)
      1.s⁻¹.quantity.must_equal ( 1.s ** -1 ).quantity
      1.s⁻¹.quantity.must_equal ( 1 / 1.s ).quantity
      1.s⁻¹.amount.must_equal ( 1.s ** -1 ).amount
      1.s⁻¹.must_equal 1.s ** -1
      q1 = ( 1.s⁻¹ ).quantity
      q1.composition.to_hash.must_equal( { SY::Time => -1 } )

      q2 = ( 1 / 1.s ).quantity
      q2.composition.to_hash.must_equal( { SY::Time => -1 } )
      
      q1.relative?.must_equal true
      q2.relative?.must_equal true

      q1.object_id.must_equal q2.object_id
      ( 1.s⁻¹ ).quantity.object_id.must_equal ( 1 / 1.s ).quantity.object_id
      ( 1 / 1.s ).must_equal 1.s⁻¹
      1.s⁻¹.( SY::Frequency ).must_equal 1.Hz
      7.°C.must_equal( 8.°C - 1.K )
      (-15).°C.must_equal 258.15.K
      7000.µM.must_be_within_epsilon( 7.mM, 1e-9 )
      ::SY::Unit.instances.map do |i|
        begin
          i.abbreviation
        rescue
        end
      end.must_include :M
      SY::Unit.instances.names( false ).must_include :MOLE
      # Avogadro's number is defined directly in SY
      1.mol.quantity.object_id
        .must_equal SY::Nᴀ.unit.( SY::MoleAmount ).quantity.object_id
      SY::Nᴀ.unit.( SY::MoleAmount ).must_equal 1.mol
      0.7.mol.l⁻¹.amount.must_equal 0.7
      1.M.must_equal 1.mol.l⁻¹.( SY::Molarity )
      # (if #reframe conversion method is not used, different quantities
      # do not compare. Arithmetics is possible because Magnitude operators
      # mostly give their results only in standard quantities.
      
      # Avogadro's number is defined directly in SY
      1.mol.must_equal SY::Nᴀ.unit.( SY::MoleAmount )
      
      0.7.M.must_equal 0.7.mol.l⁻¹.( SY::Molarity )
      # (if #is_actually! conversion method is not used, current
      # implementation will refuse to compare different quantities,
      # even if their dimensions match)
      
      30.Hz.must_equal 30.s⁻¹.( SY::Frequency )
      
      # Dalton * Avogadro must be 1 gram
      ( 1.Da * SY::Nᴀ ).must_be_within_epsilon( 1.g, 1e-6 )
      
      # kilogram
      1.kg.must_equal 1000.g
      SY::Speed.dimension.must_equal SY::Dimension( "L.T⁻¹" )
      SY::Acceleration.dimension.must_equal SY::Dimension( "L.T⁻²" )
      SY::Force.dimension.must_equal SY::Dimension( "L.M.T⁻²" )
      ( 1.kg * 1.m.s⁻² ).( SY::Force ).must_be_within_epsilon 1.N, 1e-9
      
      # joule
      ( 1.N * 1.m ).( SY::Energy ).must_equal 1.J
      1e-23.J.K⁻¹.must_equal 1.0e-20.mJ.K⁻¹

      # pascal
      ( 1.N / 1.m ** 2 ).( SY::Pressure ).must_be_within_epsilon 1.Pa, 1e-9
      
      # watt
      ( 1.V * 1.A ).( SY::Power ).must_be_within_epsilon 1.W, 1e-9

      # Custom unit creation
      XOXO = SY::Unit.of SY::Volume, amount: 1.l
      assert_equal 1.l.( SY::Volume ), 1.xoxo.( SY::Volume )

      # TRIPLE_POINT_OF_WATER
      assert_equal SY::TRIPLE_POINT_OF_WATER, 0.°C.( SY::Temperature )
      assert_equal 273.15, 0.°C.in( :K )
      assert_equal SY::Unit.instance( :SECOND ), SY::Unit.instance( :second )
      assert_equal SY::TRIPLE_POINT_OF_WATER, 0.°C # coercion behavior

      # other tests
      assert_equal 1.m, 1.s * 1.m.s⁻¹
      assert_equal 1.µM.s⁻¹, 1.µM / 1.s
      assert_equal 1.m.s⁻¹, 1.m.s( -1 )
      assert_equal 2_000.mm.s⁻², 2.m.s( -2 )
      assert_equal 3.µM, 1.µM + 2.µM
      assert_equal SY::Amount, SY::Molarity / SY::Molarity
      assert_equal SY::Amount( 1 ), 1.µM / 1.µM
      assert_equal SY::Amount( 1 ), 1.µM / ( 1.µM + 0.µM )
      assert_equal 1.µM, 1.µM * 1.µM / ( 1.µM + 0.µM )
      assert_in_epsilon 1.µM, 1.µmol / 1.dm( 3 ).( SY::LitreVolume )
      
      assert_equal SY::Molarity.relative, 1.mol.l⁻¹.quantity
      assert_equal SY::MoleAmount.relative, 1.M.l.quantity
      
      
      assert_equal 1 / SY::Time, 1 / SY::Time
      assert_equal 1 / SY::Time.relative, 1 / SY::Time
      assert_equal ( 1 / SY::Time.relative ), 1.mol.s⁻¹.( 1 / SY::Time ).quantity
      assert_equal ( 1 / SY::Time ).object_id,
                   ( 1.0.µmol.min⁻¹.mg⁻¹ * 100.kDa ).( 1 / SY::Time ).quantity.object_id
      assert_equal SY::Time.magnitude( 1 ), SY::SECOND
    end

    describe "pretty representation" do
      it "should" do
        ( 1.0.m / 3.s ).to_s.must_be_kind_of String
        ( 1.0.m / 3.s ).to_s.must_equal "0.333.m.s⁻¹"

        ( 1.m / 7.01e7.s ).to_s.must_equal( "1.43e-08.m.s⁻¹" )
      end
    end

    describe "matrix integration" do
      it "should" do
        assert_equal Matrix[[60.mM], [60.mM]], Matrix[[1e-03.s⁻¹.M], [1e-3.s⁻¹.M]] * 60.s
      
        assert_equal Matrix[[5.m]], Matrix[[1.m.s⁻¹, 2.m.s⁻¹]] * Matrix.column_vector( [1.s, 2.s] )
        assert_equal Matrix[[2.m, 3.m], [4.m, 5.m]],
                     Matrix[[1.m, 2.m], [3.m, 4.m]] + Matrix[[1.m, 1.m], [1.m, 1.m]]
        assert_equal Matrix[[5.µM]], Matrix[[1.µM]] + Matrix[[2.µM.s⁻¹]] * Matrix[[2.s]]
        assert_equal Matrix[[1.s]], Matrix[[1]] * 1.s
        assert_equal Matrix[[1.s]], 1.s * Matrix[[1]]
      end
    end
  end
end

describe SY::Magnitude do
  it "should have working #<=> method" do
    assert_equal 0, 1.m <=> 100.cm
    assert_equal 1, 1.m <=> 99.cm
    assert_equal -1, 1.m <=> 101.cm
    assert_equal SY::Length.composition * 3, 1.m³.quantity.composition
    a, b = 10.hl, 1.m³
    assert_equal SY::Volume.relative, b.quantity
    assert_equal SY::LitreVolume.relative, a.quantity
    assert_equal [SY::LitreVolume], SY::Volume.coerces
    assert b.quantity.absolute.coerces?( a.quantity.absolute )
    assert b.quantity.coerces?( a.quantity )
    assert_equal 0, 1.l <=> 1.l
    assert_equal -1, 1.m³ <=> 11.hl
    assert_equal 1, 1.m³ <=> 9.hl
    assert_equal 1.dm³, 1.dm³
  end
end
