const { ApolloServer, gql } = require('apollo-server');

const PostsAPI = require('./services/posts-api.js');
const UsersAPI = require('./services/users-api.js');

const dataSources = () => ({
  postsAPI: new PostsAPI(),
  usersAPI: new UsersAPI(),
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
    user: User!
    title: String!
    body: String!
  }

  type User {
    id: ID!
    name: String!
    username: String!
    email: String!
    website: String!
  }  
`;

  
  // Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves books from the "books" array above.
const resolvers = {
    Query: {
      posts: async (_, { id }, { dataSources }) => {
        return dataSources.postsAPI.getPosts();
      },   
    },
    Post: {
      user: async (parent, { id }, { dataSources }) => {
        return dataSources.usersAPI.getUserById(parent.userId)
      },   
    },
  };


// The ApolloServer constructor requires two parameters: your schema
// definition and your set of resolvers.
const server = new ApolloServer({ typeDefs, resolvers, dataSources, });

// The `listen` method launches a web server.
server.listen({port: 4001}).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});


  
  