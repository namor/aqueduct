require 'rubygems'
require 'hpricot'

require File.expand_path(File.dirname(__FILE__) + '/embed/exceptions')

class Aqueduct::Embed
  
  # Sanitize embed codes
  # Options
  #   :width => Set Embed object's maximum width
  #   :height => Set Embed object's maximum height
  def initialize(embed_code, options = {})
    @embed_code = embed_code
    @options = options
  end
  
  def sanitize
    @sanitized_embed_code ||= sanitize_embed_code(@embed_code, @options)
  end
  
  def to_s
    sanitize
  end
  
  def sanitize_embed_code(embed_code, options)
    code = Hpricot(embed_code)
    
    # Object movie param must be equal to embed src
    raise EmbedSrcMissingOrInvalid unless src_path_valid?(code)
    
    # Checks if embed code src is supported.
    raise UnsupportedService unless src_path_supported?(code)
    
    # Makes sure embed object width and height are okay
    embed_code = limit_width_and_height(code, options[:height], options[:width])
    
    # Sanitize embed code
    # Aqueduct::HTML.new().sanitize(embed_code)
    return embed_code
  end
  
  def supported_services
    %w(www.youtube.com youtube.com documents.scribd.com www.viddler.com viddler.com www.veoh.com veoh.com
        www.vimeo.com vimeo.com video.google.com static.slideshare.net www.musicplaylist.us musicplaylist.us )
  end
  
private

  def src_path_valid?(code)
    embed_tag = code.at("embed")
    return false if embed_tag.nil? or embed_tag['src'].empty?
    return true
  end
  
  def src_path_supported?(code)
    for service in supported_services
      return true if string_starts_with?(code.at("embed")["src"], "http://#{service}/")
    end
    return false
  end
  
  def limit_width_and_height(code, height, width)
    embed_tag = code.at("embed")
    object_tag = code.at("object")
    
    unless height.nil?
      embed_tag['height'] = height if embed_tag['height'].to_i > height.to_i
      object_tag['height'] = height if not object_tag.nil? and object_tag['height'].to_i > height.to_i
    end
    
    unless width.nil?
      embed_tag['width'] = width if embed_tag['width'].to_i > width.to_i
      object_tag['width'] = width if not object_tag.nil? and object_tag['width'].to_i > width.to_i
    end

    code.to_html
  end
  
  def string_starts_with?(string, prefix)
    prefix = prefix.to_s
    string[0, prefix.length] == prefix
  end

end