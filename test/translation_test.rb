$test_root=File.expand_path File.dirname(__FILE__)
require $test_root + '/xslt_test_helper'

class TestTermLanguage < Test::Unit::TestCase
  include XSLTRender

  HELLO = <<-END
<?xml version="1.0" encoding="UTF-8"?>
    <stuff xmlns:tr="http://www.hotelsearch.com/XMLSchema/2007/translation">
      <tr:term>HELLO</tr:term>
    </stuff>
  END

  HELLO_BEFORE_WORLD = <<-END
<?xml version="1.0" encoding="UTF-8"?>
    <stuff xmlns:tr="http://www.hotelsearch.com/XMLSchema/2007/translation">
      <tr:ordered before="HELLO">world</tr:ordered>
    </stuff>
  END

  HELLO_WORLD_GOODBYE = <<-END
<?xml version="1.0" encoding="UTF-8"?>
    <stuff xmlns:tr="http://www.hotelsearch.com/XMLSchema/2007/translation">
      <tr:ordered before="HELLO" after="GOODBYE">world</tr:ordered>
    </stuff>
  END

  NOT_PRESENT = <<-END
<?xml version="1.0" encoding="UTF-8"?>
    <stuff xmlns:tr="http://www.hotelsearch.com/XMLSchema/2007/translation">
      <tr:term>not present</tr:term>
    </stuff>
  END

  PASS_THRU = <<-END
<?xml version="1.0" encoding="UTF-8"?>
    <stuff xmlns:tr="http://www.hotelsearch.com/XMLSchema/2007/translation">
      <tr:term pass-thru="true">pass thru</tr:term>
    </stuff>
  END

  def setup
    @i18n = $test_root + '/../lib/xslts/i18n.xsl'
    @english = $test_root + '/i18n/translation.en.xml'
    @spanish = $test_root + '/i18n/translation.es.xml'
    @japanese = $test_root + '/i18n/translation.ja.xml'
  end

  def test_term_should_do_translation
    xlated = html_from_xml(@i18n, HELLO, 'termfile' => @english)
    assert_match /hello/, xlated
  end

  def test_term_should_not_pass_through_missing_terms_by_default
    xlated = html_from_xml(@i18n, NOT_PRESENT, 'termfile' => @english)
    assert_no_match /not present/, xlated
  end

  def test_term_should_pass_through_missing_terms
    xlated = html_from_xml(@i18n, PASS_THRU, 'termfile' => @english)
    assert_match /pass thru/, xlated
  end

  def test_order_defaults_to_left_to_right
    xlated = html_from_xml(@i18n, HELLO_BEFORE_WORLD, 'termfile' => @english)
    assert_match /hello world/, xlated
  end

  def test_before_and_after
    xlated = html_from_xml(@i18n, HELLO_WORLD_GOODBYE, 'termfile' => @english)
    assert_match /hello world goodbye/, xlated
  end

  def test_japanese_should_affect_order_and_spacing
    xlated = html_from_xml(@i18n, HELLO_BEFORE_WORLD, 'termfile' => @japanese)
    assert_match /worldhola/, xlated
  end
end
