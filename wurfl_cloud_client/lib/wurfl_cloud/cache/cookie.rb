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
module WurflCloud
  module Cache
    class Cookie
      
      def initialize(options, environment)
        @env = environment
      end
      
      attr_accessor :mtime
      
      def mtime
        nil
      end

      # Validates the cache
      # it's a no-op in the cookie cache
      def validate(current_mtime)
      end
      
      # Should return the value stored for the key, nil if the key is not in cache
      # The Cookie cache always returns the value of the env (no matter what the key)
      def [](key)
        @env['wurfl.cookie.device_cache']
      end
      
      # Sets the value in the cache, for the Cookie cache it sets the env
      def []=(key, value)
        @env['wurfl.cookie.device_cache'] = value
      end
    end
  end
end
