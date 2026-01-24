# Generating keys

age-plugin-yubikey (easy to use)

generating CA Certs on Yubikey with STEP-CA

can use yubioath gui to get management key from PUK pin format:

```fish
❯ step kms create 'yubikey:slot-id=9a' --kms 'yubikey:management-key=$MANAGEMENT-KEY?pin-value=$PIN'
```
