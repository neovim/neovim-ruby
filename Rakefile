require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  desc "Build Neovim and run specs on CI"
  task :ci => ["neovim:build", :spec]
end

namespace :neovim do
  vendor = File.expand_path("../vendor/neovim", __FILE__)

  desc "Build Neovim"
  task :build do
    sh "git submodule update --init && " +
       "cd #{vendor} && " +
       "make distclean && " +
       "make"

    Rake::Task["neovim:generate_docs"].invoke
  end

  desc "Update vendored Neovim revision"
  task :update do
    sh "git submodule update --init && " +
       "cd #{vendor} && " +
       "make distclean && " +
       "git pull origin master && " +
       "make"

    Rake::Task["neovim:generate_docs"].invoke
  end

  desc "Generate Neovim remote API docs"
  task :generate_docs do
    require "neovim"
    require "pathname"

    vim_docs = []
    buffer_docs = []
    window_docs = []
    tabpage_docs = []
    session = Neovim::Session.child(%w(-u NONE -n -N))

    session.request(:vim_get_api_info)[1]["functions"].each do |func|
      prefix, method_name = func["name"].split("_", 2)
      return_type = func["return_type"]
      params = func["parameters"]
      params.shift unless prefix == "vim"
      param_names = params.map(&:last)
      param_str = params.empty? ? "" : "(#{param_names.join(", ")})"
      method_decl = "@!method #{method_name}#{param_str}"
      param_docs = params.map do |type, name|
        "  @param [#{type}] #{name}"
      end
      return_doc = "  @return [#{return_type}]\n"
      method_doc = [method_decl, *param_docs, return_doc].join("\n")
      method_doc.gsub!(/ArrayOf\((\w+)[^)]*\)/, 'Array<\1>')
      method_doc.gsub!(/Integer/, "Fixnum")

      case prefix
      when "vim"
        vim_docs << method_doc
      when "buffer"
        buffer_docs << method_doc
      when "tabpage"
        tabpage_docs << method_doc
      when "window"
        window_docs << method_doc
      end

      lib_dir = Pathname.new(File.expand_path("../lib/neovim", __FILE__))
      {
        "client.rb" => vim_docs,
        "buffer.rb" => buffer_docs,
        "tabpage.rb" => tabpage_docs,
        "window.rb" => window_docs,
      }.each do |filename, docs|
        path = lib_dir.join(filename)
        contents = File.read(path)
        doc_str = ["=begin", *docs, "=end"].join("\n")

        File.write(path, contents.sub(/=begin.+=end/m, doc_str))
      end
    end
  end
end

task :default => :spec
