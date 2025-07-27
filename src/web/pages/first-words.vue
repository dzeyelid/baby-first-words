<template>
  <div class="min-h-screen bg-gradient-to-r from-pink-100 to-yellow-100">
    <div class="container mx-auto px-4 py-8">
      <!-- Header -->
      <header class="text-center mb-8">
        <h1 class="text-4xl font-bold text-gray-800 mb-4">👶 はじめての言葉</h1>
        <p class="text-lg text-gray-600">赤ちゃんの成長記録</p>
        <NuxtLink to="/" class="inline-block mt-4 text-blue-600 hover:text-blue-800">
          ← ホームに戻る
        </NuxtLink>
      </header>

      <div class="max-w-4xl mx-auto">
        <!-- Sample Words Section -->
        <div class="bg-white rounded-lg shadow-lg p-8 mb-8">
          <h2 class="text-2xl font-semibold text-gray-800 mb-6">記録された言葉</h2>
          
          <div v-if="sampleWords.length === 0" class="text-center py-8 text-gray-500">
            <div class="text-6xl mb-4">📝</div>
            <p class="text-lg">まだ記録された言葉がありません</p>
            <p class="text-sm mt-2">下のフォームから最初の言葉を記録してみましょう！</p>
          </div>

          <div v-else class="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div 
              v-for="word in sampleWords" 
              :key="word.id"
              class="bg-gradient-to-r from-blue-50 to-purple-50 p-4 rounded-lg border border-blue-200"
            >
              <div class="flex justify-between items-start mb-2">
                <span class="text-2xl font-bold text-gray-800">{{ word.word }}</span>
                <span class="text-xs text-gray-500">{{ formatDate(word.date) }}</span>
              </div>
              <p class="text-sm text-gray-600 mb-2">{{ word.context }}</p>
              <div class="flex items-center text-xs text-gray-500">
                <span class="mr-2">👶 {{ word.ageMonths }}ヶ月</span>
                <span>🎉 {{ word.occasion }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Add Word Form -->
        <div class="bg-white rounded-lg shadow-lg p-8">
          <h2 class="text-2xl font-semibold text-gray-800 mb-6">新しい言葉を記録</h2>
          
          <form @submit.prevent="addWord" class="space-y-4">
            <div class="grid md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  言葉 <span class="text-red-500">*</span>
                </label>
                <input 
                  v-model="newWord.word"
                  type="text" 
                  required
                  placeholder="例: まま、ぱぱ、わんわん"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  年齢（ヶ月）
                </label>
                <input 
                  v-model.number="newWord.ageMonths"
                  type="number" 
                  min="0"
                  max="60"
                  placeholder="12"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                状況・コンテキスト
              </label>
              <textarea 
                v-model="newWord.context"
                rows="3"
                placeholder="どんな時に言ったか、どんな状況だったかを記録してください"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              ></textarea>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                きっかけ・場面
              </label>
              <select 
                v-model="newWord.occasion"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">選択してください</option>
                <option value="朝の挨拶">朝の挨拶</option>
                <option value="食事中">食事中</option>
                <option value="遊び中">遊び中</option>
                <option value="お風呂">お風呂</option>
                <option value="おやすみ">おやすみ</option>
                <option value="外出中">外出中</option>
                <option value="その他">その他</option>
              </select>
            </div>

            <button 
              type="submit" 
              class="w-full bg-blue-500 hover:bg-blue-600 text-white font-bold py-3 px-6 rounded-lg transition-colors duration-200"
            >
              🎉 記録する
            </button>
          </form>
        </div>

        <!-- Info Section -->
        <div class="bg-blue-50 rounded-lg p-6 mt-8">
          <h3 class="text-lg font-semibold text-blue-800 mb-3">📋 記録のポイント</h3>
          <ul class="text-blue-700 space-y-2 text-sm">
            <li>• 最初に発した言葉は特別な瞬間です</li>
            <li>• 状況やきっかけも一緒に記録すると後で振り返りやすくなります</li>
            <li>• 「ばぶばぶ」や「あーあー」などの赤ちゃん言葉も大切な記録です</li>
            <li>• 現在はサンプル実装です（実際のデータベース保存は未実装）</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface FirstWord {
  id: number
  word: string
  date: Date
  ageMonths: number
  context: string
  occasion: string
}

// Sample data (in real app, this would come from API/database)
const sampleWords = ref<FirstWord[]>([
  {
    id: 1,
    word: "まま",
    date: new Date("2024-01-15"),
    ageMonths: 8,
    context: "朝起きたときに突然「ままま」と言いました。最初はおしゃべりかと思いましたが、私の方を見て言っていました。",
    occasion: "朝の挨拶"
  },
  {
    id: 2,
    word: "ばいばい",
    date: new Date("2024-02-03"),
    ageMonths: 9,
    context: "おじいちゃんが帰るときに手を振りながら「ばいばい」と言いました。とても感動的でした。",
    occasion: "外出中"
  }
])

// Form data
const newWord = ref({
  word: '',
  ageMonths: 12,
  context: '',
  occasion: ''
})

// Add new word function
const addWord = () => {
  if (!newWord.value.word.trim()) {
    alert('言葉を入力してください')
    return
  }

  const word: FirstWord = {
    id: Date.now(),
    word: newWord.value.word.trim(),
    date: new Date(),
    ageMonths: newWord.value.ageMonths || 12,
    context: newWord.value.context.trim(),
    occasion: newWord.value.occasion
  }

  sampleWords.value.unshift(word)
  
  // Reset form
  newWord.value = {
    word: '',
    ageMonths: 12,
    context: '',
    occasion: ''
  }

  // Show success message
  alert('🎉 新しい言葉が記録されました！')
}

// Format date function
const formatDate = (date: Date) => {
  return date.toLocaleDateString('ja-JP', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// Page metadata
useHead({
  title: 'はじめての言葉 - Baby First Words',
  meta: [
    { name: 'description', content: '赤ちゃんの初めての言葉を記録するページ' }
  ]
})
</script>