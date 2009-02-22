require 'open3'
require 'pathname'
require 'rubygems'
require 'xml_serialization'

class XsltprocError < StandardError; end

module XSLTRender
  attr_writer :xslt_root_dir

  def instance_hash
    hash = instance_variables.inject({}) do |vars, var|
      key = var[1..-1]

      # don't include "hidden" vars
      value = instance_variable_get(var)
      vars[key] = value unless '_' == key[0..0] or value.nil?
      vars
    end
    # don't allow param keys that are not valid as XML tag names
    hash['params'] = params.dup.delete_if {|(k,v)| k.to_s !~ /^[a-zA-Z][\w]*$/}
    hash['flash'] = flash
    hash['url_root'] = request.relative_url_root unless request.relative_url_root.blank?
    hash['environment'] = RAILS_ENV
    hash['default_javascripts'] = ActionView::Helpers::AssetTagHelper::JAVASCRIPT_DEFAULT_SOURCES
    hash['timestamp'] = "#{Time.now.to_i}#{Time.now.tv_usec}"
    hash['host'] = request.host
    hash['request_uri'] = request.request_uri
    hash
  end

  def page_xml(options={})
    start = Time.now
    options = {:root => 'page'}.merge options
    vars = instance_hash
    xml = vars.to_xml(:language => options[:language], :root => options[:root])
    logger.info "XSLTRender.page_xml: #{Time.now - start}sec"
    xml
  end

  def default_xslt_template
    (Pathname.new(self.class.controller_name)+action_name).to_s
  end

  def xslt_root_dir=(value)
    Pathname.new(value.to_s) unless value.kind_of? Pathname
  end

  # We put the xslt stylesheets in public so we could experiment
  # with having the browser perform the xsl transformations.
  def xslt_root_dir
    @xslt_root_dir ||= Pathname.new(RAILS_ROOT)+'public'+'xslts'
  end

  XSLTPROC_ERRORS = {
    1 => "No argument",
    2 => "Too many parameters",
    3 => "Unknown option",
    4 => "Failed to parse the stylesheet",
    5 => "Error in the stylesheet",
    6 => "Error in one of the documents",
    7 => "Unsupported xsl:output method",
    8 => "String parameter contains both quote and double-quotes",
    9 => "Internal processing error",
    10 => "Processing was stopped by a terminating message",
    11 => "Could not write the result to the output file",
  }

  def html_from_xml(xslt_file_name, xml, params = nil)
    params ||= {}
    cmd_params = params.map do |k,v|
      "--stringparam '#{k}' '#{v}'"
    end.join(' ')
    
    xslt_cmd_string = %Q{xsltproc #{cmd_params} #{xslt_file_name} -; echo "::$?" 1>&2}
    xslt_cmd = {}

    # scope out variables that will be used outside the 'cd'
    result = errors = error_code = nil

    Open3.popen3(xslt_cmd_string) do |xslt_cmd[:in], xslt_cmd[:out], xslt_cmd[:error]|
      begin
        xslt_cmd[:in].write xml
      rescue Errno::EPIPE
      else
        xslt_cmd[:in].close
        result = xslt_cmd[:out].read
      end

      errors, error_code_string = xslt_cmd[:error].read.match(/\A(.*)\s*::(\d+)\s*\z/m).captures
      error_code = error_code_string.to_i
    end

    unless 0 == error_code
      raise XsltprocError, "xsltproc processing of '#{xslt_file_name}' failed: #{XSLTPROC_ERRORS[error_code]} (#{error_code})\n#{errors}"
    end
    result
  end
  
  def xslt_render(options = {})
    options = {:root => 'page'}.merge(options)
    template = options[:template] || default_xslt_template

    full_template_path = nil
    ["", ".xsl", ".html.xsl"].each do |ext|
      if(full_path = (xslt_root_dir+(template + ext))).exist?
        full_template_path = full_path
      end
    end

    raise IOError, "XSLT template '#{template}' is missing" unless full_template_path
    
    xml = options[:xml] || page_xml(options)
    html = html_from_xml(full_template_path, xml, options[:params])
    
    if options[:language]
      plugin_root = (Pathname.new(__FILE__).dirname + '..').expand_path
      term_path = TermLanguage.new(options[:language]).translation_file
      i18n_path = plugin_root+'lib'+'xslts'+'i18n.xsl'
      html = html_from_xml(i18n_path, html, 'termfile' => term_path)
    end
    render :text => html
  end
end
