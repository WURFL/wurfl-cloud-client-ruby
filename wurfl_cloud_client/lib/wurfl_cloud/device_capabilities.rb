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
require 'wurfl_cloud/errors'
require 'json'

module WurflCloud
  class DeviceCapabilities
    attr_accessor :mtime, :id, :user_agent
    
    def initialize(ua = nil)
      @capabilities = {}
      @mtime = Time.at(0)
      @id = nil
      @user_agent = ua
    end
    
    def [](key)
      @capabilities[key]
    end

    def []=(key, value)
      @capabilities[key] = value
    end
    
    def merge(newvalues)
      @capabilities.merge!(newvalues)
    end
    
    def empty?
      @capabilities.empty?
    end
    
    def has_key?(key)
      @capabilities.has_key?(key)
    end
    
    def to_hash
      @capabilities.clone
    end
    class << self
      def parse(json)
        object = JSON.parse(json)
        new.tap do |device_capabilities|
          object["capabilities"].each do |key,value|
            device_capabilities[key] = cast_value(value)
          end
          
          device_capabilities.id = object["id"]
          device_capabilities["id"] = object["id"]
          device_capabilities.mtime = Time.at(object["mtime"].to_i)
        end
      rescue 
        raise WurflCloud::Errors::MalformedResponseError.new
      end
      
      private
      
      def cast_value(value)
        case value.to_s
          when "true" then true ;
          when "false" then false ;
          when /^[1-9][0-9]*$/ then value.to_s.to_i ;
          when /^[1-9][0-9]*\.[0-9]+$/ then value.to_s.to_f ;
          else value
        end
      end
    end
  end
end
