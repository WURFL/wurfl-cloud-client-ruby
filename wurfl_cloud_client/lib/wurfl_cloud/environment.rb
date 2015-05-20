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

module WurflCloud
  class Environment
    
    USER_AGENT_FIELDS = [
      'HTTP_X_DEVICE_USER_AGENT',
  		'HTTP_X_ORIGINAL_USER_AGENT',
  		'HTTP_X_OPERAMINI_PHONE_UA',
  		'HTTP_X_SKYFIRE_PHONE',
  		'HTTP_X_BOLT_PHONE_UA',
  		'HTTP_USER_AGENT'
    ]
    
    attr_reader :user_agent, :x_forwarded_for, :x_accept, :x_wap_profile
    
    # Extracts the http headers that are relevant 
    # to the library. They are used by the client 
    # when communicating with the API server.
    def initialize(http_env={})
      USER_AGENT_FIELDS.each do |ua_field|
        @user_agent ||= http_env[ua_field] 
      end
      
      @x_accept = http_env["HTTP_ACCEPT"]
      
      if !(@x_wap_profile = http_env["HTTP_X_WAP_PROFILE"])
        @x_wap_profile = http_env["HTTP_PROFILE"]
      end
      
      if http_env["REMOTE_ADDR"]
        @x_forwarded_for = http_env["REMOTE_ADDR"]
        @x_forwarded_for = "#{x_forwarded_for}, #{http_env["HTTP_X_FORWARDED_FOR"]}" if http_env["HTTP_X_FORWARDED_FOR"]
      end
    end
  end
end
