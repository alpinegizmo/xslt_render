$test_root=File.expand_path File.dirname(__FILE__)
require $test_root + '/xslt_test_helper'

class BuiltinTemplatesTest < Test::Unit::TestCase
  include XSLTTestHelper

  BUILTIN_XSL = Pathname($test_root)+'..'+'assets'+'xslt_helpers.xsl'

  def test_stylesheet_with_simple_sheetname
    xsl = <<-XSL
        <xsl:variable name="language">en</xsl:variable>
        <xsl:template match="test">
          <xsl:call-template name='stylesheet'>
            <xsl:with-param name="sheet">sheetname</xsl:with-param>
          </xsl:call-template>
        </xsl:template>
    XSL

    result = html_from_xml_helper('<test><url-root></url-root></test>', xsl, BUILTIN_XSL)
    assert_match %r{href="/stylesheets/sheetname.css"}, result
  end

  def test_stylesheet_with_url
    url = 'http://foo/bar.css'
    xsl = <<-XSL
        <xsl:variable name="language">en</xsl:variable>
        <xsl:template match="test"> 
          <xsl:call-template name='stylesheet'>
            <xsl:with-param name="sheet">#{url}</xsl:with-param>
          </xsl:call-template>
        </xsl:template>
    XSL

    result = html_from_xml_helper('<test><url-root></url-root></test>', xsl, BUILTIN_XSL)
    assert_match %r{href="#{url}"}, result
  end
  
  def test_uri_delete_param_at_beginning
    uri = "/controller/action?todelete=3&amp;keep=4"
    xsl = <<-XSL
    <xsl:template match="test">
      <xsl:call-template name="uri-delete-param">
        <xsl:with-param name="base-uri">#{uri}</xsl:with-param>
        <xsl:with-param name="param">todelete</xsl:with-param>
      </xsl:call-template>
    </xsl:template>
    XSL
    
    result = html_from_xml_helper('<test />', xsl, BUILTIN_XSL)
    assert_equal "/controller/action?keep=4", result
  end
  
  def test_uri_delete_param_in_middle
    uri = "/controller/action?keep1=1&amp;todelete=2&amp;keep2=3"
    xsl = <<-XSL
    <xsl:template match="test">
      <xsl:call-template name="uri-delete-param">
        <xsl:with-param name="base-uri">#{uri}</xsl:with-param>
        <xsl:with-param name="param">todelete</xsl:with-param>
      </xsl:call-template>
    </xsl:template>
    XSL
    
    result = html_from_xml_helper('<test />', xsl, BUILTIN_XSL)
    assert_equal "/controller/action?keep1=1&amp;keep2=3", result
  end  

  def test_uri_delete_param_at_end
    uri = "/controller/action?keep1=1&amp;todelete=2"
    xsl = <<-XSL
    <xsl:template match="test">
      <xsl:call-template name="uri-delete-param">
        <xsl:with-param name="base-uri">#{uri}</xsl:with-param>
        <xsl:with-param name="param">todelete</xsl:with-param>
      </xsl:call-template>
    </xsl:template>
    XSL
    
    result = html_from_xml_helper('<test />', xsl, BUILTIN_XSL)
    assert_equal "/controller/action?keep1=1", result
  end
  
  def test_uri_delete_param_if_only_param
    uri = "/controller/action?todelete=3"
    xsl = <<-XSL
    <xsl:template match="test">
      <xsl:call-template name="uri-delete-param">
        <xsl:with-param name="base-uri">#{uri}</xsl:with-param>
        <xsl:with-param name="param">todelete</xsl:with-param>
      </xsl:call-template>
    </xsl:template>
    XSL
    
    result = html_from_xml_helper('<test />', xsl, BUILTIN_XSL)
    assert_equal "/controller/action", result
  end
  
    def test_uri_delete_param_when_not_present
    uri = "/v/location_search?language=de&amp;sort=minrate&amp;location=malaga"
    xsl = <<-XSL
    <xsl:template match="test">
      <xsl:call-template name="uri-delete-param">
        <xsl:with-param name="base-uri">#{uri}</xsl:with-param>
        <xsl:with-param name="param">page</xsl:with-param>
      </xsl:call-template>
    </xsl:template>
    XSL
    
    result = html_from_xml_helper('<test />', xsl, BUILTIN_XSL)
    assert_equal uri, result
  end
end
