#encoding: utf-8

require 'y_support/core_ext/class'
require 'active_support/core_ext/module/delegation'

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

    # No customization is needed for the instances of SY::Dimension::Sps, since
    # the class itself is already properly customized subclass of SY::Sps.
    #
    def customize( *args ); end

    # Normalizes a symbol.
    #
    def normalize_symbol( sym )
      SY::Dimension::BASE.normalize_symbol( sym )
    end
  end

  delegate :symbols, :prefixes, to: "self.class"
end # class SY::Sps
