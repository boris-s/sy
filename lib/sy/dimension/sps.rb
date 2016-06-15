# coding: utf-8

# Superscripted product string of a metrological dimension, such as
# "L.θ⁻¹" or "MASS.LENGTH⁻²".
# 
class SY::Dimension::Sps < SY::Sps
  @symbols = SY::Dimension::BASE.all_symbols.map &:to_s
  @prefixes = []
  
  class << self
    selector :symbols, :prefixes

    def new( arg )
      super arg, symbols: symbols, prefixes: prefixes
    end

    private

    # No customization is needed for the instances of
    # SY::Dimension::Sps, no customized instances are needed.
    #
    def customize( *args ); end

    # Normalizes a symbol.
    #
    def normalize_symbol( sym )
      SY::Dimension::BASE.normalize_symbol( sym )
    end
  end

  delegate :symbols, :prefixes, to: "self.class"
end # class SY::Dimension::Sps
