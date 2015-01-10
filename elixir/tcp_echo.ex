defmodule Networking do
	def start(port) do
    tcp_options = [:binary, {:packet, 0}, {:active, false}]
    {:ok, socket} = :gen_tcp.listen(port, tcp_options)
		new_peer(socket)
	end
	defp connect(host, port) do
		{:ok, s} = :gen_tcp.connect(:erlang.binary_to_list(host), port, [{:active, false}, {:packet, 0}])
		s
	end
	defp new_peer(socket) do
    {:ok, conn} = :gen_tcp.accept(socket)
    spawn(fn -> done_listening?(conn, "") end)
    new_peer(socket)		
	end
	defp ms(socket, string) do
		:ok = :gen_tcp.send(socket, string<>"_")
	end
	def talk(host, port, msg) do
		s=connect(host, port)
		ms(s, msg)
		done_listening?(s, "")
	end
	def ping(host, port) do
		s=connect(host, port)
		ms(s, "ping")
	end
	defp done_listening?(conn, data) do
		ds=String.length(data)
		lc=String.slice(data, ds-1, ds)
		cond do
			lc == "_" -> 
				ms(conn, String.slice(data, 0, ds-1))
			true -> listen(conn, data)
		end
	end
	defp listen(conn, data) do
		case :gen_tcp.recv(conn, 0) do
			{:ok, d} ->
				done_listening?(conn, data<>to_string(d))
			{:error, :closed} ->
				IO.puts "error"
		end
	end
end
