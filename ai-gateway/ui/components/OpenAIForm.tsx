'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { Input } from '@/components/ui/input'
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { AlertCircle } from 'lucide-react'
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"

type Tab = 'response' | 'request' | 'raw' | 'jwt';
type AuthType = 'openai' | 'jwt';

function decodeJWT(token: string): object | null {
  try {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(
      atob(base64).split('').map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)).join('')
    );
    return JSON.parse(jsonPayload);
  } catch (e) {
    console.error('Error decoding JWT:', e);
    return null;
  }
}

function redactSensitiveInfo(obj: any): any {
  const clone = JSON.parse(JSON.stringify(obj));
  if (clone.headers?.Authorization) {
    clone.headers.Authorization = 'Bearer [REDACTED]';
  }
  return clone;
}

export default function OpenAIForm() {
  const [prompt, setPrompt] = useState('')
  const [apiKey, setApiKey] = useState('')
  const [openAIUrl, setOpenAIUrl] = useState('https://api.openai.com/v1/chat/completions')
  const [response, setResponse] = useState('')
  const [error, setError] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [includeApiKey, setIncludeApiKey] = useState(true)
  const [requestDetails, setRequestDetails] = useState<string>('')
  const [responseDetails, setResponseDetails] = useState<string>('')
  const [activeTab, setActiveTab] = useState<Tab>('response');
  const [jwtToken, setJwtToken] = useState('eyJhbGciOiJSUzI1NiIsInR5cGUiOiJKV1QifQ.eyJpc3MiOiJzb2xvLmlvIiwib3JnIjoic29sby5pbyIsIm5hbWUiOiJDaHJpc3RpYW4gUG9zdGEiLCJzdWIiOiJjZXBvc3RhIiwidGVhbSI6InJuZCIsImxsbXMiOnsib3BlbmFpIjpbImdwdC0zLjUtdHVyYm8iXX19.T8VOu-J4GdQd_SB2MymU3sF6hMVdlge2W_45jzdayMlwuOgpJZx7UW289vn-Nw3iQ0GOqp6pNKZHNMYeruD2nVQqVYdFakGztmALJCfRGTx0mdFIqzYgPkeFSArcj4rbxkkiC_VmrpuXd5zIJZ7SQf32eaJ1xHXW09RlEWWbQM7qAA6WpnWPBI8vG16CxdJ7RihmYnp7kV_nWicZhfm9HgN7jY4fUCcyesA18_7DosQvkF44_91xD7Tk2SC1UOVJcHeeRgGAwTdnQ4TOIxop9SCswnfModNZR2ekPN9j7ybOvvyLgnrvWkYdxo4dmWo6ph2d0MV1Nv7nmeK73ViM6g');
  const [includeJWT, setIncludeJWT] = useState(false)
  const [decodedJWT, setDecodedJWT] = useState<object | null>(null)
  const [authType, setAuthType] = useState<AuthType>('openai')
  const [includeCustomHeader, setIncludeCustomHeader] = useState(false)
  const [customHeaderName, setCustomHeaderName] = useState('x-action')
  const [customHeaderValue, setCustomHeaderValue] = useState('mask')

  useEffect(() => {
    if (authType === 'jwt' && jwtToken) {
      const decoded = decodeJWT(jwtToken);
      setDecodedJWT(decoded);
      setActiveTab('jwt');
    }
  }, [authType]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');
    setResponse('');
    setRequestDetails('');
    setResponseDetails('');

    try {
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
      };

      const requestBody = {
        prompt,
        openAIUrl,
        ...(authType === 'openai' && includeApiKey ? { apiKey } : {}),
        ...(authType === 'jwt' && includeJWT ? { jwtToken } : {}),
        ...(includeCustomHeader ? { 
          customHeader: {
            name: customHeaderName,
            value: customHeaderValue
          }
        } : {})
      };

      // Log request details
      setRequestDetails(JSON.stringify(redactSensitiveInfo({
        url: '/api/generate',
        method: 'POST',
        body: requestBody
      }), null, 2));

      const res = await fetch('/api/generate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      });

      const data = await res.json();
      setResponseDetails(JSON.stringify(data, null, 2));

      if (!res.ok) {
        throw new Error(data.error || 'Failed to generate response');
      }

      const generatedText = data.choices[0]?.message?.content;

      if (!generatedText) {
        throw new Error('No text generated from OpenAI');
      }

      setResponse(generatedText);
      // Default to response tab after generating
      setActiveTab('response');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred while generating the response.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleApiKeyToggle = (checked: boolean) => {
    if (authType === 'openai') {
      setIncludeApiKey(checked);
    }
  };

  const handleJwtToggle = (checked: boolean) => {
    if (authType === 'jwt') {
      setIncludeJWT(checked);
    }
  };

  const handleJWTInput = (value: string) => {
    setJwtToken(value);
    try {
      const decoded = decodeJWT(value);
      setDecodedJWT(decoded);
      if (decoded) {
        setActiveTab('jwt');
      }
    } catch (e) {
      console.error('Error decoding JWT:', e);
      setDecodedJWT(null);
    }
  };

  const renderAuthInputs = () => {
    return (
      <>
        <div className="flex items-center space-x-4 mb-4">
          <button
            type="button"
            onClick={() => {
              setAuthType('openai');
              setIncludeJWT(false);
            }}
            className={`px-4 py-2 rounded-md ${
              authType === 'openai' 
                ? 'bg-primary text-white' 
                : 'bg-gray-100 text-gray-700'
            }`}
          >
            OpenAI Token
          </button>
          <button
            type="button"
            onClick={() => {
              setAuthType('jwt');
              setIncludeApiKey(false);
            }}
            className={`px-4 py-2 rounded-md ${
              authType === 'jwt' 
                ? 'bg-primary text-white' 
                : 'bg-gray-100 text-gray-700'
            }`}
          >
            JWT Token
          </button>
        </div>

        {authType === 'openai' && (
          <>
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
                onCheckedChange={handleApiKeyToggle}
              />
              <Label htmlFor="include-api-key">Include API Key in request</Label>
            </div>
            
            <div className="mt-4">
              <div className="flex items-center space-x-2 mb-4">
                <Switch
                  id="include-custom-header"
                  checked={includeCustomHeader}
                  onCheckedChange={(checked) => setIncludeCustomHeader(checked)}
                />
                <Label htmlFor="include-custom-header">Include Custom Header</Label>
              </div>
              
              {includeCustomHeader && (
                <div className="space-y-4">
                  <div>
                    <label htmlFor="headerName" className="block text-sm font-medium text-gray-700">
                      Header Name
                    </label>
                    <Input
                      id="headerName"
                      type="text"
                      value={customHeaderName}
                      onChange={(e) => setCustomHeaderName(e.target.value)}
                      className="mt-1"
                      placeholder="Enter header name"
                    />
                  </div>
                  <div>
                    <label htmlFor="headerValue" className="block text-sm font-medium text-gray-700">
                      Header Value
                    </label>
                    <Input
                      id="headerValue"
                      type="text"
                      value={customHeaderValue}
                      onChange={(e) => setCustomHeaderValue(e.target.value)}
                      className="mt-1"
                      placeholder="Enter header value"
                    />
                  </div>
                </div>
              )}
            </div>
          </>
        )}

        {authType === 'jwt' && (
          <>
            <div>
              <label htmlFor="jwtToken" className="block text-sm font-medium text-gray-700">
                JWT Token
              </label>
              <Input
                id="jwtToken"
                type="text"
                value={jwtToken}
                onChange={(e) => handleJWTInput(e.target.value)}
                required={includeJWT}
                className="mt-1 font-mono text-sm"
                placeholder="Enter your JWT token"
              />
            </div>
            <div className="flex items-center space-x-2">
              <Switch
                id="include-jwt"
                checked={includeJWT}
                onCheckedChange={handleJwtToggle}
              />
              <Label htmlFor="include-jwt">Include JWT in request</Label>
            </div>
          </>
        )}
      </>
    );
  };

  const renderTabs = () => {
    if (!response && !requestDetails && !responseDetails && !decodedJWT) return null;

    return (
      <div className="mt-4">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8">
            <button
              onClick={() => setActiveTab('response')}
              className={`${
                activeTab === 'response'
                  ? 'border-primary text-primary'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
            >
              Response
            </button>
            <button
              onClick={() => setActiveTab('request')}
              className={`${
                activeTab === 'request'
                  ? 'border-primary text-primary'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
            >
              Request Details
            </button>
            <button
              onClick={() => setActiveTab('raw')}
              className={`${
                activeTab === 'raw'
                  ? 'border-primary text-primary'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
            >
              Raw Response
            </button>
            {decodedJWT && (
              <button
                onClick={() => setActiveTab('jwt')}
                className={`${
                  activeTab === 'jwt'
                    ? 'border-primary text-primary'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
              >
                JWT Details
              </button>
            )}
          </nav>
        </div>

        <div className="mt-4">
          {activeTab === 'response' && response && (
            <div>
              <h2 className="text-xl font-semibold mb-2">Generated Response:</h2>
              <p className="whitespace-pre-wrap bg-gray-50 p-4 rounded-md border border-gray-200">
                {response}
              </p>
            </div>
          )}
          {activeTab === 'request' && requestDetails && (
            <div>
              <h3 className="text-lg font-semibold mb-2">Request Details:</h3>
              <pre className="bg-gray-100 p-4 rounded-md overflow-auto text-sm">
                {requestDetails}
              </pre>
            </div>
          )}
          {activeTab === 'raw' && responseDetails && (
            <div>
              <h3 className="text-lg font-semibold mb-2">Raw Response:</h3>
              <pre className="bg-gray-100 p-4 rounded-md overflow-auto text-sm">
                {responseDetails}
              </pre>
            </div>
          )}
          {activeTab === 'jwt' && (
            <div>
              <h3 className="text-lg font-semibold mb-2">Decoded JWT:</h3>
              <pre className="bg-gray-100 p-4 rounded-md overflow-auto text-sm">
                {JSON.stringify(decodedJWT, null, 2)}
              </pre>
            </div>
          )}
        </div>
      </div>
    );
  };

  return (
    <div className="space-y-4">
      <form onSubmit={handleSubmit} className="space-y-4">
        {renderAuthInputs()}
        <div>
          <label htmlFor="openAIUrl" className="block text-sm font-medium text-gray-700">
            OpenAI API URL
          </label>
          <select
            id="openAIUrl"
            value={openAIUrl}
            onChange={(e) => setOpenAIUrl(e.target.value)}
            required
            className="mt-1 flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-base shadow-sm transition-colors file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 md:text-sm"
          >
            <option value="https://api.openai.com/v1/chat/completions">api.openai.com/v1/chat/completions</option>
            <option value="http://localhost:8080/v1/chat/completions">localhost:8080/v1/chat/completions</option>
            <option value="http://localhost:8080/openai">localhost:8080/openai</option>
          </select>
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
      </form>
      {renderTabs()}
    </div>
  )
}

