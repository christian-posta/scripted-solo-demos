require('dotenv').config(); // Load environment variables from .env file

const express = require('express');
const cors = require('cors');
const app = express();
const usecaseRoutes = require('./routes/usecase-routes');

app.use(cors());
app.use(express.json());

// Endpoint to proxy LLM requests
app.post('/api/llm', async (req, res) => {
  const requestDetails = {
    timestamp: new Date().toISOString(),
    method: 'POST',
    endpoint: req.body.endpoint,
    headers: {},
    body: req.body
  };

  try {
    const { prompt, credentials } = req.body;
    let endpoint = req.body.endpoint; // Store the original endpoint
    const headers = {
      'Content-Type': 'application/json',
    };

    // Check if the endpoint is localhost and if an override is provided
    const overrideUrl = process.env.LLM_OVERRIDE_URL; // Get the override value from .env
    if (endpoint.startsWith('http://localhost') || endpoint.startsWith('https://localhost')) {
      if (overrideUrl) {
        const url = new URL(endpoint);
        const overrideUrlObj = new URL(overrideUrl);
        // Replace the host and port while keeping the path
        endpoint = `${overrideUrlObj.protocol}//${overrideUrlObj.host}${url.pathname}${url.search}`;
      }
    }

    if (credentials) {
      headers['Authorization'] = `Bearer ${credentials}`;
      requestDetails.headers['Authorization'] = `Bearer ${credentials}`;
    }

    requestDetails.headers['Content-Type'] = 'application/json';

    const llmRequest = {
      method: 'POST',
      headers,
      body: JSON.stringify({
        model: req.body.model || 'gpt-3.5-turbo',
        messages: [
          { role: 'system', content: 'You are a helpful assistant.' },
          { role: 'user', content: prompt }
        ],
      }),
    };

    const response = await fetch(endpoint, llmRequest);
    const clonedResponse = response.clone();
    let responseData;
    let responseText;
    
    try {
      responseData = await response.json();
    } catch (parseError) {
      // If JSON parsing fails, get the response as text from the clone
      responseText = await clonedResponse.text();
    }

    const responseDetails = {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers ? Object.fromEntries(response.headers) : {},
      body: responseData || responseText
    };

    if (!response.ok) {
      return res.status(response.status).json({
        error: responseData?.error?.message || responseText || 'An error occurred',
        debug: {
          request: requestDetails,
          response: responseDetails
        }
      });
    }

    res.json({
      choices: responseData?.choices || [{ message: { content: responseText } }],
      debug: {
        request: requestDetails,
        response: responseDetails
      }
    });
  } catch (error) {
    console.error('Error in LLM proxy:', error);
    res.status(500).json({
      error: error.message || 'Internal Server Error',
      debug: {
        request: requestDetails,
        response: {
          status: error.response?.status || null,
          statusText: error.response?.statusText || null,
          headers: error.response && error.response.headers ? Object.fromEntries(error.response.headers) : null,
          body: error.response ? await error.response.text() : null
        }
      }
    });
  }
});

app.use('/api', usecaseRoutes);

// Use the PORT environment variable or default to 3000
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
