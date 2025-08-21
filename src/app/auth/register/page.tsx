'use client'

import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import { useState } from 'react'
import Link from 'next/link'

type UserRole = 'venue_owner' | 'renter'

export default function RegisterPage() {
  const [loading, setLoading] = useState(false)
  const [selectedRole, setSelectedRole] = useState<UserRole>('renter')
  const router = useRouter()
  const supabase = createClient()

  const handleGoogleSignup = async () => {
    try {
      setLoading(true)
      
      // Store the selected role in localStorage to use after OAuth callback
      localStorage.setItem('pendingUserRole', selectedRole)
      
      const { error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/auth/callback`,
        },
      })
      
      if (error) {
        console.error('Error during authentication:', error.message)
        alert('Error during authentication: ' + error.message)
      }
    } catch (error) {
      console.error('Unexpected error:', error)
      alert('An unexpected error occurred')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-green-50 flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center space-y-2">
          <CardTitle className="text-2xl font-bold">Join PlayBookings</CardTitle>
          <CardDescription>
            Get started by selecting your role
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Role Selection */}
          <div className="space-y-3">
            <Label className="text-sm font-medium">I want to:</Label>
            <div className="space-y-2">
              <div 
                className={`p-4 border rounded-lg cursor-pointer transition-colors ${
                  selectedRole === 'renter' 
                    ? 'border-blue-500 bg-blue-50' 
                    : 'border-gray-200 hover:border-gray-300'
                }`}
                onClick={() => setSelectedRole('renter')}
              >
                <div className="flex items-center space-x-3">
                  <input
                    type="radio"
                    checked={selectedRole === 'renter'}
                    onChange={() => setSelectedRole('renter')}
                    className="text-blue-600"
                  />
                  <div>
                    <div className="font-medium">Rent Courts</div>
                    <div className="text-sm text-gray-600">
                      Book basketball courts for teams, leagues, or events
                    </div>
                  </div>
                </div>
              </div>
              
              <div 
                className={`p-4 border rounded-lg cursor-pointer transition-colors ${
                  selectedRole === 'venue_owner' 
                    ? 'border-blue-500 bg-blue-50' 
                    : 'border-gray-200 hover:border-gray-300'
                }`}
                onClick={() => setSelectedRole('venue_owner')}
              >
                <div className="flex items-center space-x-3">
                  <input
                    type="radio"
                    checked={selectedRole === 'venue_owner'}
                    onChange={() => setSelectedRole('venue_owner')}
                    className="text-blue-600"
                  />
                  <div>
                    <div className="font-medium">List My Venue</div>
                    <div className="text-sm text-gray-600">
                      Generate revenue from unused court time
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <Button
            onClick={handleGoogleSignup}
            disabled={loading}
            className="w-full bg-blue-600 hover:bg-blue-700"
            size="lg"
          >
            {loading ? (
              <div className="flex items-center space-x-2">
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                <span>Creating account...</span>
              </div>
            ) : (
              <div className="flex items-center space-x-2">
                <svg className="w-5 h-5" viewBox="0 0 24 24">
                  <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                  <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                  <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                  <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                <span>Continue with Google</span>
              </div>
            )}
          </Button>
          
          <div className="text-center text-sm text-gray-600">
            Already have an account?{' '}
            <Link href="/auth/login" className="text-blue-600 hover:underline">
              Sign in here
            </Link>
          </div>
          
          <div className="text-center">
            <Link href="/marketing" className="text-sm text-gray-500 hover:underline">
              Back to Home
            </Link>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
