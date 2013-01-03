#encoding: utf-8

module SY
  # This mixin endows a class with the capacity to respond to method
  # symbols corresponding to metrological units defined in SY.
  # 
  module UnitMethodsMixin
    def method_missing ß, *args, &block
      # hack #0: for unknow reasons, 'begin' and 'end' are spooking around
      super if ß.to_s.starts_with? 'begin'
      super if ß.to_s.starts_with? 'end'
      # hack #1: prevent activation on #to_something
      super if ß.to_s.starts_with? 'to_'
      # hack #2: prevent recurrent invocation for the same symbol
      if ç.instance_exec { @unit_mmiss ||= [] }.include? ß
        ç.instance_variable_get( :@unit_mmiss ).delete ß
        super
      end
      ç.instance_variable_get( :@unit_mmiss ) << ß
      puts "Method missing: '#{ß}'"
      # Check whether ß is a unit
      known_units = ::SY::Unit.instances
      full_syms = known_units.map( &:name ).compact.map { |e| e.to_s.downcase }
      abbrevs = known_units.map( &:short ).compact.map &:to_s
      permitted_symbols = full_syms + abbrevs
      permitted_prefixes = ::SY::PREFIX_TABLE.full + ::SY::PREFIX_TABLE.short
      begin
        prefixes, units, exponents =
          ::SY::SPS_PARSER.( ß.to_s, permitted_symbols, permitted_prefixes )
      rescue NameError
        ç.instance_variable_get( :@unit_mmiss ).delete ß
        super
      end
      # passed, we have a valid unit method to define
      prefix_ꜧ = ::SY::PREFIX_TABLE.hash_full
        .merge( ::SY::PREFIX_TABLE.hash_short )
      # skeleton for the unit method definition
      skeleton = "def #{ß}\n" + # def line
                 "  %s\n" +     # method body
                 "end"          # end line
      # looking at the SPS_PARSER output from earlier...
      factors = [ prefixes, units, exponents ].transpose.map { |p, unit_ς, exp|
        prefix = prefix_ꜧ[ p ][ :full ].to_s # full prefix
        unit_name_in_upcase = known_units.find { |u|
          u.name.to_s == unit_ς || u.abbreviation.to_s == unit_ς
        }.name.to_s.upcase
        # build the unit reference and append exponentiation if called for
        "::SY::Unit::#{unit_name_in_upcase}" +
          if prefix == '' then '' else ".#{prefix}" end +
          if exp == 1 then '' else " ** #{exp}" end
      }
      # multiply the factors together (in a string)
      body = factors.reduce "self" do |acc, ς| "#{acc} * \n    #{ς}" end
      # define the unit method
      ç.module_eval( skeleton % body )
      # remove ß from anti-recursion registry
      ç.instance_variable_get( :@unit_mmiss ).delete ß
      # and invoke
      send ß, *args, &block
    end

    def respond_to_missing? ß, *args, &block
      # hack #0: for unknown reasons, 'begin' and 'end' are spooking around
      return false if ß.to_s == 'begin'
      return false if ß.to_s == 'end'
      # hack #1: prevent activation on #to_something
      super if ß.to_s.starts_with? 'to_'
      # hack #2: prevent recurrent invocation for the same symbol
      if ç.instance_exec { @unit_rmiss ||= [] }.include? ß
        ç.instance_variable_get( :@unit_rmiss ).delete ß
        super
      end
      ç.instance_variable_get( :@unit_rmiss ) << ß
      puts "Respond to missing: '#{ß}'"
      # check whether ß is a symbol
      known_units = ::SY::Unit.instances
      full_syms = known_units.map( &:name ).compact.map { |e| e.to_s.downcase }
      abbrevs = known_units.map( &:short ).compact.map &:to_s
      permitted_symbols = full_syms + abbrevs
      permitted_prefixes = ::SY::PREFIX_TABLE.full + ::SY::PREFIX_TABLE.short
      begin
        prefixes, units, exponents =
          ::SY::SPS_PARSER.( ß.to_s, permitted_symbols, permitted_prefixes )
      rescue NameError
        ç.instance_variable_get( :@unit_rmiss ).delete ß
        super
      end
      # as long as SPS_PARSER succeeded, the outcome is true
      ç.instance_variable_get( :@unit_rmiss ).delete ß
      return true
    end
  end
end
