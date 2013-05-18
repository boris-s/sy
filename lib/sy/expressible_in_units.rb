# -*- coding: utf-8 -*-
# This mixin provides ability to respond to SY unit symbol methods.
# 
module SY::ExpressibleInUnits
  RecursionError = Class.new StandardError

  def method_missing ß, *args, &block
    return self if ß.to_s =~ /begin|end/ # 3rd party bug workaround
    super if ß.to_s =~ /to_.+/ # dissmiss :to_..., esp. :to_ary
    begin # prevent recurrent call of method_missing for the same symbol
      anti_recursion_exec token: ß, var: :@SY_Units_mmiss do
        puts "Method missing: '#{ß}'" if SY::DEBUG
        prefixes, units, exps = parse_unit_symbol ß
        # Define the unit method on self.class:
        ç.module_eval write_unit_method( ß, prefixes, units, exps )
      end
    rescue NameError => err
      puts "NameError raised: #{err}" if SY::DEBUG
      super # give up
    rescue SY::ExpressibleInUnits::RecursionError
      super # give up
    else # actually invoke the method that we just defined
      send ß, *args, &block
    end
  end

  def respond_to_missing? ß, *args, &block
    # dismiss :to_... methods and /begin|end/ (3rd party bug workaround)
    return false if ß.to_s =~ /to_.+|begin|end/
    begin
      anti_recursion_exec token: ß, var: :@SY_Units_rmiss do parse_unit ß end
    rescue NameError, SY::ExpressibleInUnits::RecursionError
      false
    else
      true
    end
  end

  private

  # Looking at the method symbol, delivered to #method_missing, this method
  # figures out which SY units it represents, along with prefixes and exponents. 
  # 
  def parse_unit_symbol ß
    SY::Unit.parse_sps_using_all_prefixes( ß ) # rely on SY::Unit
  end

  # Takes method symbol, and three more array arguments, representing prefixes,
  # unit symbols and exponents. Generates an appropriate unit method as a string.
  # Arrays must be of equal length. (Note: 'ß' is 'symbol', 'ς' is 'string')
  # 
  def write_unit_method ß, prefixes, units, exponents
    known_units = SY::Unit.instances
    # A procedure to find unit based on name or abbreviation:
    find_unit = lambda do |ς|
      known_units.find { |u| u.name.to_s == ς || u.short.to_s == ς }
    end
    # Return prefix method or empty ς if not necessary.
    prefix_method_ς = lambda do |prefix|
      puts "About to call PREFIX TABLE.to_full with #{prefix}" if SY::DEBUG
      full_prefix = SY::PREFIX_TABLE.to_full( prefix )
      full_prefix == '' ? '' : ".#{full_prefix}"
    end
    # Return exponentiation string (suffix) or empty ς if not necessary.
    exponentiation_ς = lambda do |exp| exp == 1 ? '' : " ** #{exp}" end
    # Prepare prefix / unit / exponent triples for making factor strings:
    triples = [ prefixes, units, exponents ].transpose
    # A procedure for triple processing before use:
    process_triple = lambda do |pfx, unit_ς, exp|
      [ find_unit.( unit_ς ).name.to_s.upcase, 
        prefix_method_ς.( pfx ),
        exponentiation_ς.( exp ) ]
    end
    # Method skeleton:
    if triples.size == 1 && triples.first[-1] == 1 then
      method_skeleton = "def #{ß}( exp=1 )\n" +
                        "  %s\n" +
                        "end"
      method_body = "if exp == 1 then\n" +
                    "  +( ::SY.Unit( :%s )%s ) * self\n" +
                    "else\n" +
                    "  +( ::SY.Unit( :%s )%s ) ** exp * self\n" +
                    "end"
      uς, pfxς, expς = process_triple.( *triples.shift )
      method_body %= [uς, pfxς] * 2
    else
      method_skeleton = "def #{ß}\n" +
                        "  %s\n" +
                        "end"
      factors = [ "+( ::SY.Unit( :%s )%s )%s * self" %
                  process_triple.( *triples.shift ) ] +
        triples.map do |triple|
          "( ::SY.Unit( :%s )%s.relative ) )%s" % process_triple.( *triple )
        end
      # Multiply the factors toghether:
      method_body = factors.join( " * \n    " )
    end
    # Return the finished method string:
    return ( method_skeleton % method_body ).tap { |ς| puts ς if SY::DEBUG }
  end

  # Takes a token as the first argument, a symbol of the instance variable to
  # be used for storage of active tokens, grabs the token, executes the
  # supplied block, and releases the token. The method guards against double
  # execution for the same token, raising IllegalRecursionError in such case.
  # 
  def anti_recursion_exec( token: nil, var: :@SY_anti_recursion_exec )
    registry = self.class.instance_variable_get( var ) ||
      self.class.instance_variable_set( var, [] )
    raise RecursionError if registry.include? token
    begin
      registry << token
      yield if block_given?
    ensure
      registry.delete token
    end
  end

  # FIXME: There should be an option to define by default, already at the
  # beginning, certain methods for certain classes, to get in front of possible
  # collisions. Collision was detected for example for #second with
  # active_support/duration.rb
end # module SY::UnitMethodsMixin
