WurflCloud.configure do |config|
  config.host = 'api.wurflcloud.com'
  config.api_key = '000000:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' # add you api key here
  config.cache_class = WurflCloud::Cache::Cookie
end

Rails.configuration.middleware.use WurflCloud::Rack::CacheManager

# ==================================
# Example configuration using Rails cache
#
# require 'wurfl_cloud/cache/rails'
# WurflCloud.configure do |config|
#   config.host = 'api.wurflcloud.com'
#   config.api_key = '000000:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' # add you api key here
#   config.cache_class = WurflCloud::Cache::Rails
# end
# =================================== 

# =================================== 
# Example configuration using the memcached cache
# require 'wurfl_cloud/cache/memcached'
# WurflCloud.configure do |config|
#   config.host = 'api.wurflcloud.com'
#   config.api_key = '000000:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' # add you api key here
#   config.cache_class = WurflCloud::Cache::Memcached
#   config.cache_options = {:server=>'localhost:11211'}
# end
# =================================== 
