#encoding: utf-8

# Superscripted product string, such as "kg.m.s⁻²", or "L.θ⁻¹".
# 
# def SPS.inspect
#   "Superscripted product string constructor lambda." +
#     "Takes 2 arguments. Example: [:a, :b], [-1, 2] #=> a⁻¹b²."
# end
# 
class SY::Sps < String
  class << self
    # The argument can be constructed either from an array of triples
    # representing the Sps segments, or an array of pairs representing the
    # same, or, alternatively, a valid string form can be given.
    # 
    def new arg
      fail ArgumentError if arg.nil?
      super case arg
            when Array then
              arg.map { |*head, exp| [ head.join, SY.Se( exp ) ] }
                .reject { |_, exp| exp.zero? }
                .join '.'
            else
              validate String( arg )
            end
    end

    # Validates the supplied string, returning the argument back unchanged
    # if valid, and raising ArgumentError if the argument is not a valid
    # Sps.
    # 
    def validate string
      # FIXME: This method currently always hands back the string
      # with no checks performed.
      # 
      # But it should raise ArgumentError for wrong strings.
      # Think how to validate the Sps. Each Sps subtype
      # is meant to be used with certain set of symbols and
      # prefixes. This would almost call for SY::SymbolSet and
      # SY::PrefixSet classes.
      string
    end
  end

  # Parses the receiver, given 2 parameters: an array of acceptable symbols, and
  # an array of acceptable prefixes. It returns an array of factors represented
  # as triples: prefix, symbol, exponent.
  #
  def parse( acceptable_symbols, acceptable_prefixes )
    # Normalize the parameters.
    symbols = acceptable_symbols.map &:to_s
    prefixes = ( acceptable_prefixes.map( &:to_s ) << '' ).uniq
    # Split the string (ie. self).
    sections = self.split '.'
    if sections.empty?
      fail TypeError, "Bad input string: '#{self}'!" unless empty?
      return []
    end
    # Parse the string sections.
    sections.each_with_object [] do |section, a|
      # TODO: This method is too long.
      s = section.dup
      superscript_chars = SY::SUPERSCRIPT.values
      # Chop off the superscript tail of the section.
      s.chop! while superscript_chars.any? { |c| s.end_with? c }
      # Construct the set of possible unit symbols.
      possible_ßs = symbols.select { |ß| section.end_with? ß }
      # Find candidate prefixes corresponding to possible symbols.
      possible_prefixes = possible_ßs.map { |ß| s[ 0..((-1) - ß.size) ] }
      # See which possible prefixes can be confirmed.
      confirmed_prefixes = possible_prefixes.select { |x| prefixes.include? x }
      # Complain if no symbol matches the section.
      fail TypeError, "Unknown symbol: '#{s}'!" if confirmed_prefixes.empty?
      # Note if ambiguity is present in prefix/symbol pair.
      if confirmed_prefixes.size > 1 then
        if confirmed_prefixes.any? { |x| x == '' } then # prefer empty prefixes
          chosen_prefix = ''
        else
          fail TypeError, "Ambiguity in interpretation of '#{s}'!"
        end
      else
        chosen_prefix = confirmed_prefixes[0]
      end
      prefix_size = chosen_prefix.size
      # Based on the chosen prefix, find the chosen root.
      chosen_root = s[ (chosen_prefix.size)..(-1) ]
      root_size = chosen_root.size
      # Single out the exponent suffix.
      begin
        exp_string =
          SY::Ses.new( section[ ((-1) - prefix_size - root_size)..(-1) ] )
      rescue ArgumentError, TypeError
        fail TypeError, "Malformed exponent in #{section}!"
      end
      exp = Integer( exp_string.to_normal_numeral )
      fail TypeError, "Zero exponents not allowed: #{section}" if exp.zero?
      # And store the parsed triple into the aray.
      a << [ chosen_prefix, chosen_root, exp ]
    end
  end
end # class SY::Sps
