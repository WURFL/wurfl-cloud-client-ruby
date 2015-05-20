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
describe WurflCloud::Environment do

  context "the class" do  
    it "should respond to new with 1 argument" do
      WurflCloud::Environment.should respond_to(:new).with(1).argument
    end
  end
  
  context "the object" do
    [
      :user_agent,
      :x_forwarded_for,
      :x_accept,
      :x_wap_profile
    ].each do |header|
      it { should respond_to(header) }
      it "should return nil if not set in the constructor" do
        subject.send(header).should be_nil
      end
    end
    
    context "the user_agent" do
      [
        'HTTP_X_DEVICE_USER_AGENT',
    		'HTTP_X_ORIGINAL_USER_AGENT',
    		'HTTP_X_OPERAMINI_PHONE_UA',
    		'HTTP_X_SKYFIRE_PHONE',
    		'HTTP_X_BOLT_PHONE_UA',
    		'HTTP_USER_AGENT'
  		].each do |user_agent_param|
        it "should be read from #{user_agent_param} " do
          env = {user_agent_param=>String.random}
          WurflCloud::Environment.new(env).user_agent.should ==env[user_agent_param]
        end
  		end

    end

    context "the x_accept" do
      it "should be read from HTTP_ACCEPT " do
        env = {"HTTP_ACCEPT"=>String.random}
        WurflCloud::Environment.new(env).x_accept.should ==env["HTTP_ACCEPT"]
      end
    end

    context "the x_wap_profile" do
      it "should be read from HTTP_X_WAP_PROFILE if present and HTTP_PROFILE is null" do
        env = {"HTTP_X_WAP_PROFILE"=>String.random}
        WurflCloud::Environment.new(env).x_wap_profile.should ==env["HTTP_X_WAP_PROFILE"]
      end

      it "should be read from HTTP_X_WAP_PROFILE if present and HTTP_PROFILE is present" do
        env = {"HTTP_X_WAP_PROFILE"=>String.random, "HTTP_PROFILE"=>String.random}
        WurflCloud::Environment.new(env).x_wap_profile.should ==env["HTTP_X_WAP_PROFILE"]
      end
      
      it "should be read from HTTP_PROFILE if present and HTTP_X_WAP_PROFILE is nil" do
        env = {"HTTP_PROFILE"=>String.random}
        WurflCloud::Environment.new(env).x_wap_profile.should ==env["HTTP_PROFILE"]
      end
    end

    context "the x_forwarded_for" do
      it "should be the REMOTE_ADDR if present and HTTP_X_FORWARDED_FOR is absent" do
        env = {"REMOTE_ADDR"=>String.random}
        WurflCloud::Environment.new(env).x_forwarded_for.should ==env["REMOTE_ADDR"]
      end
      
      it "should be the REMOTE_ADDR, HTTP_X_FORWARDED_FOR if both are present" do
        env = {"REMOTE_ADDR"=>String.random, "HTTP_X_FORWARDED_FOR"=>String.random}
        WurflCloud::Environment.new(env).x_forwarded_for.should =="#{env["REMOTE_ADDR"]}, #{env["HTTP_X_FORWARDED_FOR"]}"
      end
      
      it "should be nil if REMOTE_ADDR and HTTP_X_FORWARDED_FOR is present" do
        env = {"HTTP_X_FORWARDED_FOR"=>String.random}
        WurflCloud::Environment.new(env).x_forwarded_for.should be_nil
      end
    end
    
  end
end