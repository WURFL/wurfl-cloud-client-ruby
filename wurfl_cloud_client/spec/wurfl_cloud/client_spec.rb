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
require 'wurfl_cloud/cache/local_memory'

describe WurflCloud::Client do
  subject { WurflCloud::Client.new(WurflCloud::Environment.new, nil) }
  
  it "should contain a device_capabilities object" do
    subject.device_capabilities.should be_instance_of(WurflCloud::DeviceCapabilities)
  end
  
  it "should delegate the [] method to the device_capabilities object" do
    capability_name = String.random
    subject.device_capabilities.should_receive(:[]).with(capability_name)
    subject[capability_name]
  end

  it "should have a read_from_cache method" do
    subject.should respond_to(:read_from_cache)
  end
  
  context "the detect_device method" do
    it "should be defined with 2 parameters" do
      WurflCloud::Client.should respond_to(:detect_device).with(2).arguments
    end
    
  end
  
  context "when using with the default null cache" do
    before(:each) do
      @http_env = {
        "HTTP_USER_AGENT"=>String.random,
        "HTTP_ACCEPT"=>String.random,
        "HTTP_X_WAP_PROFILE"=>String.random,
        "REMOTE_ADDR"=>String.random
      }
      @environment = WurflCloud::Environment.new(@http_env)
      @cache = WurflCloud.configuration.cache(nil)
      
      @device_data = File.new("#{File.dirname(__FILE__)}/../files/generic.json").read

      stub_request(:any, authenticated_uri).to_return(:status=>200, :body => @device_data)
      
      @wurfl_client = WurflCloud::Client.detect_device(@environment, @cache)
      
    end
    
    it "should validate the cache when loading from server" do
      @cache.should_receive(:validate).with(1330016154)
      @wurfl_client.load_from_server!
    end

    it "should return an instance of the client class" do
      @wurfl_client.should be_instance_of(WurflCloud::Client)
    end

    it "should call the remote webservice" do
      WebMock.should have_requested(:get, authenticated_uri)
    end

    it "should call the remote webservice each time detect_device is called" do
      WurflCloud::Client.detect_device(@environment, @cache)
      WebMock.should have_requested(:get, authenticated_uri).times(2)
    end
    
    
    it "should pass the correct headers" do
      headers = {
        'User-Agent' => @http_env["HTTP_USER_AGENT"],
        'X-Cloud-Client' => "WurflCloudClient/Ruby_#{WurflCloud::VERSION}",
        'X-Forwarded-For' => @http_env["REMOTE_ADDR"],
        'X-Accept' => @http_env["HTTP_ACCEPT"],
        'X-Wap-Profile' => @http_env["HTTP_X_WAP_PROFILE"],
      }
      stub_request(:any, authenticated_uri).with(:headers=>headers).to_return(:status=>200, :body => @device_data)
      WurflCloud::Client.detect_device(@environment, @cache)
    end
    
    { "is_wireless_device"=>false,
      "browser_id"=>"browser_root",
      "fall_back"=>"root",
      "user_agent"=>"",
      "resolution_width"=>90
    }.each do |key, value|
      it "should return the right values for the capability #{key}" do
        @wurfl_client[key].should ==value
      end
      it "should not call the webservice to read a capability that's present in the answer" do
        value = @wurfl_client[key]
        WebMock.should have_requested(:get, authenticated_uri).times(1)
      end
    end
    
  end

  context "when using with a simple local memory cache" do
    
    before(:each) do
      @http_env = {
        "HTTP_USER_AGENT"=>String.random,
        "HTTP_ACCEPT"=>String.random,
        "HTTP_X_WAP_PROFILE"=>String.random,
        "REMOTE_ADDR"=>String.random
      }
      @environment = WurflCloud::Environment.new(@http_env)
      @cache = WurflCloud::Cache::LocalMemory.new
      
      @device_data = File.new("#{File.dirname(__FILE__)}/../files/generic.json").read
      
      stub_request(:any, authenticated_uri).to_return(:status=>200, :body => @device_data)
      @wurfl_client = WurflCloud::Client.detect_device(@environment, @cache)
    end
    

    it "should call the remote webservice once if the same agent is detected twice" do
      WurflCloud::Client.detect_device(@environment, @cache)
      WebMock.should have_requested(:get, authenticated_uri).times(1)
    end
    
    context "requesting a non existent capability" do
      context "just after the capabilities have been read from the server" do
        it "should not call again the webservice" do
          value = @wurfl_client['my_non_existent_capability']
          WebMock.should have_requested(:get, authenticated_uri).times(1)
        end
        it "should return nil" do
          @wurfl_client['my_non_existent_capability'].should be_nil
        end
      end
      
      context "detecting the device from the cache" do
        before(:each) do
          @wurfl_client = WurflCloud::Client.detect_device(@environment, @cache)
        end
        
        it "should call again the webservice" do
          value = @wurfl_client['my_non_existent_capability']
          WebMock.should have_requested(:get, authenticated_uri).times(2)
        end
        
        it "should return nil if it doesn't exist" do
          @wurfl_client['my_non_existent_capability'].should be_nil
        end

        it "should return the right value if exists" do
          stub_request(:any, authenticated_uri).to_return(:status=>200, :body => %{{"apiVersion":"WurflCloud 1.3.2","mtime":1330016154,"id":"generic","capabilities":{"my_non_existent_capability":"OK"},"errors":{}}})
          @wurfl_client['my_non_existent_capability'].should =="OK"
        end        

        it "should call the webservice only once for each access to the capability value" do
          stub_request(:any, authenticated_uri).to_return(:status=>200, :body => %{{"apiVersion":"WurflCloud 1.3.2","mtime":1330016154,"id":"generic","capabilities":{"my_non_existent_capability":"OK"},"errors":{}}})
          value = @wurfl_client['my_non_existent_capability']
          value = @wurfl_client['my_non_existent_capability']
          WebMock.should have_requested(:get, authenticated_uri).times(2)
        end        
      end
    end
  end

  context "when the webservice has errors" do
    before(:each) do
      @http_env = {
        "HTTP_USER_AGENT"=>String.random,
        "HTTP_ACCEPT"=>String.random,
        "HTTP_X_WAP_PROFILE"=>String.random,
        "REMOTE_ADDR"=>String.random
      }
      @environment = WurflCloud::Environment.new(@http_env)
      @cache = WurflCloud.configuration.cache(nil)
      
      @device_data = File.new("#{File.dirname(__FILE__)}/../files/generic.json").read
    end
    
    it "should raise WurflCloud::Errors::ConnectionError if there are connection timeouts" do
      stub_request(:any, authenticated_uri).to_timeout
  
      expect { WurflCloud::Client.detect_device(@environment, @cache) }.to raise_error(WurflCloud::Errors::ConnectionError)
    end
    it "should raise WurflCloud::Errors::ConnectionError if there are connection errors" do
      stub_request(:any, authenticated_uri).to_raise("some error")
  
      expect { WurflCloud::Client.detect_device(@environment, @cache) }.to raise_error(WurflCloud::Errors::ConnectionError)    
    end
    it "should raise WurflCloud::Errors::ConnectionError if there are server errors" do
      stub_request(:any, authenticated_uri).to_return(:status=>500)
  
      expect { WurflCloud::Client.detect_device(@environment, @cache) }.to raise_error(WurflCloud::Errors::ConnectionError)
    end
    it "should raise WurflCloud::Errors::MalformedResponseError if there are unparsable responses" do
      stub_request(:any, authenticated_uri).to_return(:status=>200, :body => %{badjson})       
  
      expect { WurflCloud::Client.detect_device(@environment, @cache) }.to raise_error(WurflCloud::Errors::MalformedResponseError)
    end
  
  end

end