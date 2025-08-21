'use client'

import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'

export default function AuthCallbackPage() {
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')
  const [errorMessage, setErrorMessage] = useState('')
  const router = useRouter()
  const supabase = createClient()

  useEffect(() => {
    const handleAuthCallback = async () => {
      try {
        const { data, error } = await supabase.auth.getSession()
        
        if (error) {
          console.error('Auth callback error:', error)
          setErrorMessage(error.message)
          setStatus('error')
          return
        }

        if (data.session) {
          const user = data.session.user
          console.log('User authenticated:', user.email)

          // Check if we have a pending role selection from registration
          const pendingRole = localStorage.getItem('pendingUserRole')
          
          if (pendingRole) {
            // This is a new user registration - create user profile with role
            const { error: profileError } = await supabase
              .from('users')
              .upsert({
                id: user.id,
                email: user.email,
                full_name: user.user_metadata.full_name,
                avatar_url: user.user_metadata.avatar_url,
                role: pendingRole,
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
              })

            if (profileError) {
              console.error('Error creating user profile:', profileError)
              // Still proceed to dashboard even if profile creation fails
            }

            // Clear the pending role
            localStorage.removeItem('pendingUserRole')
          }

          setStatus('success')
          
          // Redirect to dashboard after a brief success message
          setTimeout(() => {
            router.push('/dashboard')
          }, 2000)
        } else {
          setErrorMessage('No session found')
          setStatus('error')
        }
      } catch (error) {
        console.error('Unexpected error in auth callback:', error)
        setErrorMessage('An unexpected error occurred')
        setStatus('error')
      }
    }

    handleAuthCallback()
  }, [supabase, router])

  if (status === 'loading') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-green-50 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto" />
          <h2 className="text-xl font-semibold text-gray-900">Signing you in...</h2>
          <p className="text-gray-600">Please wait while we complete your authentication.</p>
        </div>
      </div>
    )
  }

  if (status === 'success') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-green-50 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto">
            <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <h2 className="text-xl font-semibold text-gray-900">Welcome to PlayBookings!</h2>
          <p className="text-gray-600">Redirecting you to your dashboard...</p>
        </div>
      </div>
    )
  }

  if (status === 'error') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-green-50 flex items-center justify-center">
        <div className="text-center space-y-4 max-w-md mx-auto p-6">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto">
            <svg className="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </div>
          <h2 className="text-xl font-semibold text-gray-900">Authentication Error</h2>
          <p className="text-gray-600">{errorMessage}</p>
          <button
            onClick={() => router.push('/auth/login')}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            Try Again
          </button>
        </div>
      </div>
    )
  }

  return null
}
