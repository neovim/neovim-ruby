ENV.delete("VIM")
ENV.delete("VIMRUNTIME")

require "json"
require "net/http"
require "openssl"
require "open-uri"
require "tempfile"

RSpec.describe "Acceptance", timeout: 10 do
  let(:root) { File.expand_path("../acceptance", __FILE__) }
  let(:init) { File.join(root, "runtime/init.vim") }
  let(:manifest) { File.join(root, "runtime/rplugin.vim") }

  around do |spec|
    Dir.chdir(root) { spec.run }
  end

  describe "Vim compatibility" do
    ["ruby", "rubyfile", "rubydo"].each do |feature|
      specify ":#{feature}" do
        run_vader("#{feature}_spec.vim") do |status, output|
          expect(status).to be_success, -> { output.read }
        end
      end
    end
  end

  describe "Remote plugins" do
    before do
      run_nvim(
        {"NVIM_RPLUGIN_MANIFEST" => manifest},
        "-c", "silent UpdateRemotePlugins", "-c", "qa!"
      )
    end

    ["command", "function", "autocmd"].each do |feature|
      specify "##{feature}" do
        run_vader("rplugin_#{feature}_spec.vim") do |status, output|
          expect(status).to be_success, -> { output.read }
        end
      end
    end
  end

  describe "Generated documentation", timeout: 120 do
    it "is up to date" do
      url = "https://api.github.com/repos/neovim/neovim/releases/latest"
      retries = 5.times.lazy.map { sleep 5 }

      begin
        response = open(url) { |json| JSON.load(json) }
      rescue SocketError, OpenURI::HTTPError, OpenSSL::SSL::SSLError => e
        warn "#{e} (retrying)"; retries.next; retry
      rescue StopIteration
        fail "Couldn't determine latest neovim release from Github"
      end

      release_version = response["name"][/NVIM v?(.+)$/, 1]

      client_file = File.read(
        File.expand_path("../../lib/neovim/client.rb", __FILE__)
      )
      docs_version = client_file[
        /The methods documented here were generated using NVIM v?(.+)$/,
        1
      ]

      expect(docs_version).to eq(release_version)
    end
  end

  def run_nvim(env, *opts)
    nvim = env.fetch("NVIM_EXECUTABLE", "nvim")
    system(env, nvim, "--headless", "-n", "-u", init, *opts)
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
