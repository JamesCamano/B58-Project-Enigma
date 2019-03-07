# Enigma
An interpretation of the Enigma machine and its Turing decoder counterpart.

Project Enigma sets out to imitate both the German "Enigma" text cipher machine and its cryptographic
counterpart - the British "Bombe" decoder machine developed during the mid-1940s.

Based on its initial settings, the Enigma machine provides a non-surjective mapping for which individual
alphabetic characters are mapped to other alphabetic characters. The same initial setting must be used
to decrypt encoded messages from Enigma.

The Bombe decoder recieves an encrypted string from Enigma and outputs the Enigma setting for which the message
is decoded.

Enigma consists of two components: 
  (1) A multi-stage* programmable text encryptor/decryptor device, and
  (2) A string-setting decryptor device.
