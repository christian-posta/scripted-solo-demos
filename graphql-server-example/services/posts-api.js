const { RESTDataSource } = require('apollo-datasource-rest');

class PostsAPI extends RESTDataSource {
  constructor() {
    // Always call super()
    super();
    // Sets the base URL for the REST API
    this.baseURL = 'http://localhost:3000/';
  }

  async getPosts() {
    // Send a GET request to the specified endpoint
    return this.get('data/');
  }

}


module.exports = PostsAPI;

