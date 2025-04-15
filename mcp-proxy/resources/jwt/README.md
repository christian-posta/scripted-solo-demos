## JWT

I used the step CLI to generate the private key and public key: https://github.com/smallstep/cli


### Generate a token

```
step crypto jwt sign --key priv-key --iss me --aud me.com --sub me --exp 1900650294
```


