### Resource names:

API Product: petstore
Product Plan: petstore-plan
Portal: petstore-portal


### Live demo flow:

* run the `prep-live-demo.sh` script which sets up routes and users and DNS!!
* Make sure to use the names above!

* Create ApiDocs
* Create Api Product
** use domain petstore.myddns.me
* Call Curl

```
curl -v http://petstore.myddns.me/api/pets
```

For calling with the API key:

```
curl -v -H 'api-key: YTQyMjcwYTUtNzg4NS1iMjZmLWQ1YmMtMjdkOWU4ZDVlNmEw'  http://$HOST/api/pets
```
  
  customStyling:

  primaryColor: '#eb921b'

  secondaryColor: '#074d57'



petstore.myddns.me


## Set up on GKE
You can use both DNS and localhost way of doing on GKE

On kind, you can only use local

Make sure to port-forward all


Istio Developer Portal -- Part 1
With the Istio Developer Portal, teams can publish their APIs running in Istio into a customizable portal that enables authentication/authorization, usage plans/policy, self-service documentation, sign up and more. In this blog, we take a look at how this works, what components get added to Istio to enable this, and what the main API resources are. 

Istio,API Gateway,Developer Portal,Envoy,Solo.io,Gloo