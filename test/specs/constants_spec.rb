require 'minitest/autorun'

class BogoConstTop
  include Bogo::Constants
  FUBAR = 'ohai'

  def direct_const
    FUBAR
  end
end

class BogoConstSub < BogoConstTop
  FUBAR = 'bai'
end

module BogoNamespace
  module Fubar
    class Foobar
    end
  end
end

describe Bogo::Constants do

  describe 'Fetching constant value' do

    it 'should provide top level constant from top level object' do
      instance = BogoConstTop.new
      instance.direct_const.must_equal 'ohai'
      instance.const_val(:FUBAR).must_equal 'ohai'
    end

    it 'should provide top level constant from sub object when direct' do
      instance = BogoConstSub.new
      instance.direct_const.must_equal 'ohai'
    end

    it 'should provide local constant from sub object when using #const_val' do
      instance = BogoConstSub.new
      instance.const_val(:FUBAR).must_equal 'bai'
    end

  end

  describe 'Extracting constant from string' do

    before do
      @const = Object.new
      @const.extend Bogo::Constants
    end

    it 'should return expected class' do
      @const.constantize('Bogo::AnimalStrings').must_equal Bogo::AnimalStrings
    end

    it 'should return expected value' do
      @const.constantize('BogoConstTop::FUBAR').must_equal 'ohai'
    end

    it 'should return nil when constant not found' do
      @const.constantize('Bogo::Fubar').must_be_nil
    end

  end

  describe 'Providing namespace for class' do

    before do
      @const = Object.new
      @const.extend Bogo::Constants
    end

    it 'should return ObjectSpace when class is top level' do
      @const.namespace(String).must_equal ObjectSpace
    end

    it 'should return parent namespace' do
      @const.namespace(BogoNamespace::Fubar::Foobar.new).must_equal BogoNamespace::Fubar
    end

  end
end
