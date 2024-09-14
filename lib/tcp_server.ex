# lib/tcp_server.ex
defmodule TcpServer do
  require Logger
  use GenServer

  @port 2106
  @initial_bytes <<0x00, 0x9c, 0x77, 0xed, 0x03, 0x5a, 0x78, 0x00, 0x00>>

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:ok, listen_socket} = :gen_tcp.listen(@port, [:binary, :inet, active: false, reuseaddr: true])
    IO.puts("Server listening on port #{@port}...")
    {:ok, %{listen_socket: listen_socket}, {:continue, :accept}}
  end

  def handle_continue(:accept, state) do
    {:ok, client_socket} = :gen_tcp.accept(state.listen_socket)
    spawn(fn -> send_init_and_handle_client(client_socket) end)
    {:noreply, state, {:continue, :accept}}
  end

  defp send_init_and_handle_client(socket) do
    IO.puts("New client, sending init packet")

    # Construct the packet with header
    header_length = 2
    packet_length = byte_size(@initial_bytes) + header_length
    header = <<packet_length::16-little>>
    packet = header <> @initial_bytes

    # Send the packet to the newly connected client
    :ok = :gen_tcp.send(socket, packet)

    IO.puts("Init packet sent")

    read_and_try_handling_packet(socket, <<>>)
  end

  defp read_and_try_handling_packet(socket, buf) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        IO.puts("Received, time to start handling packets")
        try_handing_packet(socket, buf <> data)

      {:error, reason} ->
        IO.puts("Error occurred: #{inspect(reason)}")
        :gen_tcp.close(socket)
        IO.puts("Client disconnected.")
    end
  end

  defp try_handing_packet(socket, buf) do
    <<size :: 16-little, rest :: binary>> = buf
    if size > byte_size(buf) do
      IO.puts("Not enough data... waiting for more data")
      read_and_try_handling_packet(socket, buf)
    else
      IO.puts("All good, handling packet!")
      handle_packet(socket, buf)
    end
  end

  defp handle_packet(socket, buf) do
    <<size :: 16-little, packet :: binary>> = buf

    IO.puts("all data is")
    IO.inspect(buf)

    IO.puts("size is")
    IO.puts(size)

    # packet_big_endian = BinToInt.from_little_to_big(packet)
    packet_big_endian = packet

    # key = "[;'.]94-31==-%&@!^+]\000"
    # key = <<0x5b,0x3b,0x27,0x2e,0x5d,0x39,0x34,0x2d,0x33,0x31,0x3d,0x3d,0x2d,0x25,0x26,0x40,0x21,0x5e,0x2b,0x5d>>
    key = "[;'.]94-31==-%&@!^+]\000"
    decrypted_packet_big_endian = Blowfish.decrypt(key, packet_big_endian)
    # decrypted_packet = BinToInt.from_big_to_little(decrypted_packet_big_endian)
    decrypted_packet = decrypted_packet_big_endian

    IO.puts("decrypted is")
    IO.inspect(decrypted_packet)

    <<packet_type :: 8, body :: binary>> = decrypted_packet

    IO.puts("packet is")
    IO.puts(packet_type)

    # <<login :: binary-size(14), password :: binary-size(16)>> = body


    # IO.puts("login")
    # IO.puts(login)

    # IO.puts("password")
    # IO.puts(password)

    # Handle the rest of the packet
    read_and_try_handling_packet(socket, discard_first_n_bytes(buf, size))
  end



  defp discard_first_n_bytes(binary, n) do
    # Ensure that n is not greater than the size of the binary
    if n <= byte_size(binary) do
      binary_part(binary, n, byte_size(binary) - n)
    else
      # Handle the case where n is greater than the binary size
      <<>>  # Return an empty binary if n exceeds the binary size
    end
  end
end
