#encoding: utf-8

# Wildcard zero, stronger than ordinary numeric literal 0.
# 
( WILDCARD_ZERO = NullObject.new ).instance_exec {
  ɪ = self
  singleton_class.class_exec { define_method :zero do ɪ end }
  def * other; other.class.zero end
  def / other
    self unless other.zero?
    fail ZeroDivisionError, "The divisor is zero! (#{other})"
  end
  def + other; other end
  def - other; -other end
  def coerce other; return other, other.class.zero end
  def zero?; true end
  def to_s; "∅" end
  def inspect; to_s end
  def to_f; 0.0 end
  def to_i; 0 end
  def == other
    z = begin
          other.class.zero
        rescue NoMethodError
          return false
        end
    other == z
  end
}
