#encoding: utf-8

# Superscripted product string of a metrological dimension, such as
# "L.θ⁻¹" or "MASS.LENGTH⁻²".
# 
class SY::Dimension::Sps < SY::Sps
  # FIXME: This subclass is distinct mainly by having
  # a specific set of root symbols (SY::Dimension::BASE),
  # and allowing no prefixes.
end # class SY::Sps
