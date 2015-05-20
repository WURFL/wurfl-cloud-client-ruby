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
require 'wurfl_cloud/device_capabilities'
require 'net/http'

module WurflCloud
  class Client
    
    attr_reader :device_capabilities, :read_from_cache
    
    def initialize(e, c)
      @environment = e
      @cache = c
      @device_capabilities = WurflCloud::DeviceCapabilities.new(@environment.user_agent)
      @read_from_cache = false
    end
    
    def [](capability_key)
      if !@device_capabilities.has_key?(capability_key) && @read_from_cache
        load_from_server!
        store_in_cache
      end
      @device_capabilities[capability_key]
    end
    
    def detect
      unless load_from_cache 
        load_from_server!
        store_in_cache
      end
    end
    
    def load_from_server!
      begin
        # make the request
        Net::HTTP.start(WurflCloud.configuration.host,WurflCloud.configuration.port) do |http|
          req = Net::HTTP::Get.new(WurflCloud.configuration.path, http_headers)
          req.basic_auth WurflCloud.configuration.api_user, WurflCloud.configuration.api_password
          res = http.request(req)
          
          # emit the result
          if res.code=="200" 
            # read the response
            @device_capabilities = WurflCloud::DeviceCapabilities.parse(res.body)
            @cache.validate(@device_capabilities.mtime.to_i)
            @read_from_cache = false
          else
            raise WurflCloud::Errors::ConnectionError.new("#{res.code} #{res.message}")
          end
        end    
      rescue WurflCloud::Errors::GenericError => exc
        raise exc
      rescue Exception => exc
        raise WurflCloud::Errors::ConnectionError.new(exc.message)
      end
    end
    
    class << self
      
      def detect_device(environment, cache)
        new(environment, cache).tap do |client|          
          client.detect
        end
      end
      
    end

    private
    
    def http_headers
      {
        'X-Cloud-Client' => "WurflCloudClient/Ruby_#{WurflCloud::VERSION}",
        "Content-Type"=>"application/json; charset=UTF-8"
      }.tap do |h|
        h['User-Agent'] = @environment.user_agent unless @environment.user_agent.nil?
        h['X-Forwarded-For'] = @environment.x_forwarded_for unless @environment.x_forwarded_for.nil?
        h['X-Accept'] = @environment.x_accept unless @environment.x_accept.nil?
        h['X-Wap-Profile'] = @environment.x_wap_profile unless @environment.x_wap_profile.nil?
      end
    end
    
    def store_in_cache
      @cache[@environment.user_agent] = @device_capabilities.to_hash
    end
    
    def load_from_cache 
      if cached_capabilities = @cache[@environment.user_agent]
        @device_capabilities = WurflCloud::DeviceCapabilities.new(@environment.user_agent)
        @device_capabilities.merge(cached_capabilities)
        @read_from_cache = true
        return true
      end      
    end
    
  end
end
