// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  
  // Modules
  modules: ['@nuxtjs/tailwindcss'],
  
  // Azure Static Web Apps configuration
  nitro: {
    preset: 'azure-functions',
    azure: {
      functions: {
        functionAppName: 'baby-first-words'
      }
    }
  },
  
  // App configuration
  app: {
    head: {
      title: 'Baby First Words - はじめての言葉',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { hid: 'description', name: 'description', content: 'Azure Static Web Apps sample app for recording baby\'s first words' }
      ]
    }
  }
})
