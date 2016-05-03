# encoding: utf-8

# Represents multiplication table of quantity compositions. It is
# a hash whose keys are distinguished composed quantities, and
# values are terms that define these composed quantities.
#
class SY::Quantity::Composition::Table < Hash
  # FIXME: Write the tests!

  # FIXME: Updating the table should result in clearing the
  # Quantity::Term simplification cache as well as quantity
  # multiplication table (which is just the second cache of
  # the same process).

  # FIXME: Merely constructing an anonymous quantity by quantity
  # multiplication or division should not create an entry in the
  # composition table. The quantity thus constructed should keep
  # its composition by itself and honor it in quantity arithmetics
  # (I don't know how, though, this looks quite tough), but it
  # should only enter it in the quantity table when it is named.

  # FIXME: Make sure that renaming quantities (and when we are at
  # it, also other artefacts of SY) should be prohibited.

  # FIXME: Make absolutely certain that un-naming an instance of
  # a NameMagic user class is always treated as renaming, unless
  # the class is being deleted from the registry.
end
