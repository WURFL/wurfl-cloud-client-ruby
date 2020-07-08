class DemoController < ApplicationController

  def index
    @wurfl_device = wurfl_detect_device(request.env)
  end
end
