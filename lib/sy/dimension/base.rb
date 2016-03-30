#encoding: utf-8

class SY::Dimension
  # Basic physical dimensions.
  #
  # Current SY version intentionally omits amount of substance and luminous
  # intensity. Also, electric charge is taken for a basic dimension instead
  # of SI-prescribed electric current.
  # 
  BASE = {
    L: :LENGTH,
    M: :MASS,
    T: :TIME,
    Q: :ELECTRIC_CHARGE,        # instead of electric current
    Θ: :TEMPERATURE,
  }

  class << BASE
    # Returns all admissible symbols for base dimensions.
    # 
    def all_symbols
      keys + values
    end

    # Converts the supplied symbol to its long form.
    # 
    def normalize_symbol( ß )
      ß = ß.to_sym
      return ß if values.include? ß
      self[ß].tap { |v|
        fail TypeError,
             "Symbol '#{ß}' does not refer to a base dimension!" if v.nil?
      }
    end

    # Converts the supplied symbol to its short form.
    # 
    def short_symbol( ß )
      ß = ß.to_sym
      return ß if keys.include? ß
      rslt = rassoc( ß ) or
        fail TypeError, "Symbol '#{ß}' does not refer to a base dimension!"
      return rslt[0]
    end
  end # class << SY::Dimension::BASE
end # class SY::Dimension
