#encoding: utf-8

module SY
  # This mixin endows a class with the capacity to respond to method
  # symbols corresponding to metrological units defined in SY.
  # 
  module UnitMethodsMixin
    # # This method will cause a class to accept methods whose symbols
    # # correspond to the metrological units.
    # # 
    # def method_missing( method_ß, *args, &block )
    #   puts "mmiss #{method_ß}"
    #   # hack #1: prevent activation on #to_something
    #   super if method_ß.to_s.starts_with? 'to_'
    #   # hack #2: prevent recurrent invocation for the same symbol
    #   super if ç.instance_exec { @unit_mmiss ||= [] }.include? method_ß
    #   ç.instance_variable_get( :@unit_mmiss ) << method_ß
    #   # Check whether method_ß is registered in the table of units:
    #   units = Unit.instances
    #   unit_ςs = units.map { |u| [ u.name.to_s, u.short.to_s ] }.reduce :+
    #   prefixes = PREFIX_TABLE.full + PREFIX_TABLE.short
    #   prefix_hash = PREFIX_TABLE.hash_full.merge( PREFIX_TABLE.hash_short )
    #   begin
    #     prefixes, units, exponents =
    #       SPS_PARSER.( method_ß.to_s, unit_ςs, prefixes )
    #   rescue NameError # if method_ß is not recognized
    #     ç.instance_variable_get( :@unit_mmiss ).delete method_ß
    #     super
    #   end
    #   # Now method_ß definition for the receiver class
    #   def_skeleton = "def #{method_ß}\n" +  # def line
    #                  "  %s\n" +             # method body
    #                  "end"                  # end
    #   # Now let's look at the SPS_PARSER output from earlier:
    #   factors = [ prefixes, units, exponents ].transpose.map { |triple|
    #     prefix, unit, exponent = triple
    #     prefix = prefix_hash[ prefix ][ :full ] # convert into full form
    #     # reference the unit
    #     ς = "::SY::Unit::#{::SY::Unit.instance( unit ).name.to_s.upcase}" +
    #       prefix == '' ? '' : ".#{prefix}" # honoring the prefix
    #     # and exponentiate it if the exponent requires it
    #     ς += exponent == 1 ? '' : " ** #{exponent}"
    #   }
    #   # method body will contain their product:
    #   body = factors.reduce "self" do |acc, ς| "%s * \n" % ς + acc end
    #   # finally, define it:
    #   ç.module_eval definition_skeleton % body
    #   ç.instance_variable_get( :@unit_mmiss ).delete method_ß
    #   send method_ß, *args, &block
    # end # def method_missing

    # def respond_to_missing?( method_ß, include_private = false )
    #   # like in #method_missing, prevent handling #to_something
    #   super if method_ß.to_s.starts_with? 'to_'
    #   # like in #method_missing, watch out for recurrent symbols:
    #   ç.instance_variable_set( :@unit_rmiss, [] ) unless
    #     ç.instance_variable_get :@unit_rmiss
    #   super if ç.instance_variable_get( :@unit_rmiss ).include? method_ß
    #   ç.instance_variable_get( :@unit_rmiss ) << method_ß
    #   # now check for the symbol
    #   units = ::SY::Unit.instances
    #   unit_ςs = ( units.map( &:name ) + units.map( &:short ) ).map &:to_s
    #   prefixes = PREFIX_TABLE.full + PREFIX_TABLE.short
    #   begin
    #     prefixes, units, exponents =
    #       SPS_PARSER.( method_ß.to_s, unit_ςs, prefixes )
    #   rescue NameError # if method_ß not recognized
    #     ç.instance_variable_get( :@unit_rmiss ).delete method_ß
    #     super
    #   end
    #   ç.instance_variable_get( :@unit_rmiss ).delete method_ß
    #   # as long as SPS_PARSER succeeded, the outcome is true
    #   return true
    # end
  end # UnitMethodsMixin
end
