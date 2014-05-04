# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

require 'securerandom'

Websinger::Application.config.secret_token = begin
  if File.exist? '.secret'
    File.read '.secret'
  else
    token = SecureRandom.hex(128)
    File.write '.secret', token
    token
  end
end

