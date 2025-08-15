'use client'

import { Button } from '@/components/ui/button'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

export function Navigation() {
  const pathname = usePathname()

  return (
    <nav className="border-b bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/60">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4">
        <Link href="/" className="flex items-center space-x-2">
          <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-blue-600 to-green-600" />
          <span className="text-xl font-bold text-gray-900">PlayBookings</span>
        </Link>

        <div className="hidden md:flex md:items-center md:space-x-6">
          <Link
            href="/marketing"
            className={`text-sm font-medium transition-colors hover:text-blue-600 ${
              pathname === '/marketing' ? 'text-blue-600' : 'text-gray-600'
            }`}
          >
            Home
          </Link>
          <Link
            href="/auth/login"
            className="text-sm font-medium text-gray-600 transition-colors hover:text-blue-600"
          >
            Sign In
          </Link>
          <Button asChild>
            <Link href="/auth/register">Get Started</Link>
          </Button>
        </div>

        {/* Mobile menu button */}
        <Button variant="ghost" size="sm" className="md:hidden">
          <svg
            className="h-6 w-6"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M4 6h16M4 12h16M4 18h16"
            />
          </svg>
        </Button>
      </div>
    </nav>
  )
}
