require File.dirname(__FILE__) + '/spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../lib/aqueduct')

describe "Aqueduct::CSS" do
  
  before(:each) do
    @parser = Aqueduct::CSS.new(:append => '#network_xyz', :formatted => false)
  end
  
  it "Parse property with multiple value properly" do
    input = ".bar { margin: 0 50px 0 20px; }"
    @parser.sanitize(input).should == "#network_xyz .bar { margin: 0 50px 0 20px; }"
  end
  
  it "Main HTML elements should be removed (e.g. body)" do
    input = "body { background-color: green; font-size: 10; }"
    @parser.sanitize(input).should == "body { /* Don't do this */ }"
  end
  
  it "Only remove bad selectors (e.g. body) if grouped together other good ones" do
    input = "body, html, p { background-color: green; }"
    @parser.sanitize(input).should == "#network_xyz p { background-color: green; }"
  end
  
  it "HTML elements (e.g. p) should be scoped to sandbox id" do
    input = "p { margin: 0; }"
    @parser.sanitize(input).should == "#network_xyz p { margin: 0; }"
  end
  
  it "ID (eg #foo) should be scoped and prepend sandbox id" do
    input = "#foo { margin: 0; }"
    @parser.sanitize(input).should == "#network_xyz #network_xyz_foo { margin: 0; }"
  end
  
  it "CSS Classes (e.g. .bar) should be scoped to sandbox id" do
    input = ".bar { margin: 0; }"
    @parser.sanitize(input).should == "#network_xyz .bar { margin: 0; }"
  end
  
  it "Remove CSS import" do
    input = '@import url("foo.css")'
    @parser.sanitize(input).should be_empty
  end
  
  it "Remove z-index higher than or equal to 200" do
    input = '.content { z-index: 200; } .page { z-index: 300; }'
    @parser.sanitize(input).should == "#network_xyz .content { /* z-index: 200; - Don't do this */ }#network_xyz .page { /* z-index: 300; - Don't do this */ }"
  end
  
  it "Strip Javascript code in CSS" do
    input = '.evil { background-image: url(javascript:alert("Wazaap!!"));}'
    @parser.sanitize(input).should == "#network_xyz .evil { /* background-image: url(javascript:alert(\"Wazaap!!\"); - Don't do this */ }"
  end
  
  it "Strip Javascript (.js) in url()" do
     input = '.jspower { background-image: url("hack.js");}'
     @parser.sanitize(input).should == "#network_xyz .jspower { /* background-image: url(\"hack.js\"); - Don't do this */ }"
   end
  
  it "Strip XML mozilla bindings" do
    input = '.moz { -moz-binding: url(example_2.xml#redirect); }'
    @parser.sanitize(input).include?(".xml").should be_false
  end
  
end
