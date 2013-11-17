require 'gir_ffi/user_defined_property_info'

module GirFFI
  # Represents a user defined type, conforming, as needed, to the interface of
  # GObjectIntrospection::IObjectInfo.
  class UserDefinedTypeInfo
    def initialize klass
      @klass = klass
      @properties = []
      yield self if block_given?
    end

    def described_class
      @klass
    end

    def install_property property
      @properties << UserDefinedPropertyInfo.new(property)
    end

    def properties
      @properties
    end

    attr_writer :g_name

    def g_name
      @g_name ||= @klass.name
    end
  end
end
