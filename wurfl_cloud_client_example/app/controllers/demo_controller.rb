class DemoController < ApplicationController

  def index
    @wurfl_device = wurfl_detect_device(env) 
  end
end
