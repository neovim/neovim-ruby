module Neovim
  class Client
    def initialize(address)
      address, port = address.split(":")
      @stream = Stream.new(address, port)
      @req_id = 0
    end

    # Displays the message {msg}.
    def message(msg)
      rpc_response(36, msg)
    end

    # Sets a vim option. {option} can be any argument that the ":set" command
    # accepts. Note that this means that no spaces are allowed in the argument!
    def set_option(option)
      rpc_response(34, option)
    end

    # Executes Ex command {cmd}.
    def command(cmd)
      rpc_response(22, cmd)
    end

    # Evaluates {expr} using the vim internal expression evaluator. Returns the
    # expression result as a string.
    # A List is turned into a string by joining the items and inserting line
    # breaks.
    def evaluate(expr)
      rpc_response(23, expr)
    end

    private

    def rpc_response(func_id, *args)
      data = [0, @req_id += 1, func_id, args]
      RPC.new(data, @stream).response[3]
    end
  end
end
