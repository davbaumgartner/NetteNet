# The MIT License (MIT)

# Copyright (c) 2013 David Baumgartner

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

defmodule Handler do
	
	def answer(address, port, msg) do
		request = EJSON.decode msg
		case EJSON.search_for request, :cmd do 
			"load" ->
				case File.read ("#{Settings.get_setting :publicdir}#{(Path.basename(String.strip (EJSON.search_for request, :res)))}") do 
					{ :ok, lol } ->
						output :ok, [status: 200, content: lol]
					_ ->
						error(404)
				end
			"login" ->
				case Users.authenticate((EJSON.search_for request, :sessiontoken), (EJSON.search_for request, :username), (EJSON.search_for request, :password)) do 
					{ :ok } ->
						output :ok, [status: 200, content: "Successfully authenticated"]
					{ :error, :unvalidlogin } ->
						error(401, "Login failed")
					{ :error, :alreadyauthenticated} ->
						error(400, "Already authtenticated")
				end
			_ ->
				error(404)
		end
	end

	defp error(n) do 
		case n do 
			404 -> 
				error(n, "Not found")
			500 ->
				error(n, "Internal error")
			_ ->
				error(n, "Unknown error")
		end
	end

	defp error(status, message) do 
		output :error, [status: status, message: message]
	end

	defp output(is_ok, message) do 
		{ is_ok, EJSON.encode message }
	end
	
end