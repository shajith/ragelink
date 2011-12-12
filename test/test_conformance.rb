require 'helper'

describe "Ragelink internal conformance suite" do
  conformance = ConformanceFixture.new('internal')
  conformance.url_specs.each do |spec|
    it "should #{spec['description']}" do
      assert_equal spec['expected'], Ragelink.autolink_ragel_urls(spec['text'])
    end
  end
end


describe "Twitter conformance suite" do
  $failing = []

  conformance = ConformanceFixture.new('twitter_conformance')
  conformance.url_specs.each do |spec|

    it "should #{spec['description']}" do
      skip("Skipping: #{spec['description']}") if conformance.skip_url_spec?(spec['description'])
      if spec['expected'] != Ragelink.autolink_ragel_urls(spec['text'])
        $failing << spec
        File.open('failing.yml', 'w') {|f| f.write(YAML.dump('tests' => {'urls' =>  $failing})) }
      end
      assert_equal spec['expected'], Ragelink.autolink_ragel_urls(spec['text'])
    end
  end
end
