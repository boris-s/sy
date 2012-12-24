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
      # hack to prevent method missing activation on #to_something
      super if method_ß.to_s[0..2] == 'to_'
      # This method should not be recursively invoked for the same class.
      # While such state indicates error on the user's side, let's be
      # smart enough to notice repeated nested processing of the same
      # symbol here.
      ç.instance_variable_set( :@active_unit_mmiss, [] ) unless
        ç.instance_variable_get :@active_unit_mmiss
      # if the symbol appears twice, clearly something unexpected is going on
      # we could raise an error, but avoiding responsibility is what we do:
      if ç.instance_variable_get( :@active_unit_mmiss ).include? method_ß
        super                        # not our responsibility
      end
      # now let us note the symbol we are analyzing now
      ç.instance_variable_get( :@active_unit_mmiss ) << method_ß
      # Check whether method_ß is registered in the table of units:
      units = ::SY::Unit.instances
      unit_symbols = ( units.map( &:name ) + units.map( &:short ) )
        .map( &:to_s )
      prefixes = ::SY::PREFIX_TABLE.full + ::SY::PREFIX_TABLE.short
      prefix_hash = ::SY::PREFIX_TABLE.hash_full
        .merge ::SY::PREFIX_TABLE.hash_short
      begin
        prefixes, units, exponents =
          ::SY::SPS_PARSER.( method_ß.to_s, unit_symbols, prefixes )
      rescue NameError
        # SPS_PARSER fails with ArgumentError if method_ß is not recognized,
        # in which case, #method_missing will be forwarded higher, but before
        # that, let us clear it from the registry of active symbols:
        ç.instance_variable_get( :@active_unit_mmiss )
          .delete method_ß
        super
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
        ς = "::SY::Unit::#{::SY::Unit.instance( unit ).name.to_s.upcase}%s" %
          if prefix == '' then '' else
            ".#{prefix_hash[ prefix ][:full]}"
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
      ç.module_eval definition_skeleton % method_body
      # before invoking it, let us remove it from the registry of active
      # method_missing symbols under consideration
      ç.instance_variable_get( :@active_unit_mmiss ).delete method_ß
      # finally, invoke it
      send method_ß, *args, &block
    end # def method_missing

    def respond_to_missing?( method_ß, include_private = false )
      # due to similar consideration as in #method_missing, we watch out for
      # nested double probing for the same symbol
      ç.instance_variable_set( :@active_unit_rmiss, [] ) unless
        ç.instance_variable_get :@active_unit_rmiss
      if ç.instance_variable_get( :@active_unit_rmiss ).include? method_ß
        super                        # not our responsibility
      end
      # now let us note the symbol we are analyzing now
      ç.instance_variable_get( :@active_unit_rmiss ) << method_ß
      # now check for the method
        units = ::SY::Unit.instances
        unit_symbols = ( units.map( &:name ) + units.map( &:short ) )
          .map( &:to_s )
        prefixes = ::SY::PREFIX_TABLE.full + ::SY::PREFIX_TABLE.short
      begin
        prefixes, units, exponents =
          ::SY::SPS_PARSER.( method_ß.to_s, unit_symbols, prefixes )
      rescue NameError
        # SPS_PARSER fails with NameError if method_ß is not registered,
        ç.instance_variable_get( :@active_unit_rmiss ).delete method_ß
        super # in which case, #respond_to_missing is sent up the lookup chain
      end
      ç.instance_variable_get( :@active_unit_rmiss ).delete method_ß
    end

    # Units with offset are not supported by SY. The only exception is made
    # for degrees of Celsius, for which #°C and #celsius method is provided,
    # constructing ABSOLUTE_TEMPERATURE n + 273.15. Use of degrees of Celsius
    # is generally discouraged for relative temperatures (ie. temperature
    # differences), use kelvins instead.
    # 
    def celsius
      ::SY::Magnitude.of ::SY::Quantity.instance( :Temperature ),
                         amount: self + 273.15
    end
    alias :°C :celsius
  end # UnitMethodsMixin
end
