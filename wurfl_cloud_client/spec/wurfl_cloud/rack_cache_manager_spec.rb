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

describe WurflCloud::Rack::CacheManager do

  context "the wurfl.cookie.device_cache env parameter" do
        
    it "should be inserted if the cookie exists" do
      cookie = {'date_set' => Time.now.to_i, 'capabilities' => {'name'=>'example'}}
      env = env_with_params("/", {}, {"HTTP_COOKIE" => "#{WurflCloud::Rack::CacheManager::COOKIE_NAME}=#{::Rack::Utils.escape(cookie.to_json)}"})
      setup_rack(success_app).call(env)
      env["wurfl.cookie.device_cache"].should_not be_nil
    end

    it "should be decoded from json" do
      cookie = {'date_set' => Time.now.to_i, 'capabilities' => {'name'=>'example'}}
      env = env_with_params("/", {}, {"HTTP_COOKIE" => "#{WurflCloud::Rack::CacheManager::COOKIE_NAME}=#{::Rack::Utils.escape(cookie.to_json)}"})
      setup_rack(success_app).call(env)
      env["wurfl.cookie.device_cache"].should =={'name'=>'example'}
    end

    it "should be nil if it doesn't exist" do
      env = env_with_params("/", {}, {})
      setup_rack(success_app).call(env)
      env["wurfl.cookie.device_cache"].should be_nil
    end

    it "should be nil if not a valid json object" do
      cookie = {}
      env = env_with_params("/", {}, {"HTTP_COOKIE" => "#{WurflCloud::Rack::CacheManager::COOKIE_NAME}=#{::Rack::Utils.escape("{}")}"})
      setup_rack(success_app).call(env)
      env["wurfl.cookie.device_cache"].should be_nil
    end
    
    it "should be nil if it lacks the date_set field" do
      cookie = {'capabilities' => {}}
      env = env_with_params("/", {}, {"HTTP_COOKIE" => "#{WurflCloud::Rack::CacheManager::COOKIE_NAME}=#{::Rack::Utils.escape(cookie.to_json)}"})
      setup_rack(success_app).call(env)
      env["wurfl.cookie.device_cache"].should be_nil
    end

    it "should be nil if it lacks the capabilities field" do
      cookie = {'date_set' => Time.now.to_i}
      env = env_with_params("/", {}, {"HTTP_COOKIE" => "#{WurflCloud::Rack::CacheManager::COOKIE_NAME}=#{::Rack::Utils.escape(cookie.to_json)}"})
      setup_rack(success_app).call(env)
      env["wurfl.cookie.device_cache"].should be_nil
    end

    it "should be nil if the capabilities field is empty" do
      cookie = {'date_set' => (Time.now-WurflCloud::Rack::CacheManager::EXPIRY-1).to_i, 'capabilities' => {}}
      env = env_with_params("/", {}, {"HTTP_COOKIE" => "#{WurflCloud::Rack::CacheManager::COOKIE_NAME}=#{::Rack::Utils.escape(cookie.to_json)}"})
      setup_rack(success_app).call(env)
      env["wurfl.cookie.device_cache"].should be_nil
    end

    it "should be nil if the cookie was expired" do
      cookie = {'date_set' => (Time.now-WurflCloud::Rack::CacheManager::EXPIRY-1).to_i, 'capabilities' => {'name'=>'example'}}
      env = env_with_params("/", {}, {"HTTP_COOKIE" => "#{WurflCloud::Rack::CacheManager::COOKIE_NAME}=#{::Rack::Utils.escape(cookie.to_json)}"})
      setup_rack(success_app).call(env)
      env["wurfl.cookie.device_cache"].should be_nil
    end

  end

end
