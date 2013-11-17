require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::Builders::UserDefinedBuilder do
  describe "with type info containing one property" do
    before do
      @klass = Class.new GIMarshallingTests::OverridesObject
      Object.const_set "DerivedC#{Sequence.next}", @klass

      @info = GirFFI::UserDefinedTypeInfo.new @klass do |info|
        info.install_property GObject.param_spec_int("foo", "foo bar",
                                                     "The Foo Bar Property",
                                                     10, 20, 15,
                                                     3)
      end

      @builder = GirFFI::Builders::UserDefinedBuilder.new @info
      @builder.build_class
    end

    it "registers a type that is bigger than the parent" do
      gtype = @klass.get_gtype
      q = GObject.type_query gtype
      q.instance_size.must_be :>, GIMarshallingTests::OverridesObject::Struct.size
    end

    it "gives the types Struct the fields :parent and :foo" do
      @klass::Struct.members.must_equal [:parent, :foo]
    end

    it "creates accessor functions for the property" do
      obj = @klass.new
      obj.foo = 13
      obj.foo.must_equal 13
    end
  end

  describe "with type info containing an overridden g_name" do
    before do
      @klass = Class.new GIMarshallingTests::OverridesObject
      Object.const_set "DerivedD#{Sequence.next}", @klass

      @info = GirFFI::UserDefinedTypeInfo.new @klass do |info|
        info.g_name = "OtherName#{Sequence.next}"
      end

      @builder = GirFFI::Builders::UserDefinedBuilder.new @info
      @builder.build_class
    end

    it "registers a type under the overridden name" do
      registered_name = GObject.type_name(@klass.get_gtype)
      registered_name.must_equal @info.g_name
      registered_name.wont_equal @klass.name
    end
  end
end
