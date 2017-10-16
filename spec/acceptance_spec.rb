ENV.delete("VIM")
ENV.delete("VIMRUNTIME")

require "json"
require "net/http"
require "open-uri"
require "tempfile"

RSpec.describe "Acceptance", :timeout => 10 do
  let(:root) { File.expand_path("../acceptance", __FILE__) }
  let(:init) { File.join(root, "runtime/init.vim") }
  let(:manifest) { File.join(root, "runtime/rplugin.vim") }

  around do |spec|
    Dir.chdir(root) { spec.run }
  end

  describe ":ruby" do
    specify "vimscript specs" do
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
    specify "vimscript specs" do
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
    specify "vimscript specs" do
      run_vader("rubydo_spec.vim") do |status, output|
        expect(status).to be_success, lambda { output.read }
      end
    end
  end

  describe "Neovim.plugin DSL" do
    before do
      run_nvim(
        {"NVIM_RPLUGIN_MANIFEST" => manifest},
        "-c", "silent UpdateRemotePlugins", "-c", "qa!"
      )
    end

    ["command", "function", "autocmd"].each do |feature|
      specify feature do
        run_vader("rplugin_#{feature}_spec.vim") do |status, output|
          expect(status).to be_success, lambda { output.read }
        end
      end
    end
  end

  specify "up-to-date generated method docs" do
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
    nvim = env.fetch("NVIM_EXECUTABLE", "nvim")
    system(env, nvim, "--headless", "-n", "-u", init, *opts)
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
