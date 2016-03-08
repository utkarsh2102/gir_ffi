# frozen_string_literal: true
module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout and :out.
  #
  class InOutPointer < FFI::Pointer
    attr_reader :value_type

    def initialize(type, ptr)
      @value_type = type
      super ptr
    end

    def to_value
      case value_ffi_type
      when Module
        value_ffi_type.get_value_from_pointer(self, 0)
      when Symbol
        send("get_#{value_ffi_type}", 0)
      else
        raise NotImplementedError
      end
    end

    # Convert more fully to a ruby value than #to_value
    def to_ruby_value
      bare_value = to_value
      case value_type
      when :utf8
        bare_value.to_utf8
      when Array
        value_type[1].wrap bare_value
      when Class
        value_type.wrap bare_value
      else
        bare_value
      end
    end

    def clear
      put_bytes 0, "\x00" * value_type_size, 0, value_type_size
    end

    def self.allocate_new(type)
      ffi_type = TypeMap.type_specification_to_ffi_type type
      ptr = AllocationHelper.allocate_for_type(ffi_type)
      new type, ptr
    end

    private

    def value_ffi_type
      @value_ffi_type ||= TypeMap.type_specification_to_ffi_type value_type
    end

    def value_type_size
      @value_type_size ||= FFI.type_size value_ffi_type
    end
  end
end
