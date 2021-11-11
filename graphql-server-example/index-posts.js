const { ApolloServer, gql } = require('apollo-server');

const PostsAPI = require('./posts-api.js');

const dataSources = () => ({
  postsAPI: new PostsAPI(),
});

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  type Query {
    posts: [Post]
  }

  type Post {
    id: ID!
    title: String!
    body: String!
  }
`;

const posts = [
    {
      userId: 10,
      id: 99,
      title: "Foo bar",
      body: "cupiditate quo est a modi nesciunt soluta\nipsa voluptas error itaque dicta in\nautem qui minus magnam et distinctio eum\naccusamus ratione error aut"
    },
    {
      userId: 10,
      id: 100,
      title: "at nam consequatur ea labore ea harum",
      body: "cupiditate quo est a modi nesciunt soluta\nipsa voluptas error itaque dicta in\nautem qui minus magnam et distinctio eum\naccusamus ratione error aut"
    },
  ];
  
  // Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves books from the "books" array above.
const resolvers = {
    Query: {
      posts: async (_, { id }, { dataSources }) => {
        return dataSources.postsAPI.getPosts();
      },      
    },
  };


// The ApolloServer constructor requires two parameters: your schema
// definition and your set of resolvers.
const server = new ApolloServer({ typeDefs, resolvers, dataSources, });

// The `listen` method launches a web server.
server.listen({port: 4000}).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});


  
  