# encoding: utf-8

# Represents a conversion table that converts quantity terms into
# quantities. This table is actually a multiplication table for
# term reduction into quantities.
# 
class SY::Quantity::Term::MultiplicationTable < Hash

  # Clears the table. This table, acting as cache, relies on the
  # fact that quantity compositions are defined in advance and stay
  # uchanged thereafter. When a new quantity composition is added,
  # the table needs to be cleared and this method serves just for
  # that purpose.
  # 
  def reset!
    # Clears the table.
  end
end
