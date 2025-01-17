import OpenAI from 'openai';

export async function POST(req: Request) {
  try {
    const { prompt, apiKey, jwtToken, openAIUrl, customHeader } = await req.json();

    if (!prompt) {
      return new Response(JSON.stringify({ error: 'Prompt is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    if (jwtToken) {
      headers['Authorization'] = `Bearer ${jwtToken}`;
    } else if (apiKey) {
      headers['Authorization'] = `Bearer ${apiKey}`;
    }

    if (customHeader) {
      headers[customHeader.name] = customHeader.value;
    }

    const response = await fetch(openAIUrl, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: prompt }]
      })
    });

    const bodyText = await response.text();

    console.info('Response:', {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers,
      body: bodyText
    });

    if (!response.ok) {
      throw new Error('Backend API request failed');
    }

    const data = JSON.parse(bodyText);

    return new Response(JSON.stringify(data), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    let errorMessage = 'Failed to generate text';
    if (error instanceof Error) {
      errorMessage += `: ${error.message}`;
    }
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

