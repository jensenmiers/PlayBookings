-- Seed data for PlayBookings application
-- This will be used for development and testing

-- Insert sample users (these would normally be created through auth signup)
INSERT INTO public.users (id, email, role, first_name, last_name, phone) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'admin@playbookings.com', 'admin', 'Admin', 'User', '+1-555-0001'),
    ('550e8400-e29b-41d4-a716-446655440002', 'venue.owner@school.edu', 'venue_owner', 'John', 'Smith', '+1-555-0002'),
    ('550e8400-e29b-41d4-a716-446655440003', 'athletic.director@league.org', 'renter', 'Sarah', 'Johnson', '+1-555-0003'),
    ('550e8400-e29b-41d4-a716-446655440004', 'coach@club.com', 'renter', 'Mike', 'Davis', '+1-555-0004');

-- Insert sample venues
INSERT INTO public.venues (id, name, description, address, city, state, zip_code, latitude, longitude, owner_id, hourly_rate, instant_booking, amenities) VALUES
    ('660e8400-e29b-41d4-a716-446655440001', 'St. Mary\'s Gymnasium', 'Professional basketball court with hardwood floors, scoreboards, and bleacher seating for 200+ spectators.', '123 Main Street', 'Los Angeles', 'CA', '90210', 34.0522, -118.2437, '550e8400-e29b-41d4-a716-446655440002', 75.00, true, ARRAY['Basketball Court', 'Scoreboard', 'Bleachers', 'Parking', 'Restrooms', 'Water Fountains']),
    ('660e8400-e29b-41d4-a716-446655440002', 'Community Faith Center Gym', 'Multi-purpose gymnasium perfect for basketball, volleyball, and other indoor sports. Well-maintained facilities with modern equipment.', '456 Oak Avenue', 'Beverly Hills', 'CA', '90211', 34.0736, -118.4004, '550e8400-e29b-41d4-a716-446655440002', 65.00, false, ARRAY['Basketball Court', 'Volleyball Nets', 'Equipment Storage', 'Parking', 'Restrooms', 'Kitchen']);

-- Insert sample availability (next 30 days, 6 AM to 10 PM)
INSERT INTO public.availability (venue_id, date, start_time, end_time, is_available)
SELECT 
    v.id,
    d.date,
    t.start_time,
    t.end_time,
    CASE 
        WHEN t.start_time >= '18:00' AND t.start_time <= '21:00' THEN false  -- Evening slots often booked
        ELSE true
    END
FROM public.venues v
CROSS JOIN (
    SELECT generate_series(
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '30 days',
        INTERVAL '1 day'
    )::date AS date
) d
CROSS JOIN (
    SELECT 
        '06:00'::time + (n || ' hours')::interval AS start_time,
        '07:00'::time + (n || ' hours')::interval AS end_time
    FROM generate_series(0, 15) n
) t
WHERE v.is_active = true;

-- Insert sample bookings
INSERT INTO public.bookings (venue_id, renter_id, date, start_time, end_time, status, total_amount, insurance_approved) VALUES
    ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', CURRENT_DATE + INTERVAL '2 days', '18:00', '20:00', 'confirmed', 150.00, true),
    ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', CURRENT_DATE + INTERVAL '3 days', '19:00', '21:00', 'pending', 150.00, false),
    ('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003', CURRENT_DATE + INTERVAL '5 days', '16:00', '18:00', 'confirmed', 130.00, true);

-- Insert sample insurance documents
INSERT INTO public.insurance_documents (booking_id, renter_id, document_url, policy_number, coverage_amount, effective_date, expiration_date, status) VALUES
    ('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', 'https://example.com/insurance1.pdf', 'POL-001-2024', 1000000.00, '2024-01-01', '2024-12-31', 'approved'),
    ('770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', 'https://example.com/insurance2.pdf', 'POL-002-2024', 500000.00, '2024-01-01', '2024-12-31', 'pending'),
    ('770e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'https://example.com/insurance3.pdf', 'POL-001-2024', 1000000.00, '2024-01-01', '2024-12-31', 'approved');

-- Insert sample subscriptions
INSERT INTO public.subscriptions (user_id, stripe_subscription_id, stripe_customer_id, status, current_period_start, current_period_end, trial_end) VALUES
    ('550e8400-e29b-41d4-a716-446655440002', 'sub_trial_001', 'cus_trial_001', 'trialing', CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', CURRENT_DATE + INTERVAL '6 months');

-- Insert sample messages
INSERT INTO public.messages (sender_id, recipient_id, booking_id, subject, content) VALUES
    ('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440001', 'Equipment Setup', 'Hi! We\'ll need to set up some additional equipment for our practice. Is that okay?'),
    ('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440001', 'Re: Equipment Setup', 'Absolutely! Just let us know what you need and we\'ll have it ready.'),
    ('550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440002', 'Insurance Question', 'I\'m working on getting the insurance certificate. Should be ready by tomorrow.');

-- Update availability to reflect existing bookings
UPDATE public.availability 
SET is_available = false
WHERE EXISTS (
    SELECT 1 FROM public.bookings b
    WHERE b.venue_id = availability.venue_id
    AND b.date = availability.date
    AND b.start_time <= availability.start_time
    AND b.end_time >= availability.end_time
    AND b.status IN ('confirmed', 'pending')
);
