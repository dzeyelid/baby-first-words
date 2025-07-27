<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto px-4 py-8">
      <!-- Header -->
      <header class="text-center mb-8">
        <h1 class="text-4xl font-bold text-gray-800 mb-4">🔗 API連携デモ</h1>
        <p class="text-lg text-gray-600">Azure Functions APIとの接続テスト</p>
        <NuxtLink to="/" class="inline-block mt-4 text-blue-600 hover:text-blue-800">
          ← ホームに戻る
        </NuxtLink>
      </header>

      <!-- API Test Section -->
      <div class="max-w-4xl mx-auto">
        <div class="bg-white rounded-lg shadow-lg p-8 mb-8">
          <h2 class="text-2xl font-semibold text-gray-800 mb-6">ヘルスチェックAPI</h2>
          
          <!-- API Call Button -->
          <div class="mb-6">
            <button 
              @click="callHealthApi"
              :disabled="loading"
              class="bg-blue-500 hover:bg-blue-600 disabled:bg-gray-400 text-white font-bold py-3 px-6 rounded-lg transition-colors duration-200"
            >
              <span v-if="loading" class="flex items-center">
                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                APIを呼び出し中...
              </span>
              <span v-else>ヘルスチェックAPIを呼び出し</span>
            </button>
          </div>

          <!-- API Response Display -->
          <div v-if="apiResponse" class="space-y-4">
            <div class="p-4 rounded-lg" :class="apiResponse.success ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'">
              <h3 class="font-semibold mb-2" :class="apiResponse.success ? 'text-green-800' : 'text-red-800'">
                {{ apiResponse.success ? '✅ API呼び出し成功' : '❌ API呼び出し失敗' }}
              </h3>
              <p class="text-sm" :class="apiResponse.success ? 'text-green-700' : 'text-red-700'">
                ステータス: {{ apiResponse.status }} {{ apiResponse.statusText }}
              </p>
            </div>

            <!-- Response Data -->
            <div v-if="apiResponse.data" class="bg-gray-50 p-4 rounded-lg">
              <h4 class="font-semibold text-gray-800 mb-3">APIレスポンス:</h4>
              <pre class="bg-gray-800 text-green-400 p-4 rounded text-sm overflow-x-auto">{{ JSON.stringify(apiResponse.data, null, 2) }}</pre>
            </div>

            <!-- Error Details -->
            <div v-if="apiResponse.error" class="bg-red-50 p-4 rounded-lg border border-red-200">
              <h4 class="font-semibold text-red-800 mb-3">エラー詳細:</h4>
              <p class="text-red-700 text-sm">{{ apiResponse.error }}</p>
            </div>
          </div>
        </div>

        <!-- API Information -->
        <div class="bg-white rounded-lg shadow-lg p-8">
          <h2 class="text-2xl font-semibold text-gray-800 mb-6">API情報</h2>
          
          <div class="grid md:grid-cols-2 gap-6">
            <div>
              <h3 class="text-lg font-semibold text-gray-700 mb-3">エンドポイント</h3>
              <div class="bg-gray-50 p-3 rounded">
                <code class="text-sm text-gray-800">/api/health</code>
              </div>
            </div>
            
            <div>
              <h3 class="text-lg font-semibold text-gray-700 mb-3">メソッド</h3>
              <div class="bg-gray-50 p-3 rounded">
                <span class="inline-block bg-green-100 text-green-800 px-2 py-1 rounded text-sm font-medium">GET</span>
              </div>
            </div>
          </div>

          <div class="mt-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-3">説明</h3>
            <p class="text-gray-600">
              このAPIは、Azure Functions + TypeScriptで実装されたヘルスチェックエンドポイントです。
              アプリケーションの状態、メモリ使用量、データベース接続状況などの情報を返します。
            </p>
          </div>

          <div class="mt-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-3">技術スタック</h3>
            <div class="flex flex-wrap gap-2">
              <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm">Azure Functions v4</span>
              <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm">TypeScript</span>
              <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm">Azure Static Web Apps</span>
              <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm">Node.js</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface ApiResponse {
  success: boolean
  status: number
  statusText: string
  data?: any
  error?: string
}

// Reactive state
const loading = ref(false)
const apiResponse = ref<ApiResponse | null>(null)

// API call function
const callHealthApi = async () => {
  loading.value = true
  apiResponse.value = null

  try {
    const response = await $fetch('/api/health', {
      method: 'GET',
      // Get response metadata
      onResponse({ response }) {
        apiResponse.value = {
          success: response.ok,
          status: response.status,
          statusText: response.statusText,
          data: response._data
        }
      },
      onResponseError({ response }) {
        apiResponse.value = {
          success: false,
          status: response.status,
          statusText: response.statusText,
          error: `HTTP ${response.status}: ${response.statusText}`
        }
      }
    })
  } catch (error: any) {
    apiResponse.value = {
      success: false,
      status: 0,
      statusText: 'Network Error',
      error: error.message || 'Unknown error occurred'
    }
  } finally {
    loading.value = false
  }
}

// Page metadata
useHead({
  title: 'API連携デモ - Baby First Words',
  meta: [
    { name: 'description', content: 'Azure Functions APIとの連携テストページ' }
  ]
})
</script>