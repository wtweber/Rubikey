# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'json'

class PasswordCipher
  CIPHER_NAME = 'aes-256-cbc'
  def self.encrypt(text, password)
    cipher, salt, iv = PasswordCipher.init_encrypt(password)
    encrypted = cipher.update text
    encrypted << cipher.final

    payload = {
      salt: Base64.strict_encode64(salt),
      iv: Base64.strict_encode64(iv),
      data: Base64.strict_encode64(encrypted)
    }

    Base64.strict_encode64(payload.to_json)
  end

  def self.decrypt(encrypted_payload, password)
    decoded_json = Base64.strict_decode64(encrypted_payload)
    payload = JSON.parse(decoded_json, symbolize_names: true)

    salt = Base64.strict_decode64(payload[:salt])
    iv = Base64.strict_decode64(payload[:iv])
    enc_data = Base64.strict_decode64(payload[:data])

    cipher = PasswordCipher.init_decrypt(password, salt, iv)

    decrypted = cipher.update enc_data
    decrypted << cipher.final
  end

  def self.init_encrypt(password)
    cipher = OpenSSL::Cipher.new CIPHER_NAME
    cipher.encrypt

    iv = cipher.random_iv
    salt = OpenSSL::Random.random_bytes 16
    iter = 20_000
    key_len = cipher.key_len
    digest = OpenSSL::Digest.new('SHA256')
    cipher.key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iter, key_len, digest)

    [cipher, salt, iv]
  end

  def self.init_decrypt(password, salt, ivec)
    cipher = OpenSSL::Cipher.new CIPHER_NAME
    cipher.decrypt
    cipher.iv = ivec

    iter = 20_000
    key_len = cipher.key_len
    digest = OpenSSL::Digest.new('SHA256')

    cipher.key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iter, key_len, digest)
    cipher
  end
end
