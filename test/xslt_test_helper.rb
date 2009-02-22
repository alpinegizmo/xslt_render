$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
require 'rexml/document'
require 'xslt_render'
require 'activesupport'
require 'pathname'

RAILS_ENV = :test if not defined? RAILS_ENV
RAILS_ROOT = '.' if !defined? RAILS_ROOT
if not defined? ActionView::Helpers::AssetTagHelper::JAVASCRIPT_DEFAULT_SOURCES
  class ActionView
    class Helpers
      class AssetTagHelper
        JAVASCRIPT_DEFAULT_SOURCES = ''
      end
    end
  end
end

class String
  def blank?
    self !~ /\S/
  end
end

class Test::Unit::TestCase
  def assert_xml_tag(xml, conditions)
    doc = REXML::Document.new(xml)
    assert doc.elements[%Q{//#{conditions[:tag]}[text()="#{conditions[:content]}"]}],
      "expected tag, but no tag found matching #{conditions.inspect} in:\n#{xml.inspect}"
  end
end

module XSLTTestHelper
  include XSLTRender

  def html_from_xml_helper(xml, partial_template_text, 
                           base_template_filename = 
                             "#{RAILS_ROOT}/public/xslts/layouts/application.html.xsl")
                         
    include_text = base_template_filename ? %Q{<xsl:include href="#{base_template_filename}" />\n} : ""
    
    template_text = <<TEMPLATE
<?xml version="1.0" encoding="UTF-8"?>
  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    #{include_text}
    #{partial_template_text}
  </xsl:stylesheet>
TEMPLATE
    
    template_file = Tempfile.new('template.xsl')
    template_file.print(template_text)
    template_file.flush
    
    html_from_xml(template_file.path, xml).sub(/\A<\?[^>]*\?>\s*/m, '').sub(/\s*\z/m, '')
  end
end

class TermLanguage
  attr_reader :translations, :language, :controller_name
  
  def translation_base
    Pathname.new(RAILS_ROOT)+'public'+'xslts'+'i18n'
  end

  def translation_file
    translation_base+"normal.#{language}.xml"
  end
  
  def get_translations
    REXML::Document.new(File.open(translation_file, 'r') {|f| f.read})
  end
  
  def initialize(language_symbol)
    @language = language_symbol
    @translations = get_translations
  end
  
  def translate(term)
    if node = translations.elements["/terms/term[@name='#{term}']"]
      node.text
    else
      term
    end
  end
  
  alias [] translate
end