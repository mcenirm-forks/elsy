require 'turnip/rspec'
require 'tmpdir'

RSpec.configure do |config|
  Dir.glob("smoketest/steps/**/*_steps.rb") { |f| load f, true }
  config.before do
    @dir = Dir.mktmpdir("project-lifecycle-smoketest")
  end
  config.after do
    FileUtils.rm_rf(@dir)
  end
  config.after(:teardown => true) do
    Dir.chdir(@dir) do
      %x{lc teardown -f 2>&1}
    end
  end
end

# add `lc` to our path
require 'fileutils'
FileUtils.ln_s("/opt/project/target/lc-linux-amd64", "/usr/local/bin/lc")
