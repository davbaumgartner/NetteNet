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

defmodule Users do
	
	def authenticated?(session_token) do
		sessions = EJSON.read_file (Settings.get_setting :sessiondir)
		Enum.any?(
			Enum.map(sessions, 
					fn (session) ->
						Keyword.get session, :sessiontoken == session_token
					end)
			)
	end

	def get_username(session_token) do
		sessions = EJSON.read_file (Settings.get_setting :sessiondir)
		Keyword.get (Enum.at(Enum.filter(sessions,
					fn (session) ->
						Keyword.get session, :sessiontoken == session_token
					end), 0)), :user
	end


	def authenticate(session_token, user, password) do
		if not authenticated?(session_token) do
			sessions = EJSON.read_file (Settings.get_setting :sessiondir)
			if correct_login?(user, password) do 
				EJSON.write_file((Settings.get_setting :sessiondir), (sessions ++ [[sessiontoken: session_token, user: user]]))
				{ :ok }
			else
				{ :error, :unvalidlogin }
			end
		else
			{ :error, :alreadyauthenticated }
		end
	end

	defp correct_login?(username, password) do 
		users = EJSON.read_file (Settings.get_setting :userdb)
		Enum.any?(
			Enum.map(users, fn (user) ->
				(Keyword.get user, :username == username) and (Keyword.get user, :password == password)
			end)
		)
	end

end