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
require 'wurfl_cloud/cache/memcached'
require 'digest/md5'
require 'dalli'

describe WurflCloud::Cache::Memcached do
  subject { WurflCloud::Cache::Memcached.new({:server=>'localhost:11211'}, {}) }

  before(:each) do
    @memcached = Dalli::Client.new('localhost:11211')
    @memcached.flush()
    @key = String.random
    @value = String.random
  end
  
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
    
    it "should have an empty prefix" do
      subject.prefix.should ==""
    end
    
    it "should have the key_prefix contain the mtime" do
      mtime = Time.now.to_i
      subject.mtime = mtime
      subject.key_prefix.should include("#{mtime}:")
    end
    
    it "should store values" do
      key = String.random
      subject[key] = String.random
      subject[key].should_not be_nil
    end
    
    it "should read the value from the memcache" do
      @memcached.set("#{subject.key_prefix}#{Digest::MD5.hexdigest(@key)}", @value)
      subject[@key].should ==@value
    end

    it "should set the value into memcache" do
      subject[@key] = @value
      @memcached.get("#{subject.key_prefix}#{Digest::MD5.hexdigest(@key)}").should ==@value
    end

    it "should read the mtime value from memcache" do
      mtime = Time.now.to_i
      @memcached.set("mtime", mtime)
      subject.mtime.should ==mtime
    end

    it "should store the mtime value into memcache" do
      mtime = Time.now.to_i
      subject.mtime = mtime
      @memcached.get("mtime").should ==mtime
    end

    it "should store the mtime value into memcache when validating the cache" do
      mtime = Time.now.to_i
      subject.validate(mtime)
      @memcached.get("mtime").should ==mtime
    end
  end
  
  context "with a prefix" do
    before(:each) do
      @cache = WurflCloud::Cache::Memcached.new({:server=>'localhost:11211', :prefix=>"a_prefix"}, {})
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
    
    it "should read the mtime value from memcache" do
      mtime = Time.now.to_i
      @memcached.set("a_prefix:mtime", mtime)
      @cache.mtime.should ==mtime
    end

    it "should store the mtime value into memcache" do
      mtime = Time.now.to_i
      @cache.mtime = mtime
      @memcached.get("a_prefix:mtime").should ==mtime
    end

    it "should store the mtime value into memcache when validating the cache" do
      mtime = Time.now.to_i
      @cache.validate(mtime)
      @memcached.get("a_prefix:mtime").should ==mtime
    end
  end
end