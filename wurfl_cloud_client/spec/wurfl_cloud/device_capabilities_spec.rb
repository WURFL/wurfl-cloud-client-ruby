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
describe WurflCloud::DeviceCapabilities do
  
  context "the object" do    
    it { should respond_to(:[]).with(1).argument }
    it { should respond_to(:[]=).with(2).arguments }
    it { should respond_to(:has_key?).with(1).argument }
    it { should respond_to(:merge).with(1).argument }
    it { should respond_to(:empty?).with(0).arguments }
    it { should respond_to(:mtime).with(0).arguments }
    it { should respond_to(:id).with(0).arguments }
    it { should respond_to(:user_agent).with(0).arguments }
    
    it "should store a value by key" do
      key = String.random
      val = String.random
      subject[key] = val
      subject[key].should ==val 
    end

    it "should return true from has_key? if the key is set" do
      key = String.random
      subject[key] = nil
      subject.has_key?(key).should be_truthy
    end
    
    context "when merging" do
      before(:each) do
        subject = WurflCloud::DeviceCapabilities.new
        @old_key = String.random
        @old_val = String.random
        subject[@old_key] = @old_val

        @new_key = String.random
        @new_val = String.random
      end

      
      context "another DeviceCapabilities object" do
        it "should store a value when merged" do
          subject_2 = WurflCloud::DeviceCapabilities.new
          subject_2[@new_key] = @new_val
          subject.merge(subject_2)
          subject[@new_key].should ==@new_val 
        end

        it "should overwrite a value when merged" do
          subject_2 = WurflCloud::DeviceCapabilities.new
          subject_2[@old_key] = @new_val
          subject.merge(subject_2)
          subject[@old_key].should ==@new_val 
        end
      end
      
    end
    
    context "the empty? method" do
      it "should return true if there are no capabilities defined" do
        WurflCloud::DeviceCapabilities.new.empty?.should be_truthy
      end
      
      it "should return false if there are capabilities defined" do
        subject[String.random] = String.random
        subject.empty?.should be_falsey
      end
    end
  end
  
  context "the parse class method" do
    subject { WurflCloud::DeviceCapabilities }
    
    before(:each) do
      @generic_filtered_json = File.new("#{File.dirname(__FILE__)}/../files/generic_filtered.json").read
    end
    it "should exist" do
      WurflCloud::DeviceCapabilities.should respond_to(:parse).with(1).argument
    end
    
    it "shuould return a DeviceCapabilities object" do
      WurflCloud::DeviceCapabilities.parse(@generic_filtered_json).should be_a(WurflCloud::DeviceCapabilities)
    end
    
    context "the parse result" do
      before(:each) do 
        @parsed = WurflCloud::DeviceCapabilities.parse(@generic_filtered_json)
      end
      { "is_wireless_device"=>false,
        "browser_id"=>"browser_root",
        "fall_back"=>"root",
        "user_agent"=>"",
        "device_os_version"=>10.5,
        "resolution_width"=>800
      }.each do |key, value|
        it "should populate the DeviceCapabilities key #{key}  with the value #{value.to_s.empty? ? "''" : value} from the json pased in" do
          @parsed[key].should ==value
        end
      end
      
      it "should have the mtime set to a Time object" do
        @parsed.mtime.should ==Time.at(1330016154)
      end
      
      it "should return the correct wurfl id calling its is method" do
        @parsed.id.should =="generic"
      end
    end
    
    context "parsing capabilities with boolean and numeric casted to strings" do
      before(:each) do 
        @parsed = WurflCloud::DeviceCapabilities.parse(File.new("#{File.dirname(__FILE__)}/../files/strange_values.json").read)
      end
      { "is_tablet"=>false,
        "is_wireless_device"=>true,
        "resolution_width"=>800,
        "release_date"=>"1994_january"
      }.each do |key, value|
        it "should populate the DeviceCapabilities key #{key}  with the correct value #{value.to_s.empty? ? "''" : value} from the json pased in" do
          @parsed[key].should ==value
        end
      end
    end

    it "should be empty if no capabilities defined in the json" do 
      @parsed = WurflCloud::DeviceCapabilities.parse(%{{"apiVersion":"WurflCloud 1.3.2","mtime":1330016154,"id":"generic","capabilities":{},"errors":{}}})
    end
    
    it "should raise and error if the json is not in the correct format" do
      expect { WurflCloud::DeviceCapabilities.parse(%{}) }.to raise_error(WurflCloud::Errors::MalformedResponseError)
    end
    
  end
end