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


describe "the client doing a real request" do
    before(:all) do
      unless defined?(TEST_API_KEY)
        pending(%{ MISSING TEST API KEY
          To be able to execute this test you need to add a file spec/support/test_api_key.rb in which you define the 
          constant TEST_API_KEY to hold the api key you'll be using to do the test: 
          TEST_API_KEY = '000000:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
          ** DO NOT ADD YOUR KEY TO THE REPOSITORY **
        }) 
      else
        WurflCloud.configure do |config|
          config.host = 'api.wurflcloud.com'
          config.api_key = TEST_API_KEY
        end
        @environment = WurflCloud::Environment.new({"HTTP_USER_AGENT"=>%{Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Mobile/7D11}})

        WebMock.allow_net_connect!
        @device = WurflCloud::Client.detect_device(@environment, WurflCloud.configuration.cache(nil))
      end
    end
    
    it "should detect the correct device" do
      
      @device['id'].should =='apple_iphone_ver4'
    end

    it "should have the device capabilities" do
      @device['advertised_device_os'].should == 'iOS'
    end
    
end
