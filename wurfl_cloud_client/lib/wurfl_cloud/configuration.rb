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
  class Configuration
    # The API key to access the WurflCloud api (defaults to "100000:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx").
    attr_accessor :api_key
    
    # The API user id decoded from the api_key
    attr_reader :api_user

    # The API password decoded from the api_key
    attr_reader :api_password

    # The schema of the URI for the api server (defaults to http).
    attr_accessor :schema

    # The host to connect to (defaults to api.wurflcloud.com).
    attr_accessor :host

    # The port on which your WurflCloud server runs (defaults to 80).
    attr_accessor :port

    # The path (URL) for the API endpoint at the host (defaults to /v1/json).
    attr_accessor :path

    # The API Type, defaults to http (*not used*)
    attr_accessor :api_type
    
    # The search parameter format (defaults to "search:(%{capabilities})")
    attr_accessor :search_parameter 
    
    # The search parameter capabilities separator (defaults to ",")
    attr_accessor :search_parameter_separator
    
    # The cache class to be used (defaults to a WurflCloud::Cache::Null )
    attr_accessor :cache_class

    # The cache_options to be used (defaults to {})
    attr_accessor :cache_options
    
    def initialize
      @api_key                    = "100000:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      @api_user                   = 100000
      @api_password               = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      @host                       = 'api.wurflcloud.com'
      @schema                     = 'http'
      @port                       = 80
      @path                       = '/v1/json'
      @api_type                   = 'http'
      @search_parameter           = "search:(%{capabilities})"
      @search_parameter_separator = ','
      @cache_class                = WurflCloud::Cache::Null
      @cache_options              = {}
    end
    
    def api_key=(new_key)
      @api_key = new_key
      if new_key=~/^(\d{6}):(\w{32})$/
        @api_user = $1.to_i
        @api_password = $2
      else
        raise WurflCloud::Errors::ConfigurationError.new
      end
    end
    
    def api_uri
      "#{@schema}://#{@host}:#{@port}#{@path}"
    end
    
    # creates a cache instance using the class and the options 
    # given in the confinguration and passing whatever environment
    # is passed in the parameters
    def cache(environment)
      @cache_class.new(@cache_options, environment)
    end
  end
end
