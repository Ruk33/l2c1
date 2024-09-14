defmodule Blowfish do
  def encrypt(key, to_encrypt) do
    :crypto.crypto_one_time(:blowfish_ecb, key, to_encrypt, true)
  end

  def decrypt(key, to_decrypt) do
    :crypto.crypto_one_time(:blowfish_ecb, key, to_decrypt, false)
  end
end
