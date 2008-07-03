require File.dirname(__FILE__) + '/spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../lib/aqueduct')

describe "Aqueduct::Embed" do
  
  it "Raises EmbedSrcMissingOrInvalid exception if embed code is bad" do
    input = "rubbish"
    options = {}
    lambda { Aqueduct::Embed.new(input, options).sanitize }.should raise_error(Aqueduct::Embed::EmbedSrcMissingOrInvalid)
  end
  
end
