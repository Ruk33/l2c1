# lib/l2c1.ex
defmodule L2c1.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Starts the TCP server
      TcpServer
    ]

    opts = [strategy: :one_for_one, name: L2c1.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
