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
describe WurflCloud::Cache::Cookie do
  subject { WurflCloud::Cache::Cookie.new({}, {}) }
  
  context "the object" do    
    it { should respond_to(:[]).with(1).argument }
    it { should respond_to(:[]=).with(2).arguments }
    it { should respond_to(:mtime).with(0).arguments }
    it { should respond_to(:mtime=).with(1).argument }
    
    it "should not throw errors calling []=" do
      expect { subject[String.random] = String.random }.to_not raise_error
    end

    it "should store values" do
      key = String.random
      subject[key] = String.random
      subject[key].should_not be_nil
    end
    
  end
  
  context "for the environment" do
    before(:each) do
      @env = Hash.new
      @cache = WurflCloud::Cache::Cookie.new({}, @env)
    end
    
    it "should read the value from the wurfl.cookie.device_cache env variable" do
      @env['wurfl.cookie.device_cache'] = String.random
      @cache[String.random].should ==@env['wurfl.cookie.device_cache']
    end

    it "should set the value into the wurfl.cookie.device_cache env variable" do
      value = String.random
      @cache[String.random] = value
      @env['wurfl.cookie.device_cache'].should ==value
    end
  end
end