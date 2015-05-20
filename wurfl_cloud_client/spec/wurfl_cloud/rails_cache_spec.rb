#
# Copyright (c) 2015 ScientiaMobile Inc.
#
# The WURFL Cloud Client is intended to be used in both open-source and
# commercial environments. To allow its use in as many situations as possible,
# the WURFL Cloud Client is dual-licensed. You may choose to use the WURFL
# Cloud Client under either the GNU GENERAL PUBLIC LICENSE, Version 2.0, or
# the MIT License.
#
# Refer to the COPYING.txt file distributed with this package.
#
require 'spec_helper'
require 'digest/md5'
require 'wurfl_cloud/cache/rails'

# fake rails cache
module Rails
  class Cache
    def initialize
      @store = Hash.new
    end
    def write(key, value)
      @store[key] = value
    end
    def read(key)
      @store[key]
    end
  end
  
  class << self
    def cache 
      @cache ||= Rails::Cache.new
    end
  end
end

describe WurflCloud::Cache::Rails do
  subject { WurflCloud::Cache::Rails.new({}, {}) }
  
  context "the object" do    
    it { should respond_to(:[]).with(1).argument }
    it { should respond_to(:[]=).with(2).arguments }
    it { should respond_to(:mtime).with(0).arguments }
    it { should respond_to(:mtime=).with(1).argument }
    it { should respond_to(:prefix).with(0).arguments }
    it { should respond_to(:key_prefix).with(0).arguments }
    
    it "should not throw errors calling []=" do
      expect { subject[String.random] = String.random }.to_not raise_error
    end

    it "should store values" do
      key = String.random
      subject[key] = String.random
      subject[key].should_not be_nil
    end
    
    it "should have an empty prefix" do
      subject.prefix.should ==""
    end
    
    it "should have the key_prefix contain the mtime" do
      mtime = Time.now.to_i
      subject.mtime = mtime
      subject.key_prefix.should include("#{mtime}:")
    end

  end
  
  context "given Rails.cache" do
    before(:each) do
      @cache = WurflCloud::Cache::Rails.new({}, {})
      @key = String.random
      @value = String.random
    end
    
    it "should read the value from the Rails.cache" do
      Rails.cache.write("#{@cache.key_prefix}#{Digest::MD5.hexdigest(@key)}", @value)
      @cache[@key].should ==@value
    end

    it "should set the value into the Rails.cache" do
      @cache[@key] = @value
      Rails.cache.read("#{@cache.key_prefix}#{Digest::MD5.hexdigest(@key)}").should ==@value
    end

    context "with a prefix" do
      before(:each) do
        @cache = WurflCloud::Cache::Rails.new({:prefix=>"a_prefix"}, {})
      end

      it "should not have an empty prefix" do
        @cache.prefix.should =="a_prefix:"
      end

      it "should have the key_prefix start with the prefix" do
        @cache.key_prefix.should =~/^a_prefix:/
      end

      it "should have the key_prefix contain the mtime" do
        mtime = Time.now.to_i
        @cache.mtime = mtime
        @cache.key_prefix.should include("#{mtime}:")
      end

      it "should read the mtime value from Rails.cache" do
        mtime = Time.now.to_i
        Rails.cache.write("a_prefix:mtime", mtime)
        @cache.mtime.should ==mtime
      end

      it "should store the mtime value into Rails.cache" do
        mtime = Time.now.to_i
        @cache.mtime = mtime
        Rails.cache.read("a_prefix:mtime").should ==mtime
      end

      it "should store the mtime value into Rails.cache when validating the cache" do
        mtime = Time.now.to_i
        @cache.validate(mtime)
        Rails.cache.read("a_prefix:mtime").should ==mtime
      end
    end
  end

end