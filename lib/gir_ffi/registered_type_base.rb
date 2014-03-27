require 'gir_ffi/type_base'

module GirFFI
  # Base module for generated registered GLib types (these are types that have a
  # GType).
  module RegisteredTypeBase
    include TypeBase

    def get_gtype
      self::G_TYPE
    end
  end
end
