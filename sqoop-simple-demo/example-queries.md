# Example GraphQL queries for this demo:


Get ped by ID: 

```
{
  pet(id:1 ) {
    name
  }
}
```

Get only "name" field for pets:

```
{
  pets {
    name
  }
}
```

Adding a pet:

```
mutation($pet: InputPet!) {
  addPet(pet: $pet) {
    id
    name
  }
}
```

With these variables:

```
{
  "pet":{
    "id":3,
    "name": "monkey"
  }
}
```