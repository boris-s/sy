#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Acceptance tests for SY at large.
# *****************************************************************

require_relative 'test_loader'

describe "general features" do
  it "should give method name collision warning" do
    skip
    # warn if prospective unit method name already defined
    flunk "Test not written!"
  end

  it "should give redefine warning" do
    skip
    # when trying to overshadow existing unit methods
    flunk "Test not written!"
  end
end

describe "dimensionless quantities and units" do
  it "should define Amount" do
    skip
    SY::Amount.must_be_kind_of SY::Quantity
    assert SY::Amount.standard?
  end

  it "should define UNIT" do
    skip
    SY::UNIT.must_be_kind_of SY::Unit
    SY::UNIT.quantity.must_equal SY::Amount
  end

  it "should define AVOGADRO_CONSTANT" do
    skip
    SY::Nᴀ.must_equal SY::AVOGADRO_CONSTANT
    SY::Nᴀ.must_be_within_epsilon 6.0221e23
  end

  it "define MoleAmount" do
    skip
    assert SY::MoleAmount.equal? Amount / Nᴀ
  end

  # FIXME: The interesting tests below.

  it "should attempt to define quantity Density" do
    skip
    # Density is not such a simple thing to say. Although commonly, people
    # will expect volumetric density with dimension M.L⁻³, there are many
    # other possible kinds of densities. I should check the terminology of
    # this physical unit.
    ( defined? SY::Density ).must_equal "constant"
  end

  it "should attempt to define quantity Frequency" do
    skip
    ( defined? SY::Frequency ).must_equal "constant"
  end

  it "should attempt to define quantity Frequency" do
    skip
    ( defined? SY::HERTZ ).must_equal "constant"
  end
end

describe "standard dimensionless quantity" do
  it "must be named Amount" do
    SY::Dimension.zero.standard_quantity.name.must_equal :Amount
  end

  it "must have standard unit named UNIT" do
    SY::UNIT.must_be_kind_of SY::Unit
    SY::UNIT.quantity.must_be_kind_of SY::Quantity
    SY::UNIT.quantity.must_equal SY::Amount
    SY::UNIT.number.must_equal 1
    skip
    # FIXME: The presence or absence of the commented out line
    # below in the tests depends on whether I want to have
    # standard unit unique to each quantity. At the moment,
    # this is not so.
    # 
    SY::Amount.standard_unit.name.must_equal :UNIT
  end
end

# describe "mole amount quantity" do
#   before do
#     @q = SY::MoleAmount
#   end

#   it "must be dimensionless" do
#     assert SY::MoleAmount.dimension.zero?
#   end

#   # FIXME: Write the tests for :coerces parameter.
# end


describe SY do
  it "should define the following quantities and units" do
    # # Length quantity and typical units
    # SY::METRE.must_be_kind_of SY::Unit
    # SY::METRE.absolute?.must_equal true
    # 1.metre.absolute.must_equal SY::METRE
    # # FIXME
    # # assert 1.metre.absolute != 1.metre.relative
    # 1.metre.relative.relative?.must_equal true
      
    # SY::METRE.relative.must_equal 1.metre
    # 1.m.must_equal 1.metre
    # 1.m.must_equal 1000.mm
    # SY::METRE.quantity.name.must_equal :Length
    # assert_in_delta 0.9.µm, 900.nm, 1e-6.nm
    # [ 1.m, 1.m ].min.must_equal 1.m
    # 1.m + 1.m == 1.m
    # assert_in_epsilon 1.m, 1.m, 0.1
    # 600.m.must_equal 0.6.km
    # SY::METRE.quantity.must_equal SY::Length
    # SY::Length.dimension.must_equal SY.Dimension( :L )
    # SY.Dimension( :L ).standard_quantity.must_equal SY::Length
    # SY::Length.standard_unit.must_equal SY::METRE
    # SY::METRE.amount.must_equal 1
    # SY::METRE.mili.amount.must_equal 0.001
    # 3.km.in( :dm ).must_equal 30_000
    # ( 1.m + 20.cm ).must_equal 1_200.mm
    # assert 1.mm.object_id != 1.mm.object_id
    # assert 1.mm == 1.mm
    # assert 1.01.m != 1.m
    # assert_equal 1, 1.01.m <=> 1.m
    # assert_equal 0, 1.00.m <=> 1.m
    # assert_equal -1, 0.99.m <=> 1.m
    # assert 0.9.mm < 1.mm
    # assert 1.1.mm > 1.09.mm
    # assert ( 0.1.m - ( 1.m - 0.9.m ) ).abs < 1.nm.abs

    # # Mass quantity and typical units
    # SY::KILOGRAM.must_be_kind_of SY::Unit
    # SY::GRAM.must_be_kind_of SY::Unit
    # assert SY::Mass.standard_unit.equal?( SY::KILOGRAM )
    # 1.kilogram.must_be_kind_of SY::Magnitude
    # 1.gram.must_be_kind_of SY::Magnitude
    # 1.kilogram.absolute.quantity.must_equal SY::Mass
    # 1.gram.absolute.quantity.must_equal SY::Mass
    # ( SY::KILOGRAM * 1 ).must_equal SY::GRAM * 1000
    # 1.kilogram.must_equal 1000.g
    # 1.kg.to_f.must_equal 1
    # 1.g.to_f.must_equal 0.001
    # 1.miligram.must_equal 0.001.g
    # 1.mg.must_equal 1.miligram
    # 1.µg.must_equal 0.001.miligram
    # 1.ng.must_equal 0.001.microgram
    # 1.pg.quantity.must_equal 0.001.nanogram.quantity
    # 1.pg.amount.must_be_within_epsilon 0.001.nanogram.amount, 1e-6
    # assert_equal 1.g, [1.g, 2.g].min
    # assert_equal 1.mg, 1.g * 0.001
    # 1.pg.abs.must_be_within_epsilon 0.001.nanogram.abs, 1e-6
    # SY::TON.must_be_kind_of SY::Unit
    # 1.ton.must_equal 1000.kg
    # 1.t.must_equal 1.ton
    # 1.kt.must_equal 1000.ton
    # 1.Mt.must_equal 1000.kiloton
    # 1.mm.quantity.name.must_equal :Length±
    # SY::Length.standard_unit.must_equal SY::METRE
    # SY::Length.standard_unit.name.must_equal :METRE
    # SY::Length.standard_unit.must_equal SY::METRE
    # SY.Quantity( :Length ).object_id.must_equal SY::Length.object_id
    # SY::Length.relative.object_id.must_equal SY.Quantity( :Length± ).object_id
    # SY.Quantity( :Length± ).colleague.name.must_equal :Length
    # SY.Quantity( :Length± ).colleague.class.must_equal SY::Quantity
    # SY.Quantity( :Length± ).colleague.object_id.must_equal SY::Length.object_id
    # SY.Quantity( :Length± ).send( :Unit ).object_id
    #   .must_equal SY::Length.send( :Unit ).object_id
    # 1.mm.quantity.standard_unit.name.must_equal :METRE
    # 1.mm.to_s.must_equal "0.001.m"
    # 1.mm.inspect.must_equal "#<±Magnitude: 0.001.m >"
    # 1.µs.inspect.must_equal "#<±Magnitude: 1e-06.s >"
      
    # SY::Area.dimension.must_equal SY.Dimension( :L² )
    # SY::Area.composition.must_equal SY::Composition[ SY::Length => 2 ]
      
    # SY::AMPERE.name.must_equal :AMPERE
    # SY::AMPERE.abbreviation.must_equal :A
    # SY::AMPERE.dimension.must_equal 1.A.dimension
    # SY.Magnitude( of: SY::ElectricCurrent, amount: 1 ).must_equal 1.A.absolute
    # 1.A.quantity.must_equal SY::ElectricCurrent.relative
    # 1.A.quantity.standard_unit.name.must_equal :AMPERE
    # 1.A.to_s( SY::AMPERE ).must_equal "1.A"
    # 1.A.to_s.must_equal "1.A"
    # 1.A.amount.must_equal 1
    # 1.A.quantity.standard_unit.abbreviation.must_equal :A
    # 1.A.inspect.must_equal "#<±Magnitude: 1.A >"
      
    # 1.l⁻¹.reframe( SY::Molarity ).quantity.must_equal SY::Molarity
    # x = ( SY::Nᴀ / SY::LITRE )
    # x = x.reframe( SY::Molarity )
    # y = 1.molar.absolute
    # y.quantity.must_equal x.quantity
    # y.amount.must_equal y.amount
    # SY::MoleAmount.protected?.must_equal true
    # SY::LitreVolume.protected?.must_equal true
    # SY::MOLAR.quantity.name.must_equal :Molarity
    # m = 1.µM
    # 1.µM.quantity.relative?.must_equal true
    # 1.µM.quantity.name.must_equal :Molarity±
    # 1.µM.quantity.absolute.name.must_equal :Molarity
    # 7.µM.must_be_within_epsilon 5.µM + 2.µM, 1e-6
    # +1.s.must_equal 1.s
    # -1.s.must_equal -1 * 1.s # must raisen
    # assert_equal -(-(1.s)), +(1.s)
    # 1.s⁻¹.quantity.must_equal ( 1.s ** -1 ).quantity
    # 1.s⁻¹.quantity.must_equal ( 1 / 1.s ).quantity
    # 1.s⁻¹.amount.must_equal ( 1.s ** -1 ).amount
    # 1.s⁻¹.must_equal 1.s ** -1
    # q1 = ( 1.s⁻¹ ).quantity
    # q1.composition.to_hash.must_equal( { SY::Time => -1 } )
      
    # q2 = ( 1 / 1.s ).quantity
    # q2.composition.to_hash.must_equal( { SY::Time => -1 } )
      
    # q1.relative?.must_equal true
    # q2.relative?.must_equal true
      
    # q1.object_id.must_equal q2.object_id
    # ( 1.s⁻¹ ).quantity.object_id.must_equal ( 1 / 1.s ).quantity.object_id
    # ( 1 / 1.s ).must_equal 1.s⁻¹
    # 1.s⁻¹.( SY::Frequency ).must_equal 1.Hz
    # 7.°C.must_equal( 8.°C - 1.K )
    # (-15).°C.must_equal 258.15.K
    # 7000.µM.must_be_within_epsilon( 7.mM, 1e-9 )
    # ::SY::Unit.instances.map do |i|
    #   begin
    #     i.abbreviation
    #   rescue
    #   end
    # end.must_include :M
    # SY::Unit.instance_names.must_include :MOLE
    # # Avogadro's number is defined directly in SY
    # 1.mol.quantity.object_id
    #   .must_equal SY::Nᴀ.unit.( SY::MoleAmount ).quantity.object_id
    # SY::Nᴀ.unit.( SY::MoleAmount ).must_equal 1.mol
    # 0.7.mol.l⁻¹.amount.must_equal 0.7
    # 1.M.must_equal 1.mol.l⁻¹.( SY::Molarity )
    # # (if #reframe conversion method is not used, different quantities
    # # do not compare. Arithmetics is possible because Magnitude operators
    # # mostly give their results only in standard quantities.
      
    # # Avogadro's number is defined directly in SY
    # 1.mol.must_equal SY::Nᴀ.unit.( SY::MoleAmount )
      
    # 0.7.M.must_equal 0.7.mol.l⁻¹.( SY::Molarity )
    # # (if #is_actually! conversion method is not used, current
    # # implementation will refuse to compare different quantities,
    # # even if their dimensions match)
      
    # 30.Hz.must_equal 30.s⁻¹.( SY::Frequency )
      
    # # Dalton * Avogadro must be 1 gram
    # ( 1.Da * SY::Nᴀ ).must_be_within_epsilon( 1.g, 1e-6 )
      
    # # kilogram
    # 1.kg.must_equal 1000.g
    # SY::Speed.dimension.must_equal SY::Dimension( "L.T⁻¹" )
    # SY::Acceleration.dimension.must_equal SY::Dimension( "L.T⁻²" )
    # SY::Force.dimension.must_equal SY::Dimension( "L.M.T⁻²" )
    # ( 1.kg * 1.m.s⁻² ).( SY::Force ).must_be_within_epsilon 1.N, 1e-9
      
    # # joule
    # ( 1.N * 1.m ).( SY::Energy ).must_equal 1.J
    # 1e-23.J.K⁻¹.must_equal 1.0e-20.mJ.K⁻¹
      
    # # pascal
    # ( 1.N / 1.m ** 2 ).( SY::Pressure ).must_be_within_epsilon 1.Pa, 1e-9
      
    # # watt
    # ( 1.V * 1.A ).( SY::Power ).must_be_within_epsilon 1.W, 1e-9
      
    # # pretty representation
    # ( 1.m / 3.s ).to_s.must_equal( "0.333.m.s⁻¹" )
    # ( 1.m / 7.01e7.s ).to_s.must_equal( "1.43e-08.m.s⁻¹" )
      
    # assert_equal 1.m, 1.s * 1.m.s⁻¹
    # assert_equal 1.µM.s⁻¹, 1.µM / 1.s
    # assert_equal 1.m.s⁻¹, 1.m.s( -1 )
    # assert_equal 2_000.mm.s⁻², 2.m.s( -2 )
    # assert_equal 3.µM, 1.µM + 2.µM
    # assert_equal SY::Amount, SY::Molarity / SY::Molarity
    # assert_equal SY::Amount( 1 ), 1.µM / 1.µM
    # assert_equal SY::Amount( 1 ), 1.µM / ( 1.µM + 0.µM )
    # assert_equal 1.µM, 1.µM * 1.µM / ( 1.µM + 0.µM )
    # assert_in_epsilon 1.µM, 1.µmol / 1.dm( 3 ).( SY::LitreVolume )

    # assert_equal SY::Molarity.relative, 1.mol.l⁻¹.quantity
    # assert_equal SY::MoleAmount.relative, 1.M.l.quantity
      
    # assert_equal 1 / SY::Time, 1 / SY::Time
    # assert_equal 1 / SY::Time.relative, 1 / SY::Time
    # assert_equal ( 1 / SY::Time.relative ), 1.mol.s⁻¹.( 1 / SY::Time ).quantity
    # assert_equal ( 1 / SY::Time ).object_id,
    #              ( 1.0.µmol.min⁻¹.mg⁻¹ * 100.kDa ).( 1 / SY::Time ).quantity.object_id
    # assert_equal SY::Time.magnitude( 1 ), SY::SECOND
    # assert_equal Matrix[[60.mM], [60.mM]], Matrix[[1e-03.s⁻¹.M], [1e-3.s⁻¹.M]] * 60.s
      
    # assert_equal Matrix[[5.m]], Matrix[[1.m.s⁻¹, 2.m.s⁻¹]] * Matrix.column_vector( [1.s, 2.s] )
    # assert_equal Matrix[[2.m, 3.m], [4.m, 5.m]],
    #              Matrix[[1.m, 2.m], [3.m, 4.m]] + Matrix[[1.m, 1.m], [1.m, 1.m]]
    # assert_equal Matrix[[5.µM]], Matrix[[1.µM]] + Matrix[[2.µM.s⁻¹]] * Matrix[[2.s]]
    # assert_equal Matrix[[1.s]], Matrix[[1]] * 1.s
    # assert_equal Matrix[[1.s]], 1.s * Matrix[[1]]
    # XOXO = SY::Unit.of SY::Volume, amount: 1.l
    # assert_equal 1.l.( SY::Volume ), 1.xoxo.( SY::Volume )
    # assert_equal SY::TRIPLE_POINT_OF_WATER, 0.°C.( SY::Temperature )
    # assert_equal 273.15, 0.°C.in( :K )
    # assert_equal SY::Unit.instance( :SECOND ), SY::Unit.instance( :second )
    # assert_equal SY::TRIPLE_POINT_OF_WATER, 0.°C # coercion behavior
    # assert 2.°C.eql?( 1.°C + 1.K )
    # assert ( 1.°C - 1.°C ).eql?( 0.K )

    # -> { 1.°C + 1.°C }.must_raise QuantityError
    # -> { 1.K + 1.°C }.must_raise QuantityError
    # -> { 1.K - 1.°C }.must_raise QuantityError
    
    # assert 1.mm.K⁻¹.eql?( 1.mm.°C⁻¹ )
    # assert 1.mm.K.eql?( 1.mm.°C )
    
    # -> { 1.mm / 1.°C }.must_raise QuantityError
    # -> { 1.mm * 1.°C }.must_raise QuantityError
  end
end
