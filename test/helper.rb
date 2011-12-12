require 'rubygems'
require 'bundler'
Bundler.setup

require 'minitest/spec'

require 'ragelink'

MiniTest::Unit.autorun

class ConformanceFixture
  def initialize(name)
    @name = name
  end

  def specs
    @specs ||= load_specs(file_name)
  end

  def url_specs
    specs['tests']['urls']
  end

  def email_specs
    specs['tests']['urls']
  end

  def skips
    @skips ||= load_specs(skip_file_name)
  end

  def url_skips
    return @url_skips if @url_skips
    @url_skips = skips['tests']['urls'].inject({}) do |map, spec|
      map[spec['description']] = spec
      map
    end
  end

  def skip_url_spec?(spec_description)
    url_skips.keys.include?(spec_description)
  end

  private
  def load_specs(file)
    YAML.load(File.read(file))
  end

  def file_name
    File.join(File.dirname(__FILE__), 'fixtures', "#{@name}.yml")
  end

  def skip_file_name
    File.join(File.dirname(__FILE__), 'fixtures', "#{@name}_skips.yml")
  end

end
