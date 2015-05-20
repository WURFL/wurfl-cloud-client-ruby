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
describe WurflCloud::Cache::Null do
  subject { WurflCloud::Cache::Null.new({}, Object.new) }
  
  context "the object" do    
    it { should respond_to(:[]).with(1).argument }
    it { should respond_to(:[]=).with(2).arguments }
    it { should respond_to(:mtime).with(0).arguments }
    it { should respond_to(:mtime=).with(1).argument }
    
    it "should not throw errors calling []=" do
      expect { subject[String.random] = String.random }.to_not raise_error
    end

    it "should not store values" do
      key = String.random
      subject[key] = String.random
      subject[key].should be_nil
    end
    
    it "should not store the mtime" do
      subject.mtime = rand
      subject.mtime.should be_nil
    end
  end
end