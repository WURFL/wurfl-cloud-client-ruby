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
module WurflCloud::Rack
  class CacheManager
    # to be refactored: make configurable
    COOKIE_NAME = 'WurflCloud_Client'
    EXPIRY = 86400
    
    def initialize(app, options={})
      @app = app
    end
    def call(env)
      # extract cookie
      request = Rack::Request.new(env)
      env['wurfl.cookie.device_cache'] = extract_wurfl_cookie(request.cookies)
      
      # execute upstream request
      status, headers, body = @app.call(env)
      
      # store cookie
      response = Rack::Response.new body, status, headers
      response.set_cookie(COOKIE_NAME, {:value => {'date_set'=>Time.now.to_i, 'capabilities'=>env['wurfl.cookie.device_cache']}.to_json, :path => "/", :expires => Time.now+EXPIRY})
      response.finish 
    end
    
    private
    
    def extract_wurfl_cookie(cookies)
      # read the cookie and try to parse it
      raw_cookie = cookies[COOKIE_NAME] 
      parsed_cookie = JSON.parse(raw_cookie)
      
      # if parsed then check the expiry
      return nil if !parsed_cookie.has_key?('date_set') || (parsed_cookie['date_set'].to_i+EXPIRY < Time.now.to_i)
      
      # check if the capabilities params are present
      return nil if !parsed_cookie.has_key?('capabilities') || !parsed_cookie['capabilities'].is_a?(Hash) || parsed_cookie['capabilities'].empty?
      
      parsed_cookie['capabilities']

    rescue Exception=>e
      nil
    end
  end
end
