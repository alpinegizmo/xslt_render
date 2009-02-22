$test_root = File.expand_path File.dirname(__FILE__)
require $test_root + '/xslt_test_helper'
require 'xslt_render'
require 'rubygems'
require 'mocha'
require 'tempfile' 
require 'ostruct'

class MockLogger
  def info(*args)
    # don't do anything
  end
  
  alias warn info
  alias debug info
end

class MockController
  include XSLTRender

  attr_accessor :action_name
  attr_accessor :controller_name
  attr_accessor :response

  def self.controller_name
    'mock'
  end

  def params
    {'spa' => nil}; 
  end

  def flash; end
        
  def request
    OpenStruct.new(:relative_url_root => '')
  end

  def initialize(values={})
    values.each {|k,v| instance_variable_set("@#{k}", v)}

    @response = OpenStruct.new
    @xslt_root_dir = Pathname.new($test_root)
  end

  def render(options)
    if options and options.kind_of? Hash and options[:text]
      @response.body = options[:text]
    end
  end
  
  def logger(*args)
    MockLogger.new
  end
end

class XSLTRenderTest < Test::Unit::TestCase
  include XSLTRender
  
  def use_test_translations(lang=:en)
    TermLanguage.any_instance.
      stubs(:translation_file).
      returns($test_root + "/i18n/normal.#{lang}.xml")
  end
  
  def test_instance_hash
    controller = MockController.new

    controller.instance_eval do
      @a = 'A'
      @b = 'B'
    end

    assert_equal 'A', controller.instance_hash['a']
    assert_equal 'B', controller.instance_hash['b']
  end

  def test_default_xslt_template
    controller = MockController.new(:action_name => 'test_action')

    assert_equal 'mock/test_action', controller.default_xslt_template
  end

  def test_page_xml
    controller = MockController.new

    controller.instance_eval do
      @a = 'A'
      @b = 42
    end

    dom = REXML::Document.new(xml = controller.page_xml(:root => 'page'))
    assert top = dom.elements['/page'], "<page/> not in #{xml}"
    assert a_node = dom.elements['/page/a'], "<a/> not in '#{xml}'"
    assert_equal 'A', a_node.text, "'A' not in #{a_node.to_s}"
    assert b_node = dom.elements['/page/b'], "<b/> not in '#{xml}'"
    assert_equal '42', b_node.text, "'42' not in #{b_node.to_s}"
  end

  def test_page_xml_with_alternate_root
    controller = MockController.new

    controller.instance_eval do
      @a = 'A'
      @b = 'B'
    end

    dom = REXML::Document.new(xml = controller.page_xml(:root => "test"))
    assert top = dom.elements['/test'], "<test/> not in #{xml}"
    assert a_node = dom.elements['/test/a'], "<a/> not in '#{xml}'"
    assert_equal 'A', a_node.text, "'A' not in #{a_node.to_s}"
    assert b_node = dom.elements['/test/b'], "<b/> not in '#{xml}'"
    assert_equal 'B', b_node.text, "'B' not in #{b_node.to_s}"
  end


  def test_xslt_render
    controller = MockController.new(:action_name => 'test_action')

    controller.instance_eval do
      @some_interesting_value = 'interesting value'
    end

    controller.xslt_render

    assert_xml_tag controller.response.body, :tag => 'dt', :content => 'some-interesting-value'
    assert_xml_tag controller.response.body, :tag => 'dd/dl/dt', :content => 'interesting value'

    controller = MockController.new(:action_name => 'test_action')
    controller.instance_eval do
      @some_other_value = 'other value'
    end

    controller.xslt_render

    assert_xml_tag controller.response.body, :tag => 'dt', :content => 'some-other-value'
    assert_xml_tag controller.response.body, :tag => 'dd/dl/dt', :content => 'other value'
  end
  
  def test_xslt_render_with_translation
    controller = MockController.new(:action_name => 'test_translation')
    use_test_translations

    controller.xslt_render :language => 'en'

    assert_match /Hello.*and.*English/, controller.response.body
  end

  def test_xslt_render_with_params
    controller = MockController.new(:action_name => 'test_action')
    use_test_translations

    controller.xslt_render :language => 'en', :params => {:title => 'my page'}

    assert_xml_tag controller.response.body, :tag => 'title', :content => 'my page'
  end
  
  def test_xslt_render_with_alternate_root
    controller = MockController.new(:action_name => 'test_action')

    controller.instance_eval do
      @some_interesting_value = 'interesting value'
    end

    controller.xslt_render(:root => 'test')

    assert_xml_tag controller.response.body, :tag => 'dt', :content => 'test'
  end

  def test_xslt_render_with_alternate_template
    controller = MockController.new(:action_name => 'other_action')

    controller.instance_eval do
      @some_interesting_value = 'interesting value'
    end

    controller.xslt_render(:template => 'mock/test_action')

    assert_xml_tag controller.response.body, :tag => 'dt', :content => 'page'
  end

  def test_render_throws_exception_for_missing_xslt
    controller = MockController.new(:action_name => 'missing_action')

    controller.instance_eval {@some_var = 'some val'}

    assert_raises IOError do
      controller.xslt_render
    end
  end

  def test_render_raise_with_erroneous_action
    controller = MockController.new(:action_name => 'erroneous_action')

    controller.instance_eval {@some_var = 'some val'}

    assert_raises XsltprocError do
      controller.xslt_render
    end
  end
  
  def test_html_from_xml_does_correct_transformation_and_uses_default_param
    xml = '<some-interesting-value>interesting value</some-interesting-value>'
    html = html_from_xml($test_root + '/mock/test_action.html.xsl', xml)
    assert_xml_tag html, :tag => 'dt', :content => 'some-interesting-value'
    assert_xml_tag html, :tag => 'dd/dl/dt', :content => 'interesting value'
    assert_xml_tag html, :tag => 'title', :content => 'default'
  end
  
  def test_html_from_xml_sees_supplied_parameter
    xml = '<some-interesting-value>interesting value</some-interesting-value>'
    html = html_from_xml($test_root + '/mock/test_action.html.xsl', xml, 'title' => "a big deal")
    assert_xml_tag html, :tag => 'dt', :content => 'some-interesting-value'
    assert_xml_tag html, :tag => 'dd/dl/dt', :content => 'interesting value'
    assert_xml_tag html, :tag => 'title', :content => 'a big deal'
  end
end
