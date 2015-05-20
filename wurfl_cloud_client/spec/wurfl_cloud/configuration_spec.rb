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
describe WurflCloud::Configuration do
  after(:all) do
    WurflCloud.configuration = WurflCloud::Configuration.new
  end
  
  it "should give a new instance if non defined" do
    WurflCloud.configuration = nil
    WurflCloud.configuration.should be_a(WurflCloud::Configuration)
  end
  
  context "the configure method" do
    it "should yield an instance of the configuration" do
      WurflCloud.configure do |config|
        config.should be_a(WurflCloud::Configuration)
      end
    end

    it "should allow writing of the configuration" do
      str = String.random
      WurflCloud.configure do |config|
        config.host = str
      end
      WurflCloud.configuration.host.should ==str
    end
  end
  
  {
    :host => 'api.wurflcloud.com',
    :path => '/v1/json',
    :port => 80,
    :schema => 'http',
    :api_type => 'http',
    :search_parameter => 'search:(%{capabilities})',
    :search_parameter_separator => ',',
    :cache_class => WurflCloud::Cache::Null,
    :cache_options => {}
  }.each do |key, value|
    
    it "should have the right default for #{key}" do
      subject.send(key).should ==value
    end
    
    it "should allow overriding default of #{key}" do 
      v = String.random
      subject.send(:"#{key}=", v)
      subject.send(key).should ==v
    end  
     
  end
    
  it "should return the correct api_uri" do
    c = WurflCloud.configuration
    c.schema = String.random
    c.host = String.random
    c.path = String.random
    c.port = String.random
    c.api_uri.should == "#{c.schema}://#{c.host}:#{c.port}#{c.path}"
  end
  
  context "the cache method" do

    it "should return a @cache_class object " do
      subject.cache(Object.new).should be_a(subject.cache_class)
    end
    
    it "should call the initialize method of the cache class " do
      env = Object.new
      subject.cache_class.should_receive(:new).with(subject.cache_options, env)
      cache = subject.cache(env)
    end
    
  end
  context "the api_key method" do
    
    it "should have the right default" do
      subject.api_key.should =='100000:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    end

    it "should allow overriding the default" do 
      u = 100000+rand(99999)
      p = String.az_random(32)
      subject.api_key = "#{u}:#{p}"
      subject.api_key.should =="#{u}:#{p}"
    end  

    it "should throw an exception if called with a key with the worng format" do
      expect { subject.api_key = "a wrong api key" }.to raise_error(WurflCloud::Errors::ConfigurationError)
    end
    
    it "should have set the api_user value" do
      u = 100000+rand(99999)
      p = String.az_random(32)
      subject.api_key = "#{u}:#{p}"
      subject.api_user.should ==u
    end
    
    it "should set the api_password value" do
      u = 100000+rand(99999)
      p = String.az_random(32)
      subject.api_key = "#{u}:#{p}"
      subject.api_password.should ==p
    end
    
  end
end

