const { RESTDataSource } = require('apollo-datasource-rest');

class UsersAPI extends RESTDataSource {
  constructor() {
    // Always call super()
    super();
    // Sets the base URL for the REST API
    this.baseURL = 'http://localhost:3001/';
  }

  async getUserById(id) {
    // Send a GET request to the specified endpoint
    return this.get('data/' + id);
  }

}


module.exports = UsersAPI;

