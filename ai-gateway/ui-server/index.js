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
    const { prompt, endpoint, credentials } = req.body;
    const headers = {
      'Content-Type': 'application/json',
    };

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
      headers: Object.fromEntries(response.headers),
      body: responseData || responseText
    };

    if (!response.ok) {
      throw {
        message: responseData?.error?.message || responseText || `API call failed with status: ${response.status}`,
        request: requestDetails,
        response: responseDetails
      };
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
          headers: error.response ? Object.fromEntries(error.response.headers) : null,
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
