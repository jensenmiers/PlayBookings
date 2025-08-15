import * as z from 'zod'

export const venueSchema = z.object({
  name: z.string().min(1, 'Venue name is required'),
  description: z.string().min(10, 'Description must be at least 10 characters'),
  address: z.string().min(1, 'Address is required'),
  city: z.string().min(1, 'City is required'),
  state: z.string().length(2, 'State must be 2 characters'),
  zipCode: z.string().regex(/^\d{5}(-\d{4})?$/, 'Invalid ZIP code format'),
  hourlyRate: z.number().min(1, 'Hourly rate must be at least $1'),
  instantBooking: z.boolean(),
  amenities: z.array(z.string()).min(1, 'At least one amenity is required'),
})

export const availabilitySchema = z.object({
  date: z.string().min(1, 'Date is required'),
  startTime: z.string().min(1, 'Start time is required'),
  endTime: z.string().min(1, 'End time is required'),
})

export type VenueInput = z.infer<typeof venueSchema>
export type AvailabilityInput = z.infer<typeof availabilitySchema>
