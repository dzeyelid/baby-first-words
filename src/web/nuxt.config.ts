// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  
  // Explicitly enable pages
  pages: true,
  
  // Modules
  modules: ['@nuxtjs/tailwindcss'],
  
  // Azure Static Web Apps configuration
  nitro: {
    preset: 'azure',
    azure: {
      config: {
        platform: {
          apiRuntime: 'node:20',
        }
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
        { name: 'description', content: 'Azure Static Web Apps sample app for recording baby\'s first words' }
      ]
    }
  },

  // Environment variables
  runtimeConfig: {
    AzureWebJobsStorage: "UseDevelopmentStorage=true",
  },
})
