#encoding: utf-8

# This mixin endows a class with the capacity to respond to method
# symbols corresponding to metrological units defined in SY.
# 
module SY::ExpressibleInUnits
  class IllegalRecursionError < StandardError; end

  def method_missing ß, *args, &block
    # hack #0: working around a bug in a 3rd party library
    return self if ß.to_s.include?( 'begin' ) || ß.to_s.include?( 'end' )
    # hack #1: get rid of missing methods 'to_something', esp. #to_ary
    super if ß == :to_ary || ß.to_s.starts_with?( 'to_' )
    begin # prevent recurrent method_missing for the same symbol
      anti_recursion_exec_with_token ß, :@SY_Units_mmiss do
        puts "Method missing: '#{ß}'" if SY::DEBUG
        # Parse the unit symbol.
        prefixes, units, exponents = parse_unit_symbol( ß )
        # Define the unit method.
        ç.module_eval write_unit_method( ß, prefixes, units, exponents )
      end
    rescue NameError => m
      puts "NameError raised: #{m}" if SY::DEBUG
      super # give up
    rescue SY::ExpressibleInUnits::IllegalRecursionError
      super # give up
    else # invoke the defined method that we just defined
      send ß, *args, &block
    end
  end

  def respond_to_missing? ß, *args, &block
    # hack #0: working around a bug in a 3rd party library
    super if ß.to_s == 'begin' || ß.to_s == 'end'
    # hack #1: prevent activation on #to_something
    super if ß == :to_ary || ß.to_s.starts_with?( 'to_' )
    begin # prevent recurrent method_missing for the same symbol
      anti_recursion_exec_with_token ß, :@SY_Units_rmiss do
        parse_unit_symbol( ß )
      end
    rescue NameError, SY::ExpressibleInUnits::IllegalRecursionError
      super # give up
    else
      return true
    end
  end

  private

  # Looking at the method symbol, delivered to #method_missing, this method
  # figures out which SY units it represents, along with prefixes and exponents. 
  # 
  def parse_unit_symbol ß
    # Known unit symbols include all the names and abbrevs of named units.
    ii = SY::Unit.instances
    known_unit_symbols = ii
      .map { |u| [ u.name, u.abbreviation ] }
      .select { |ɴ, _| ɴ } # excludes anonymous units
      .map { |ɴ, short| [ ɴ.to_s, short.to_s ] }
      .transpose
      .reduce( :+ )
    puts known_unit_symbols.join ', ' if SY::DEBUG
    # Known prefix symbols include full prefixes and prefix abbreviations.
    known_prefixes = SY::PREFIX_TABLE.full + SY::PREFIX_TABLE.short
    # Here, we rely on SY::SPS_PARSER:
    SY::SPS_PARSER.( ß.to_s, known_unit_symbols, known_prefixes )
  end

  # Taking method name symbol as the first argument, and three more arguments
  # representing equal-length arrays of prefixes, unit symbols and exponents,
  # appropriate method string is written.
  # 
  def write_unit_method ß, prefixes, units, exponents
    # Let's prepare SY information for further use:
    prefix_ꜧ = SY::PREFIX_TABLE.hash_full.merge( SY::PREFIX_TABLE.hash_short )
    known_units = SY::Unit.instances
    # A procedure to find unit based on name or abbreviation:
    find_unit = lambda do |ς|
      known_units.find { |u| u.name.to_s == ς || u.short.to_s == ς }
    end
    # Return prefix method or empty ς if not necessary.
    prefix_method_ς = lambda do |prefix|
      full_prefix = prefix_ꜧ[ prefix ][:full].to_s
      full_prefix == '' ? '' : ".#{full_prefix}"
    end
    # Return exponentiation string (suffix) or empty ς if not necessary.
    exponentiation_ς = lambda do |exponent|
      exponent == 1 ? '' : " ** #{exponent}"
    end
    # Prepare prefix / unit / exponent triples for making factor strings:
    triples = [ prefixes, units, exponents ].transpose
    # A procedure for triple processing before use:
    process_triple = lambda do |prefix, unit_ς, exponent|
      [ find_unit.( unit_ς ).name.to_s.upcase,
        prefix_method_ς.( prefix ),
        exponentiation_ς.( exponent ) ]
    end
    # Method skeleton:
    method_skeleton = "def #{ß}\n" +
                      "  %s\n" +
                      "end"
    factors = if triples.size < 1 then
                []
              else
                first_factor = "::SY.Unit( :%s )%s.to_magnitude( self )%s" %
                  process_triple.( *triples.shift )
                rest = triples.map do |tr|
                  "::SY.Unit( :%s )%s.to_magnitude%s" % process_triple.( *tr )
                end
                [ first_factor, *rest ]
              end
    # Multiply the factors toghether:
    method_body = factors.join( " * \n    " )
    # Return the finished method string:
    return ( method_skeleton % method_body ).tap { |ς| puts ς if SY::DEBUG }
  end

  # Takes a token as the first argument, a symbol of the instance variable to
  # be used for storage of active tokens, grabs the token, executes the
  # supplied block, and releases the token. The method guards against double
  # execution for the same token, raising IllegalRecursionError in such case.
  # 
  def anti_recursion_exec_with_token token, inst_var
    registry = self.class.instance_variable_get( inst_var ) ||
      self.class.instance_variable_set( inst_var, [] )
    if registry.include? token then
      raise SY::ExpressibleInUnits::IllegalRecursionError
    end
    begin
      registry << token
      yield if block_given?
    ensure
      registry.delete token
    end
  end
end # module SY::UnitMethodsMixin
