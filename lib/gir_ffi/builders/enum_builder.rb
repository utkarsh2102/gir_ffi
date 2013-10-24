require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/with_methods'
require 'gir_ffi/enum_base'

module GirFFI
  module Builders
    # Implements the creation of an enum or flags type. The type will be
    # attached to the appropriate namespace module, and will be defined
    # as an enum for FFI.
    class EnumBuilder < RegisteredTypeBuilder
      include WithMethods

      private

      def enum_sym
        @classname.to_sym
      end

      def value_spec
        return info.values.map {|vinfo|
          val = GirFFI::ArgHelper.cast_uint32_to_int32(vinfo.value)
          [vinfo.name.to_sym, val]
        }.flatten
      end

      def instantiate_class
        @enum = optionally_define_constant klass, :Enum do
          lib.enum(enum_sym, value_spec)
        end
        setup_class unless already_set_up
      end

      def setup_class
        klass.extend superclass
        setup_constants
        setup_gtype_getter
        stub_methods
        setup_inspect
      end

      def klass
        @klass ||= get_or_define_module namespace_module, @classname
      end

      def setup_inspect
        klass.instance_eval <<-EOS
          def self.inspect
            "#{@namespace}::#{@classname}"
          end
        EOS
      end

      def already_set_up
        klass.respond_to? :get_gtype
      end

      def superclass
        @superclass ||= EnumBase
      end
    end
  end
end
