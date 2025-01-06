'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { Input } from '@/components/ui/input'
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { AlertCircle } from 'lucide-react'
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"

export default function OpenAIForm() {
  const [prompt, setPrompt] = useState('')
  const [apiKey, setApiKey] = useState('')
  const [openAIUrl, setOpenAIUrl] = useState('https://api.openai.com/v1/chat/completions')
  const [response, setResponse] = useState('')
  const [error, setError] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [includeApiKey, setIncludeApiKey] = useState(true)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');
    setResponse('');

    try {
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
      };

      if (includeApiKey) {
        headers['Authorization'] = `Bearer ${apiKey}`;
      }

      const res = await fetch(openAIUrl, {
        method: 'POST',
        headers: headers,
        body: JSON.stringify({
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: prompt }]
        }),
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.error?.message || 'Failed to generate response');
      }

      const generatedText = data.choices[0]?.message?.content;

      if (!generatedText) {
        throw new Error('No text generated from OpenAI');
      }

      setResponse(generatedText);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred while generating the response.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="apiKey" className="block text-sm font-medium text-gray-700">
          OpenAI API Key
        </label>
        <Input
          id="apiKey"
          type="password"
          value={apiKey}
          onChange={(e) => setApiKey(e.target.value)}
          required={includeApiKey}
          className="mt-1"
          placeholder="Enter your OpenAI API key"
        />
      </div>
      <div className="flex items-center space-x-2">
        <Switch
          id="include-api-key"
          checked={includeApiKey}
          onCheckedChange={setIncludeApiKey}
        />
        <Label htmlFor="include-api-key">Include API Key in request</Label>
      </div>
      <div>
        <label htmlFor="openAIUrl" className="block text-sm font-medium text-gray-700">
          OpenAI API URL
        </label>
        <Input
          id="openAIUrl"
          value={openAIUrl}
          onChange={(e) => setOpenAIUrl(e.target.value)}
          required
          className="mt-1"
          placeholder="Enter OpenAI API URL"
        />
      </div>
      <div>
        <label htmlFor="prompt" className="block text-sm font-medium text-gray-700">
          Enter your prompt
        </label>
        <Textarea
          id="prompt"
          value={prompt}
          onChange={(e) => setPrompt(e.target.value)}
          required
          className="mt-1"
          rows={4}
          placeholder="Type your prompt here..."
        />
      </div>
      <Button type="submit" disabled={isLoading} className="w-full">
        {isLoading ? 'Generating...' : 'Generate Response'}
      </Button>
      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertTitle>Error</AlertTitle>
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}
      {response && (
        <div className="mt-4">
          <h2 className="text-xl font-semibold mb-2">Generated Response:</h2>
          <p className="whitespace-pre-wrap bg-gray-50 p-4 rounded-md border border-gray-200">{response}</p>
        </div>
      )}
    </form>
  )
}

