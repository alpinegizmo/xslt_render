$test_root=File.expand_path File.dirname(__FILE__)
require 'rubygems'
require 'mocha'

class TestTermLanguage < Test::Unit::TestCase
  def use_test_translations(lang=:en)
    TermLanguage.any_instance.
      stubs(:translation_file).
      returns($test_root + "/i18n/translation.#{lang}.xml")
  end
  
  def test_translation_file
    TermLanguage.any_instance.stubs(:get_translations)
    
    en = TermLanguage.new(:en)

    file_path = en.translation_file
    assert_equal(Pathname(RAILS_ROOT)+'public'+'xslts'+'i18n'+'normal.en.xml', 
                 file_path)
  end
  
  def test_translate_in_english
    use_test_translations(:en)
    en = TermLanguage.new(:en)
    assert_equal "hello", en.translate('HELLO')
  end
  
  def test_translate_in_spanish
    use_test_translations(:es)
    es = TermLanguage.new(:es)
    assert_equal "hola", es.translate('HELLO')
  end
  

  def test_translate_with_missing_term
    use_test_translations(:en)
    en = TermLanguage.new(:en)
    assert_equal "BINGO", en.translate('BINGO')
  end
  
  def test_square_brace_alias_works
    use_test_translations(:en)
    en = TermLanguage.new(:en)
    assert_equal "goodbye", en['GOODBYE']
  end
end
