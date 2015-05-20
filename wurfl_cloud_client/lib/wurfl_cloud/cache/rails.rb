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
require 'digest/md5'
module WurflCloud
  module Cache
    class Rails
      
      def initialize(options, environment)
        @prefix = options[:prefix]||''
      end
      
      def prefix
        "#{(@prefix.nil? || @prefix=="") ? "": "#{@prefix}:"}"
      end
      
      def key_prefix        
        "#{prefix}:#{mtime}:"
      end
      
      def mtime
        ::Rails.cache.read("#{prefix}mtime")
      end
      
      def mtime=(new_mtime)
        ::Rails.cache.write("#{prefix}mtime", new_mtime)
      end

      # Validates the cache
      # checks if the cache is still valid with respect to a new mtime received from the server
      # if the new mtime is different from the one cached then it overwrites the current key
      # prefix thus actually invalidationg the cache
      def validate(current_mtime)
      end
      
      # Should return the value stored for the key, nil if the key is not in cache
      # The Rails cache reads from the Rails.cache object
      def [](key)
        ::Rails.cache.read("#{key_prefix}#{Digest::MD5.hexdigest(key)}")
      end
      
      # Stores the value for the key in the Rails.cache
      def []=(key, value)
        ::Rails.cache.write("#{key_prefix}#{Digest::MD5.hexdigest(key)}", value)
      end
    end
  end
end
