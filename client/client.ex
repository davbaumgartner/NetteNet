defmodule Client do

	def start_client() do
		dest_ip = list_to_tuple(Enum.map((String.split (to_string (IO.gets "IP to connect to ? ")), "."), (fn (s) -> case String.to_integer s do { n, _ } -> n end end)))
		{ dest_port, _ } = String.to_integer (to_string (IO.gets "Which port ? "))
		start_client(dest_ip, dest_port)
	end

	def start_client(dest_ip, dest_port) do
		case :gen_udp.open(0) do 
			{ :ok, socket } ->
				Inform.ok "Started client on port #{inspect (case :inet.port(socket), do: ({ _, port } -> port))}."
				:random.seed(:erlang.now())
				session_token = :base64.encode(to_string :random.uniform(round 1.0e100))
				loop socket, session_token, dest_ip, dest_port
			_ -> 
				Inform.error "Failed."
				start_client dest_ip, dest_port
		end 
	end


	defp loop(socket, session_token, ip, port) do 
		ask = String.split (String.strip (to_string (IO.gets "> ")))
		case Enum.at ask, 0 do
			"load" ->
				send_wait_loop socket, session_token, ip, port, [cmd: "load", res: (Enum.at ask, 1), sessiontoken: session_token]
			"login" ->
				send_wait_loop socket, session_token, ip, port, [cmd: "login", username: (Enum.at ask, 1), password: (to_string (:hmac.hexlify :erlsha2.sha512((Enum.at ask, 2)))), sessiontoken: session_token]
			"gen_password" ->
				IO.puts (to_string (:hmac.hexlify :erlsha2.sha512((Enum.at ask, 1))))
				loop socket, session_token, ip, port
			"end" ->
				Inform.ok "Goodbye."
				exit :normal
			_ ->
				Inform.error "Invalid query."
				loop socket, session_token, ip, port
		end

	end

	defp wait_for_response(socket) do 
		receive do
			{ udp, socket, address, port, msg } ->
				Handler.read address, port, msg
			_ ->
				wait_for_response socket
		after
			20000 ->
				Inform.error "Sorry, timeout."
		end
	end

	defp send_wait_loop(socket, session_token, ip, port, message) do 
		send_msg socket, ip, port, EJSON.encode(message)
		wait_for_response socket
		loop socket, session_token, ip, port
	end

	defp send_msg(socket, ip, port, msg) do
		:gen_udp.send(socket, ip, port, msg)
	end

end