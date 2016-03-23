#encoding: utf-8

# This class represents superscripted exponent, such as "¹⁵", "⁻²", or even
# empty string "", meaning exponent 1.
# 
class SY::Se < String
  # Convenience constructor.
  # 
  def SY.Se arg
    SY::Se.new arg
  end
  
  TABLE = {
    '-' => '⁻',
    '/' => '⎖',                 # for fractions, not in use atm.
    '0' => '⁰',
    '1' => '¹',
    '2' => '²',
    '3' => '³',
    '4' => '⁴',
    '5' => '⁵',
    '6' => '⁶',
    '7' => '⁷',
    '8' => '⁸',
    '9' => '⁹',
  }

  class << self
    def new arg
      # Validate the presence of the argument.
      arg.aA_present
      # Convert the argument into a normal string first.
      s = String arg
      # The argument must represent an integer.
      i = begin
            Integer s
          rescue TypeError, ArgumentError
            if s == "" then
              # Empty strings represent exponent 1.
              1
            else
              # Non-empty strings have still chance to be a superscript integer.
              Integer s.each_char.map { |c|
                r = TABLE.rassoc( c ) or
                  fail ArgumentError, "#{arg} is not a valid exponent!"
                r[0]
              }.reduce( :+ )
            end
          end
      # Convert the integer into the superscript form.
      super i.each_char.map { |c| TABLE[c] }.reduce :+
    end
  end
  
  # Converts the exponent string written in superscript characters to a
  # string written in normal ASCII numerals.
  #
  def to_normal_numeral
    return "1" if empty?
    each_char.map { |c| TABLE.rassoc( c )[0] }.reduce :+
  end
end # class SY::Ses
