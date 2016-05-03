#encoding: utf-8

# A mixin providing the capability to respond to +SY+ unit methods.
# 
module SY::Units::ModuleMethods
  def included target
    target.extend case target
                  when Class then SY::Units::ClassMethods
                  else SY::Units::ModuleMethods end
  end
end # module SY::Units::ModuleMethods
