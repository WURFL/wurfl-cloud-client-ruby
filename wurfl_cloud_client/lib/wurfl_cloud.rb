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
require 'wurfl_cloud/configuration'
require 'wurfl_cloud/cache/null'
require 'wurfl_cloud/cache/cookie'
require 'wurfl_cloud/version'
require 'wurfl_cloud/client'
require 'wurfl_cloud/environment'
require 'wurfl_cloud/device_capabilities'
require 'wurfl_cloud/errors'

module WurflCloud

  class << self

    # A configuration object. See WurflCloud::Configuration.
    attr_writer :configuration

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   WurflCloud.configure do |config|
    #     config.api_key = '00000000:xxxxxxxxxxxxxxxxxxxxxxxxxxx'
    #     config.host  = 'staging.wurflcloud.com'
    #   end
    def configure(silent = false)
      yield(configuration)
    end

    # The configuration object.
    # @see WurflCloud.configure
    def configuration
      @configuration ||= WurflCloud::Configuration.new
    end

  end

end

require 'wurfl_cloud/rails' if defined?(Rails)
