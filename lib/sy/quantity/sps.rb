# coding: utf-8

# Superscripted product string of a metrological quantity, such as
# "Length.Temperature⁻¹" or "Mass.Length⁻²".
# 
class SY::Quantity::Sps < SY::Sps
  @prefixes = []
  
  class << self
    def symbols
      SY::Quantity.instances.names
    end

    selector :prefixes

    def new( arg )
      super arg, symbols: symbols, prefixes: prefixes
    end

    private

    # No customization is needed for the instances of
    # SY::Quantity::Sps, no customized instances are needed.
    #
    def customize( *args ); end
  end

  delegate :symbols, :prefixes, to: "self.class"
end # class SY::Quantity::Sps
