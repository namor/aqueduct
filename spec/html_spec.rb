require File.dirname(__FILE__) + '/spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../lib/aqueduct')

describe "Aqueduct::HTML" do
  
  before(:each) do
    @parser = Aqueduct::HTML.new(:append => 'network_xyz', :formatted => false)
  end

# Valid HTML - Invalid Content
  
  it "Only output content inside of <body> tags" do
    input = "<html><head></head><body>Works</body></html>"
    @parser.sanitize(input).should == "Works"
  end
  
  it "Remove inline styling" do
    input = '<span style="color:red">RED</span>'
    @parser.sanitize(input).should == "<span>RED</span>"
  end
  
  it "Remove javascript events" do
    input = '<a href="#" onclick="alert(\'Yippee\');">Click Me</a>'
    @parser.sanitize(input).should == '<a href="#">Click Me</a>'
  end
  
  it "Remove javascript in img src" do
    input = '<img src="javascript:alert(\'3viL\');" alt="cow" />'
    @parser.sanitize(input).should == '<img alt="cow" />'
  end
  
  it "Remove javascript in img dynsrc" do
    input = '<img dynsrc="javascript:alert(\'3viL\');" alt="cow" />'
    @parser.sanitize(input).should == '<img alt="cow" />'
  end
  
  
  it "Remove javascript in img lowsrc" do
    input = '<img lowsrc="javascript:alert(\'3viL\');" alt="cow" />'
    @parser.sanitize(input).should == '<img alt="cow" />'
  end
  
  it "Remove javascript (encoded as UTF) in img src" do
    input = '<IMG SRC=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>'
    @parser.sanitize(input).should == '<img />'
  end
  
  it "Strip tags not allowed inside <body></body>" do
    input = "<body><html><head></head></html><meta></meta><base></base></body>"
    @parser.sanitize(input).should be_empty
  end
  
  it "Strip <script>" do
    input = "<body><script>alert('a');</script></body>"
    @parser.sanitize(input).should be_empty
  end
  
  it "Sandbox ids" do
    input = '<span id="king"></span>'
    @parser.sanitize(input).should == '<span id="network_xyz_king"></span>'
  end
  
  it "Run sandboxing seperately" do
    input = '<span id="king"></span>'
    @parser.sandbox(input, "pop").should == '<span id="pop_king"></span>'
  end


# Invalid HTML (Broken tags)

  it "Attack of the >" do
    input = '><script>var a = document.getElementById(\'header\'); a.style.display = \'none\';</script>'
    @parser.sanitize(input).should == ">"
  end
  
  it "Attack of many <  > //" do
    input = '<<SCRIPT>alert("XSS");//<</SCRIPT>'
    @parser.sanitize(input).should_not =~ /\<script\>/i
  end  
  
end
