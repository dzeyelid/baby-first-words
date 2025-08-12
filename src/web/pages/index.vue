<template>
  <div class="min-h-screen bg-gradient-to-r from-blue-100 to-purple-100">
    <div class="container mx-auto px-4 py-8">
      <!-- Header -->
      <header class="text-center mb-12">
        <h1 class="text-5xl font-bold text-gray-800 mb-4">
          🍼 Baby First Words
        </h1>
        <p class="text-xl text-gray-600 mb-2">はじめての言葉</p>
        <p class="text-lg text-gray-500">Azure Static Web Apps + Nuxt.js サンプルアプリケーション</p>
      </header>

      <!-- Welcome Section -->
      <div class="max-w-4xl mx-auto">
        <div class="bg-white rounded-lg shadow-lg p-8 mb-8">
          <h2 class="text-3xl font-semibold text-gray-800 mb-4">🎉 Hooray!</h2>
          <p class="text-lg text-gray-600 mb-4">
            Azure Static Web Appsを使ったNuxt.jsアプリケーションが正常に動作しています！
          </p>
          <div class="grid md:grid-cols-2 gap-6">
            <div class="bg-blue-50 p-6 rounded-lg">
              <h3 class="text-xl font-semibold text-blue-800 mb-2">✨ フロントエンド</h3>
              <ul class="text-blue-700 space-y-1">
                <li>• Nuxt.js 最新版</li>
                <li>• Vue.js 3</li>
                <li>• TypeScript対応</li>
                <li>• Tailwind CSS (utility-first)</li>
              </ul>
            </div>
            <div class="bg-green-50 p-6 rounded-lg">
              <h3 class="text-xl font-semibold text-green-800 mb-2">⚡ バックエンド</h3>
              <ul class="text-green-700 space-y-1">
                <li>• Nuxt Server API</li>
                <li>• TypeScript API</li>
                <li>• Static Web Apps統合</li>
                <li>• サーバーレス実行</li>
              </ul>
            </div>
          </div>
        </div>

        <!-- Navigation Cards -->
        <div class="grid md:grid-cols-3 gap-6">
          <NuxtLink to="/api-demo" class="block">
            <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow duration-200">
              <div class="text-center">
                <div class="text-4xl mb-4">🔗</div>
                <h3 class="text-xl font-semibold text-gray-800 mb-2">API連携デモ</h3>
                <p class="text-gray-600">Azure Functions APIとの連携を確認</p>
              </div>
            </div>
          </NuxtLink>

          <NuxtLink to="/first-words" class="block">
            <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow duration-200">
              <div class="text-center">
                <div class="text-4xl mb-4">👶</div>
                <h3 class="text-xl font-semibold text-gray-800 mb-2">はじめての言葉</h3>
                <p class="text-gray-600">赤ちゃんの記録を管理</p>
              </div>
            </div>
          </NuxtLink>

          <div class="bg-white rounded-lg shadow-md p-6">
            <div class="text-center">
              <div class="text-4xl mb-4">📚</div>
              <h3 class="text-xl font-semibold text-gray-800 mb-2">ドキュメント</h3>
              <p class="text-gray-600 mb-4">セットアップとデプロイ方法</p>
              <a href="https://github.com/dzeyelid/baby-first-words" target="_blank" rel="noopener" 
                 class="inline-flex items-center text-blue-600 hover:text-blue-800">
                <span>GitHub リポジトリ</span>
                <svg class="w-4 h-4 ml-1" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M11 3a1 1 0 100 2h2.586l-6.293 6.293a1 1 0 101.414 1.414L15 6.414V9a1 1 0 102 0V4a1 1 0 00-1-1h-5z"></path>
                  <path d="M5 5a2 2 0 00-2 2v8a2 2 0 002 2h8a2 2 0 002-2v-3a1 1 0 10-2 0v3H5V7h3a1 1 0 000-2H5z"></path>
                </svg>
              </a>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="text-center mt-12 text-gray-500">
          <p>Built with ❤️ using Azure Static Web Apps</p>
          <p class="text-sm mt-2">Powered by Nuxt.js, Azure Functions, and TypeScript</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Page metadata
useHead({
  title: 'Baby First Words - はじめての言葉',
  meta: [
    { name: 'description', content: 'Azure Static Web Appsを使用したNuxt.jsサンプルアプリケーション' }
  ]
})
</script>