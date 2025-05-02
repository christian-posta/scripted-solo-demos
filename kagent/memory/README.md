
How to create the secret for the memory. 


```bash
apiVersion: v1
data:
  PINECONE_API_KEY: << foo >>
kind: Secret
metadata:
  name: test-kagent-memory
  namespace: kagent
type: Opaque
```