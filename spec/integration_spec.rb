ENV.delete("VIM")
ENV.delete("VIMRUNTIME")

require "helper"
require "json"
require "net/http"
require "open-uri"

RSpec.describe "integration tests", :timeout => 30 do
  let(:root) { File.expand_path("../integration", __FILE__) }
  let(:init) { File.join(root, "runtime/init.vim") }
  let(:manifest) { File.join(root, "runtime/rplugin.vim") }

  around do |spec|
    Dir.chdir(root) { spec.run }
  end

  ["vim", "buffer", "window"].each do |object|
    describe "ruby_#{object}" do
      specify ":ruby invocation" do
        run_rspec("+ruby load('ruby_#{object}_spec.rb')") do |status, output|
          expect($?).to be_success, lambda { output.read }
        end
      end

      specify ":rubyfile invocation" do
        run_rspec("+rubyfile ruby_#{object}_spec.rb") do |status, output|
          expect($?).to be_success, lambda { output.read }
        end
      end
    end
  end

  ["ruby", "rubyfile", "rubydo"].each do |ex_cmd|
    specify ":#{ex_cmd}" do
      run_vader("#{ex_cmd}_spec.vim") do |status, output|
        expect(status.success?).to be(true), lambda { output.read }
      end
    end
  end

  describe "remote plugin DSL" do
    before do
      run_nvim(
        {"NVIM_RPLUGIN_MANIFEST" => manifest},
        "-c", "silent UpdateRemotePlugins", "-c", "qa!"
      )
    end

    ["command", "function", "autocmd"].each do |feature|
      specify "##{feature}" do
        run_vader("rplugin_#{feature}_spec.vim") do |status, output|
          expect(status.success?).to be(true), lambda { output.read }
        end
      end
    end
  end

  specify "neovim-ruby has up-to-date generated method docs" do
    begin
      url = "https://api.github.com/repos/neovim/neovim/releases/latest"
      response = open(url) { |json| JSON.load(json) }

      client_file = File.read(
        File.expand_path("../../lib/neovim/client.rb", __FILE__)
      )
      docs_version = client_file[
        /The methods documented here were generated using (.+)$/,
        1
      ]

      expect(docs_version).to eq(response["name"])
    rescue SocketError, OpenURI::HTTPError => e
      skip "Skipping: #{e}"
    end
  end

  def run_nvim(env, *opts)
    system(env, Neovim.executable.path, "--headless", "-n", "-u", init, *opts)
  end

  def run_rspec(*args)
    Tempfile.open("rspec.out") do |out|
      run_nvim(
        {"NVIM_RPLUGIN_MANIFEST" => manifest, "RSPEC_OUTPUT_FILE" => out.path},
        *args, "+call RunSuite()"
      )

      yield $?, out
    end
  end

  def run_vader(test_path)
    Tempfile.open("vader.out") do |out|
      run_nvim(
        {"NVIM_RPLUGIN_MANIFEST" => manifest, "VADER_OUTPUT_FILE" => out.path},
        "-c", "Vader! #{test_path}"
      )

      yield $?, out
    end
  end
end
