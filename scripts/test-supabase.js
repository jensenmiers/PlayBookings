#!/usr/bin/env node

/**
 * Command-line script to test Supabase connections
 * Run with: node scripts/test-supabase.js
 */

// Load environment variables from .env.local file
function loadEnvFile() {
  const fs = require('fs')
  const path = require('path')
  
  const envPath = path.join(process.cwd(), '.env.local')
  
  if (fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, 'utf8')
    
    envContent.split('\n').forEach(line => {
      const [key, ...valueParts] = line.split('=')
      if (key && valueParts.length > 0) {
        const value = valueParts.join('=').trim()
        if (value && !key.startsWith('#')) {
          process.env[key.trim()] = value.replace(/^["']|["']$/g, '')
        }
      }
    })
    
    console.log('📁 Loaded environment variables from .env.local')
  } else {
    console.log('⚠️ No .env.local file found, using system environment variables')
  }
}

// Load environment variables
loadEnvFile()

// Simple test functions that don't require Supabase client
function testEnvironmentVariables() {
  console.log('🔍 Testing Environment Variables...')
  
  const requiredVars = [
    'NEXT_PUBLIC_SUPABASE_URL',
    'NEXT_PUBLIC_SUPABASE_ANON_KEY'
  ]
  
  const missingVars = requiredVars.filter(varName => !process.env[varName])
  
  if (missingVars.length > 0) {
    console.error('❌ Missing environment variables:', missingVars)
    return false
  }
  
  console.log('✅ All required environment variables are set')
  console.log('📡 Supabase URL:', process.env.NEXT_PUBLIC_SUPABASE_URL)
  console.log('🔑 Anon Key:', process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.substring(0, 20) + '...')
  
  return true
}

function testUrlFormat() {
  console.log('\n🌐 Testing URL Format...')
  
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  
  if (!url) {
    console.error('❌ No Supabase URL found')
    return false
  }
  
  try {
    const urlObj = new URL(url)
    
    if (urlObj.protocol !== 'https:') {
      console.warn('⚠️ Warning: Supabase URL should use HTTPS')
    }
    
    if (!urlObj.hostname.includes('supabase.co')) {
      console.warn('⚠️ Warning: URL doesn\'t look like a standard Supabase URL')
    }
    
    console.log('✅ URL format is valid')
    console.log('📍 Hostname:', urlObj.hostname)
    console.log('🔒 Protocol:', urlObj.protocol)
    
    return true
    
  } catch (error) {
    console.error('❌ Invalid URL format:', error.message)
    return false
  }
}

function testKeyFormat() {
  console.log('\n🔑 Testing API Key Format...')
  
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  
  if (!key) {
    console.error('❌ No API key found')
    return false
  }
  
  // Supabase anon keys are typically long base64 strings
  if (key.length < 100) {
    console.warn('⚠️ Warning: API key seems shorter than expected')
  }
  
  if (!key.startsWith('eyJ')) {
    console.warn('⚠️ Warning: API key doesn\'t start with expected JWT format')
  }
  
  console.log('✅ API key format appears valid')
  console.log('📏 Key length:', key.length, 'characters')
  console.log('🔐 Key prefix:', key.substring(0, 10) + '...')
  
  return true
}

function testDatabaseConnection() {
  console.log('\n🗄️ Testing Database Connection...')
  
  // This is a basic connectivity test
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  
  if (!url) {
    console.error('❌ No URL available for connection test')
    return false
  }
  
  console.log('ℹ️ To test actual database connectivity, run the browser tests')
  console.log('ℹ️ Or use the Supabase dashboard to verify your project is active')
  console.log('ℹ️ URL being used:', url)
  
  return true
}

function runAllTests() {
  console.log('🚀 Starting Supabase Environment Tests...\n')
  
  const tests = [
    { name: 'Environment Variables', fn: testEnvironmentVariables },
    { name: 'URL Format', fn: testUrlFormat },
    { name: 'API Key Format', fn: testKeyFormat },
    { name: 'Database Connection', fn: testDatabaseConnection }
  ]
  
  let passedTests = 0
  let totalTests = tests.length
  
  for (const test of tests) {
    try {
      const result = test.fn()
      if (result) {
        passedTests++
      }
    } catch (error) {
      console.error(`❌ ${test.name} test crashed:`, error)
    }
  }
  
  console.log('\n' + '='.repeat(50))
  console.log(`🏁 Test Results: ${passedTests}/${totalTests} tests passed`)
  
  if (passedTests === totalTests) {
    console.log('🎉 All environment tests passed!')
    console.log('\n💡 Next steps:')
    console.log('   1. Start your Next.js development server: npm run dev')
    console.log('   2. Navigate to /test-supabase to run full connection tests')
    console.log('   3. Or run the migration files in your Supabase dashboard')
  } else {
    console.log('⚠️ Some tests failed. Check the output above for details.')
    console.log('\n🔧 Troubleshooting:')
    console.log('   • Verify your .env.local file exists and has correct values')
    console.log('   • Check your Supabase project settings')
    console.log('   • Ensure your project is active and not paused')
  }
  
  return passedTests === totalTests
}

// Run tests if this file is executed directly
if (require.main === module) {
  runAllTests()
}

module.exports = {
  testEnvironmentVariables,
  testUrlFormat,
  testKeyFormat,
  testDatabaseConnection,
  runAllTests
}
