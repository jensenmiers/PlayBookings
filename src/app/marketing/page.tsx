import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Calendar, MapPin, Shield, Users } from 'lucide-react'
import Link from 'next/link'
import { Navigation } from '@/components/layout/navigation'

export default function MarketingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-green-50">
      <Navigation />
      {/* Hero Section */}
      <section className="px-4 py-20 text-center">
        <div className="mx-auto max-w-4xl">
          <h1 className="mb-6 text-5xl font-bold text-gray-900 md:text-6xl">
            Streamline Your{' '}
            <span className="bg-gradient-to-r from-blue-600 to-green-600 bg-clip-text text-transparent">
              Gym Rentals
            </span>
          </h1>
          <p className="mb-8 text-xl text-gray-600">
            Connect underutilized indoor basketball courts with trusted renters. 
            Generate revenue, reduce admin work, and strengthen community engagement.
          </p>
          <div className="flex flex-col gap-4 sm:flex-row sm:justify-center">
            <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700">
              <Link href="/auth/register">Get Started</Link>
            </Button>
            <Button asChild variant="outline" size="lg">
              <Link href="/auth/login">Sign In</Link>
            </Button>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="px-4 py-20">
        <div className="mx-auto max-w-6xl">
          <h2 className="mb-16 text-center text-3xl font-bold text-gray-900">
            Why Choose PlayBookings?
          </h2>
          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4">
            <Card className="text-center">
              <CardHeader>
                <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-blue-100">
                  <Calendar className="h-8 w-8 text-blue-600" />
                </div>
                <CardTitle>Easy Scheduling</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>
                  Manage availability with our intuitive calendar system. Set custom pricing and instant booking options.
                </CardDescription>
              </CardContent>
            </Card>

            <Card className="text-center">
              <CardHeader>
                <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
                  <Shield className="h-8 w-8 text-green-600" />
                </div>
                <CardTitle>Trust & Safety</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>
                  Vetted renters and insurance verification ensure your facility is protected.
                </CardDescription>
              </CardContent>
            </Card>

            <Card className="text-center">
              <CardHeader>
                <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-purple-100">
                  <Users className="h-8 w-8 text-purple-600" />
                </div>
                <CardTitle>Community Connection</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>
                  Connect with athletic directors, league coordinators, and club sports managers.
                </CardDescription>
              </CardContent>
            </Card>

            <Card className="text-center">
              <CardHeader>
                <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-orange-100">
                  <MapPin className="h-8 w-8 text-orange-600" />
                </div>
                <CardTitle>Local Focus</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>
                  Focus on Los Angeles County with plans to expand throughout Southern California.
                </CardDescription>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="px-4 py-20">
        <div className="mx-auto max-w-4xl text-center">
          <h2 className="mb-6 text-3xl font-bold text-gray-900">
            Ready to Transform Your Gym Rental Process?
          </h2>
          <p className="mb-8 text-xl text-gray-600">
            Join the growing network of venues and renters using PlayBookings.
          </p>
          <Button asChild size="lg" className="bg-green-600 hover:bg-green-700">
            <Link href="/auth/register">Start Today</Link>
          </Button>
        </div>
      </section>
    </div>
  )
}
