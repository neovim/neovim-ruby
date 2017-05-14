ENV.delete("VIM")
ENV.delete("VIMRUNTIME")

require "helper"

RSpec.describe "acceptance tests", :timeout => 30 do
  describe "vim compatibility" do
    ["ruby", "rubyfile", "rubydo"].each do |ex_cmd|
      specify ":#{ex_cmd}" do
        run_spec("#{ex_cmd}_spec.vim") do |status, output|
          expect(status.success?).to be(true), lambda { output.read }
        end
      end
    end
  end

  describe "remote plugin DSL" do
    ["command", "function", "autocmd"].each do |feature|
      specify "##{feature}" do
        run_spec("rplugin_#{feature}_spec.vim") do |status, output|
          expect(status.success?).to be(true), lambda { output.read }
        end
      end
    end
  end

  def run_nvim(env, vimrc, *opts)
    system(env, Neovim.executable.path, "--headless", "-n", "-u", vimrc, *opts)
  end

  def run_spec(test_path)
    root = File.expand_path("../acceptance", __FILE__)
    vimrc = File.join(root, "runtime/init.vim")
    manifest = File.join(root, "runtime/rplugin.vim")
    test_path = File.join(root, test_path)

    Dir.chdir(root) do
      Tempfile.open("vader.out") do |out|
        run_nvim(
          {"NVIM_RPLUGIN_MANIFEST" => manifest},
          vimrc,
          "-c", "silent UpdateRemotePlugins", "-c", "qa!"
        )

        run_nvim(
          {"NVIM_RPLUGIN_MANIFEST" => manifest, "VADER_OUTPUT_FILE" => out.path},
          vimrc,
          "-c", "Vader! #{test_path}"
        )

        yield $?, out
      end
    end
  end
end
