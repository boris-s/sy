#encoding: utf-8

module SY
  # This mixin endows a class with the capacity to respond to method
  # symbols corresponding to metrological units defined in SY.
  # 
  module UnitMethodsMixin
    # This method will cause a class to accept methods whose symbols
    # correspond to the metrological units.
    # 
    def method_missing( method_ß, *args, &block )
      # Check whether method_ß is registered in the table of units:
      begin
        units = ::SY::Unit.instances
        unit_names = units.map( &:name ).map( &:to_s )
        prefixes = ::SY::PREFIX_TABLE.full + ::SY::PREFIX_TABLE.short
        prefix_hash = ::SY::PREFIX_TABLE.hash_full
          .merge ::SY::PREFIX_TABLE.hash_short
        prefixes, units, exponents =
          ::SY::SPS_PARSER.( method_ß.to_s, unit_names, prefixes )
      rescue ArgumentError
        # SPS_PARSER fails with ArgumentError if method_ß is not recognized,
        super     # in which case, #method_missing will be forwarded higher
      end
      # method_ß is a method that takes a number (the receiver) and creates
      # a metrological Magnitude instance out of it. We are going to define
      # that method here. The definition skeleton will be:
      definition_skeleton = "def #{method_ß}\n" + # def line
                            "%s\n" +              # method body
                            "end"                 # end
      # Now let us take a look at the output of the SPS_PARSER, which we
      # called earlier, and convert it to the array of factors:
      factors = [ prefixes, units, exponents ].transpose.map { |triple|
        prefix, unit, exponent = triple
        # convert prefix into the full form
        prefix = prefix_hash[ prefix ][ :full ]
        # reference the unit (with or without prefix)
        ς = if prefix == "" then
              "::SY::Unit.instance( '#{unit}' )"
            else
              "::SY::Unit.instance( '#{unit}' ).#{prefix}"
            end
        # and exponentiate it if exponent requires it
        ς += if exponent == 1 then "" else " ** #{exponent}" end
      } # map
      # method body will contain the product of these factors:
      method_body = factors.reduce "self" do |accumulator, ς|
        "%s * \n" % ς + accumulator
      end
      # finally, teh finished method will be defined for that class,
      # on which it was called:
      self.class.module_eval definition_skeleton % method_body
      # and invoked:
      send method_ß, *args, &block
    end # def method_missing
    
    def respond_to_missing?( method_ß, include_private = false )
      # Check whether method_ß is registered in the table of units:
      begin
        prefixes, units, exponents =
          ::SY::SPS_PARSER.( method_ß.to_s,
                             ::SY::UNITS_WITHOUT_PREFIX.keys,
                             ::SY::PREFIXES.keys )
      rescue ArgumentError
        # SPS_PARSER fails with ArgumentError if method_ß is not registered,
        super # in which case, #respond_to_missing is sent up the lookup chain
      end
    end

    # Units with offset are not supported by SY. The only exception is made
    # for degrees of Celsius, for which #°C and #celsius method is provided,
    # constructing ABSOLUTE_TEMPERATURE n + 273.15. Use of degrees of Celsius
    # is generally discouraged for relative temperatures (ie. temperature
    # differences), use kelvins instead.
    # 
    def celsius
      Magnitude.of ABSOLUTE_TEMPERATURE, n: self + 273.15
    end
    alias :°C :celsius
  end # UnitMethodsMixin
end
