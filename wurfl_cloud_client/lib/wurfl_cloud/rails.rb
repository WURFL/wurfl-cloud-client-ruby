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
require 'wurfl_cloud/helper'
require 'wurfl_cloud/rack/cache_manager'

module WurflCloud
  class Engine < ::Rails::Engine

    # # Initialize the cache manager rack middleware
    # config.app_middleware.use WurflCloud::Rack::CacheManager
  
    # adds the moethods to the controller and views
    initializer "wurf_cloud.helpers" do
      ActiveSupport.on_load(:action_controller) do
        include WurflCloud::Helper
        helper_method :wurfl_detect_device
      end

      ActiveSupport.on_load(:action_view) do
        include WurflCloud::Helper
      end
    end

  end
end
