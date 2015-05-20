# encoding: utf-8
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
require 'wurfl_cloud/helper'

describe WurflCloud::Helper do
  include WurflCloud::Helper
  
  context "the wurfl_detect_device method" do

    it "should return a WurflCloud::Client object" do
      
      cookie = {'date_set' => Time.now.to_i, 'capabilities' => {'name'=>'example'}}
      env = env_with_params("/", {}, {"HTTP_USER_AGENT"=>String.random, "HTTP_COOKIE" => "#{WurflCloud::Rack::CacheManager::COOKIE_NAME}=#{::Rack::Utils.escape(cookie.to_json)}"})
      
      @device_data = File.new("#{File.dirname(__FILE__)}/../files/generic.json").read
      stub_request(:any, authenticated_uri).to_return(:status=>200, :body => @device_data)

      @wurfl_device = wurfl_detect_device(env)     
      @wurfl_device.should be_instance_of(WurflCloud::Client)

    end
  end

end
