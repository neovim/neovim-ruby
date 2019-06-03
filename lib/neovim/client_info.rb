require "neovim/version"

module Neovim
  # @api private
  class ClientInfo
    HOST_METHOD_SPEC = {poll: {}, specs: {nargs: 1}}.freeze

    ATTRIBUTES = {
      website: "https://github.com/neovim/neovim-ruby",
      license: "MIT"
    }.freeze

    def self.for_host(host)
      name = host.plugins.map(&:script_host?) == [true] ?
        "ruby-script-host" :
        "ruby-rplugin-host"

      new(name, :host, HOST_METHOD_SPEC, ATTRIBUTES)
    end

    def self.for_client
      new("ruby-client", :remote, {}, ATTRIBUTES)
    end

    def initialize(name, type, method_spec, attributes)
      @name = name
      @type = type
      @method_spec = method_spec
      @attributes = attributes

      @version = ["major", "minor", "patch"]
        .zip(Neovim::VERSION.segments)
        .to_h
    end

    def to_args
      [
        @name,
        @version,
        @type,
        @method_spec,
        @attributes
      ]
    end
  end
end
