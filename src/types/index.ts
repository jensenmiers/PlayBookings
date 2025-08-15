export type UserRole = 'venue_owner' | 'renter' | 'admin'

export interface User {
  id: string
  email: string
  role: UserRole
  first_name?: string
  last_name?: string
  phone?: string
  created_at: string
  updated_at: string
}

export interface Venue {
  id: string
  name: string
  description: string
  address: string
  city: string
  state: string
  zip_code: string
  latitude?: number
  longitude?: number
  owner_id: string
  hourly_rate: number
  instant_booking: boolean
  photos: string[]
  amenities: string[]
  created_at: string
  updated_at: string
}

export interface Availability {
  id: string
  venue_id: string
  date: string
  start_time: string
  end_time: string
  is_available: boolean
  created_at: string
}

export interface Booking {
  id: string
  venue_id: string
  renter_id: string
  date: string
  start_time: string
  end_time: string
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed'
  total_amount: number
  insurance_approved: boolean
  created_at: string
  updated_at: string
}

export interface InsuranceDocument {
  id: string
  booking_id: string
  renter_id: string
  document_url: string
  policy_number: string
  coverage_amount: number
  effective_date: string
  expiration_date: string
  status: 'pending' | 'approved' | 'rejected'
  rejection_reason?: string
  created_at: string
  updated_at: string
}

export interface AuditLog {
  id: string
  table_name: string
  record_id: string
  action: 'create' | 'update' | 'delete'
  old_values?: Record<string, any>
  new_values?: Record<string, any>
  user_id: string
  created_at: string
}
