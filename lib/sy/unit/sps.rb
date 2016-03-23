#encoding: utf-8

# Superscripted product string of metrological units, such as
# "kg.m.s⁻²" or "GJ.m³".
# 
class SY::Unit::Sps < SY::Sps
  # FIXME: This subclass is distinct mainly by having
  # a the existing units as root symbols (SY::Dimension::BASE) and
  # SY::PREFIXES as prefixes.
end # class SY::Sps
