# Generating keys for mTLS & Step CA

> Ensure that use has ran
> `step ca bootstrap --ca-url $CA_URL --fingerprint $CA_ROOT_FINGERPRINT` before
> doing anything

generating CA Certs on Yubikey with STEP-CA

can use yubioath gui to get management key from PUK pin format:

```fish
❯ step kms create 'yubikey:slot-id=9a' --kms 'yubikey:management-key=$MANAGEMENT-KEY?pin-value=$PIN'
```

then attest to the cert to ca server:

```
step ca certificate --attestation-uri 'yubikey:slot-id=9a;management-key=MGMT_KEY?pin-value=$PIN' \
       --provisioner acme-da $SERIAL $SERIAL.crt
```

$SERIAL can be found with `ykman info`

then import cert back into yubikey

```
ykman piv certificates import 9a $SERIAL.crt
```
