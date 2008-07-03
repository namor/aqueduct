class Aqueduct::CSS
  module Filters
  
    def remove_javascript_from_url(property)
      return (!property[:value].to_s.include?("javascript:")) && (!property[:value].to_s.include?(".js"))
    end
  
    def remove_high_zindex(property)
      return false if property[:name] == "z-index" and property[:value].first.to_s.to_i >= 200
      return true
    end
  
  end
end