ENV.delete("VIM")
ENV.delete("VIMRUNTIME")

require "helper"
require "json"
require "net/http"
require "open-uri"
require "tempfile"

RSpec.describe "integration tests", :timeout => 5 do
  let(:root) { File.expand_path("../integration", __FILE__) }
  let(:init) { File.join(root, "runtime/init.vim") }
  let(:manifest) { File.join(root, "runtime/rplugin.vim") }

  around do |spec|
    Dir.chdir(root) { spec.run }
  end

  describe ":ruby" do
    specify "vader specs" do
      run_vader("ruby_spec.vim") do |status, output|
        expect(status).to be_success, lambda { output.read }
      end
    end

    ["vim", "buffer", "window"].each do |object|
      specify "ruby-#{object}" do
        run_rspec("+ruby load('ruby_#{object}_spec.rb')") do |status, output|
          expect(status).to be_success, lambda { output.read }
        end
      end
    end
  end

  describe ":rubyfile" do
    specify "vader specs" do
      run_vader("rubyfile_spec.vim") do |status, output|
        expect(status).to be_success, lambda { output.read }
      end
    end

    ["vim", "buffer", "window"].each do |object|
      specify "ruby-#{object}" do
        run_rspec("+rubyfile ruby_#{object}_spec.rb") do |status, output|
          expect(status).to be_success, lambda { output.read }
        end
      end
    end
  end

  describe ":rubydo" do
    specify "vader specs" do
      run_vader("rubydo_spec.vim") do |status, output|
        expect(status).to be_success, lambda { output.read }
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
          expect(status).to be_success, lambda { output.read }
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
        {"NVIM_RUBY_LOG_FILE" => "/dev/stderr", "NVIM_RPLUGIN_MANIFEST" => manifest, "VADER_OUTPUT_FILE" => out.path},
        "-c", "Vader! #{test_path}"
      )

      yield $?, out
    end
  end
end
