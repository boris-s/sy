#encoding: utf-8

# A mixin providing the capability to respond to +SY+ unit methods.
# 
module ExpressibleInUnits
  COLLISION_WARNING =
    "Unit %s collision, method already defined on %s!"
  REDEFINE_WARNING =
    "Method %s just defined on %s shadows SY unit method!"

  # Custom error class should unwanted recursion happen. This is a
  # real danger due to broadly responsive #method_missing carried
  # by this module.
  # 
  RecursionError = Class.new StandardError

  # This module is to be included in the class methods. It's
  # purpose is to warn when the user shadows a SY unit method.
  # 
  module DetectRedefine
    def method_added ß
      # warn "#{self}: method added: :#{ß}"
      uu = ExpressibleInUnits.known_units
      nn = uu.map &:name
      aa = uu.map &:abbreviation
      ꜧ = Hash[ nn.zip( uu ) ].merge Hash[ aa.zip( uu ) ]
      w = ::SY::ExpressibleInUnits::REDEFINE_WARNING % [ ß, self ]
      if nn.include? ß then
        if instance_methods.include? ß then
          im = instance_method ß
          warn w unless
            ::SY::ExpressibleInUnits.method_family.include? im if
            ꜧ[ß].warns? unless
            instance_variable_get( :@no_collision ) == ß
          # FIXME: This is too clumsy
          instance_variable_set( :@no_collision, nil )
        else
          warn w if ꜧ[ß].warns?
        end
      end
      if aa.include? ß then
        if instance_methods.include? ß then
          im = instance_method ß
          warn w unless
            ::SY::ExpressibleInUnits.method_family.include? im if
            ꜧ[ß].warns? unless
            instance_variable_get( :@no_collision ) == ß
          # FIXME: This is too clumsy
          instance_variable_set( :@no_collision, nil )
        else
          warn w if ꜧ[ß].warns?
        end
      end
    end
  end

  class << self
    # Perfoms a casual check for blatant name collisions between
    # SY::Unit-implied methods.
    # 
    def included receiver
      # Keep track of where the mixin has been included
      included_in << receiver
      # Warn if the receiver has potentially colliding methods.
      inst_methods = receiver.instance_methods
      w = COLLISION_WARNING % ["%s", receiver]
      known_units.each do |unit|
        next unless unit.warns?
        name, short = unit.name, unit.abbreviation
        warn w % "name method ##{name}" if
          inst_methods.include? name
        warn w % "abbreviation method ##{short}" if
          inst_methods.include? short
      end
      # Look out for user shadowing SY methods.
      if receiver.is_a? Class
        receiver.extend ExpressibleInUnits::DetectRedefine
      end
    end

    # Modules in which this mixin has been included.
    # 
    def included_in
      @included_in ||= []
    end

    # Unit namespace.
    # 
    def unit_namespace
      begin
        SY::Unit
      rescue NameError # no SY::Unit defined yet
      end
    end

    # Currently defined unit instances, if any.
    # 
    def known_units
      begin
        unit_namespace.instances
      rescue NoMethodError 
        [] # no #instances method defined yet
      end.tap { |r| puts "Known units are #{r}" if SY::DEBUG }
    end

    # All methods defined by this mixin.
    # 
    def method_family
      @method_family ||= []
    end

    # Find unit based on name / abbreviation.
    # 
    def find_unit ς
      puts "searching for unit #{ς}" if SY::DEBUG
      known_units.find do |u|
        u.name.to_s.downcase == ς.downcase &&
          ( ς == ς.downcase || ς == ς.upcase ) ||
          u.short.to_s == ς
      end
    end
  end

  # Covers unit methods.
  # 
  def method_missing ß, *args, &block
    return self if ß.to_s =~ /begin|end/ # 3rd party bug workaround
    super if ß.to_s =~ /to_.+/ # dismiss #to_something methods
    begin # prevent recursive activation of #method_missing
      anti_recursion_exec token: ß, var: :@SY_Units_mmiss do
        puts "Method missing: '#{ß}'" if SY::DEBUG
        prefixes, units, exps = parse_unit_symbol
        
        # TODO: This is a rebuild of SY. I learned new things since
        # the old SY, and it deserves a rebuild. Previous version
        # is hidden in the "old" directories.

      end
    rescue NameError => err
      puts "NameError raised: #{err}" if SY::DEBUG
      super # give up
    rescue RecursionError
      super # just give up
    else
      # if there was no error, invoke the defined method
      send ß, *args, &block
    end
  end

  # Covers unit methods.
  # 
  def respond_to_missing? ß, *args, &block
    # dismiss :to_... methods and /begin|end/
    # (3rd party bug workaround)
    return false if ß.to_s =~ /to_.+|begin|end/
    !! begin
         anti_recursion_exec token: ß, var: :@SY_Units_rmiss do
           parse_unit_symbol ß
         end
       rescue NameError, SY::ExpressibleInUnits::RecursionError
         false
       else
         true
       end
  end

  private

  # TODO: Since ExpressibleInUnits is a mixin, it would be purer
  # not to keep these private methods here. They might be better
  # placed in the singleton class of this module, or of SY module,
  # or something like that. I won't do it just yet because I'm
  # already used to this program structure.

  # Takes a method symbol as an argument and figures out which SY
  # unit, if any, it represents, along with unit prefixes and
  # exponents.
  # 
  def parse_unit_symbol ß
    puts "About to parse #{ß} using all prefixes" if SY::DEBUG
    SY::Unit.parse_sps_using_all_prefixes( ß ) # rely on SY::Unit
  end

  # This method does metaprogramming. On demand, it writes a unit
  # method, and returns the method code in the text form. Takes 2
  # ordered arguments: The first of them is the name of the method
  # to be written, the second one is the array of instructions how
  # to write the method. The second argument is an array of triples
  # (size 3 arrays) of the form [prefix, unit, exponent]. The
  # resulting method code is returned as a string.
  # 
  def write_unit_method method_name, writing_instructions
    # TODO: This method is long.
    puts "writing unit method #{method_name}" if SY::DEBUG
    # Each instruction is a triple [prefix, unit_string, exponent]
    process_instruction = -> pfx, unit_ς, exp do
      puts "Processing triple #{pfx}, #{unit_ς}, #{exp}." if
        SY::DEBUG
      [ ExpressibleInUnits.find_unit( unit_ς ).name.to_s.upcase, 
        ExpressibleInUnits.prefix_method_string( pfx ),
        ExpressibleInUnits.exponentiation_string( exp ) ]
    end
    # Write the method template and the method body.
    if instructions.size == 1 && instructions.first[-1] == 1 then
      single_instruction = instructions[0]
      method_template = "def #{ß}( exp=1 )\n" +
                        "  %s\n" +
                        "end"
      uς, pfxς, expς = process_instruction.( *single_instruction )
      method_body = ( "if exp == 1 then\n" +
                      "  +( ::SY.Unit( :%s )%s ) * self\n" +
                      "else\n" +
                      "  +( ::SY.Unit( :%s )%s ) ** exp * self\n" +
                      "end" ) % [uς, pfxς, uς, pfxς]
    else
      first_instruction = instructions.shift
      method_template = "def #{ß}\n" +
                        "  %s\n" +
                        "end"
      first_factor =  "+( ::SY.Unit( :%s )%s )%s * self" %
        process_instruction.( *first_instruction )
      factors = [ first_factor ] + instructions.map do |i|
        "( ::SY.Unit( :%s )%s.relative ) )%s" % process_instruction.( *i )
      end
      # Multiply the factors toghether:
      method_body = factors.join( " * \n    " )
    end
    # Return the finished method code as a string:
    method_code = method_template % method_body
    puts method_code if SY::DEBUG
    return method_code
  end

  # Takes 2 arguments: A token, and a name of the instance variable
  # in which to store the active tokens. It then grabs the token,
  # executes the supplied block and releases the token. The method
  # guarantees that the block won't be executed recursively with
  # the same token, or RecursionError is raised.
  # 
  def anti_recursion_exec( token: nil, var: :@anti_recursion_exec )
    token_registry = self.class.instance_variable_get( var ) ||
      self.class.instance_variable_set( var, [] )
     fail RecursionError if token_registry.include? token
    begin
      token_registry << token   # grab the token
      yield                     # execute the block
    ensure
      token_registry.delete( token )  # release the token
    end
  end

  # TODO: There should be an option to define by default, from the
  # get go, some unit methods for some classes, get in front of
  # possible collisions. Example of such collision is eg. #second
  # with active_support/duration.rb
end # module ExpressibleInUnits
