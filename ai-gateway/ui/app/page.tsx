import OpenAIForm from '@/components/OpenAIForm'

export default function Home() {
  return (
    <div className="min-h-screen bg-gray-100 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md mx-auto bg-white rounded-xl shadow-md overflow-hidden md:max-w-2xl">
        <div className="p-8">
          <h1 className="text-2xl font-bold text-gray-900 mb-6">LLM Client Example</h1>
          <OpenAIForm />
        </div>
      </div>
    </div>
  )
}

