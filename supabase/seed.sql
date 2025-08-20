-- Seed data for PlayBookings application
-- This will be used for development and testing

-- **Important notes:**
-- 1. The `auth.users` insert requires admin privileges in Supabase
-- 2. The passwords are set to 'password123' for testing (you can change these)
-- 3. The `crypt()` function with `gen_salt('bf')` properly hashes the passwords
-- 4. All the metadata fields are required for Supabase auth to work properly

-- If you don't have admin access to insert into `auth.users`, you might need to:
-- 1. Use the Supabase dashboard to create these users manually, or
-- 2. Sign up through your app's authentication flow first, then run the seed data

-- Try running this updated version and let me know if you encounter any other issues!

-- First, create users in auth.users (requires admin privileges)
-- Note: These are test users for development only
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, confirmation_token, email_change, email_change_token_new, recovery_token) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'admin@playbookings.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, '', '', '', ''),
    ('550e8400-e29b-41d4-a716-446655440002', 'venue.owner@school.edu', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, '', '', '', ''),
    ('550e8400-e29b-41d4-a716-446655440003', 'athletic.director@league.org', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, '', '', '', ''),
    ('550e8400-e29b-41d4-a716-446655440004', 'coach@club.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, '', '', '', '');

-- Now insert into public.users with conflict handling (the trigger should have created them, but we'll update if needed)
INSERT INTO public.users (id, email, role, first_name, last_name, phone) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'admin@playbookings.com', 'admin', 'Admin', 'User', '+1-555-0001'),
    ('550e8400-e29b-41d4-a716-446655440002', 'venue.owner@school.edu', 'venue_owner', 'John', 'Smith', '+1-555-0002'),
    ('550e8400-e29b-41d4-a716-446655440003', 'athletic.director@league.org', 'renter', 'Sarah', 'Johnson', '+1-555-0003'),
    ('550e8400-e29b-41d4-a716-446655440004', 'coach@club.com', 'renter', 'Mike', 'Davis', '+1-555-0004')
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    phone = EXCLUDED.phone;

-- Insert sample venues
INSERT INTO public.venues (id, name, description, address, city, state, zip_code, latitude, longitude, owner_id, hourly_rate, instant_booking, amenities) VALUES
    ('660e8400-e29b-41d4-a716-446655440001', 'St. Mary''s Gymnasium', 'Professional basketball court with hardwood floors, scoreboards, and bleacher seating for 200+ spectators.', '123 Main Street', 'Los Angeles', 'CA', '90210', 34.0522, -118.2437, '550e8400-e29b-41d4-a716-446655440002', 75.00, true, ARRAY['Basketball Court', 'Scoreboard', 'Bleachers', 'Parking', 'Restrooms', 'Water Fountains']),
    ('660e8400-e29b-41d4-a716-446655440002', 'Community Faith Center Gym', 'Multi-purpose gymnasium perfect for basketball, volleyball, and other indoor sports. Well-maintained facilities with modern equipment.', '456 Oak Avenue', 'Beverly Hills', 'CA', '90211', 34.0736, -118.4004, '550e8400-e29b-41d4-a716-446655440002', 65.00, false, ARRAY['Basketball Court', 'Volleyball Nets', 'Equipment Storage', 'Parking', 'Restrooms', 'Kitchen']);

-- Insert sample availability (next 30 days, 6 AM to 10 PM)
-- Create 2-hour availability slots to match the booking durations
INSERT INTO public.availability (venue_id, date, start_time, end_time, is_available)
SELECT 
    v.id,
    d.date,
    t.start_time,
    t.end_time,
    true  -- All slots available by default
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
        '06:00'::time + (n * 2 || ' hours')::interval AS start_time,
        '08:00'::time + (n * 2 || ' hours')::interval AS end_time
    FROM generate_series(0, 7) n  -- 6 AM to 10 PM in 2-hour blocks
) t
WHERE v.is_active = true;

-- Insert sample bookings
INSERT INTO public.bookings (venue_id, renter_id, date, start_time, end_time, status, total_amount, insurance_approved) VALUES
    ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', CURRENT_DATE + INTERVAL '2 days', '18:00', '20:00', 'confirmed', 150.00, true),
    ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', CURRENT_DATE + INTERVAL '3 days', '19:00', '21:00', 'pending', 150.00, false),
    ('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003', CURRENT_DATE + INTERVAL '5 days', '16:00', '18:00', 'confirmed', 130.00, true);

-- Insert sample insurance documents (using actual booking IDs)
INSERT INTO public.insurance_documents (booking_id, renter_id, document_url, policy_number, coverage_amount, effective_date, expiration_date, status)
SELECT 
    b.id,  -- Use the actual booking ID
    b.renter_id,
    'https://example.com/insurance' || row_number() over() || '.pdf',
    'POL-00' || row_number() over() || '-2024',
    CASE WHEN b.venue_id = '660e8400-e29b-41d4-a716-446655440001' THEN 1000000.00 ELSE 500000.00 END,
    '2024-01-01',
    '2024-12-31',
    CASE WHEN b.status = 'confirmed' THEN 'approved' ELSE 'pending' END
FROM public.bookings b
WHERE b.renter_id IN ('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004');

-- Insert sample subscriptions
INSERT INTO public.subscriptions (user_id, stripe_subscription_id, stripe_customer_id, status, current_period_start, current_period_end, trial_end) VALUES
    ('550e8400-e29b-41d4-a716-446655440002', 'sub_trial_001', 'cus_trial_001', 'trialing', CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', CURRENT_DATE + INTERVAL '6 months');

-- Insert sample messages (using actual booking IDs)
INSERT INTO public.messages (sender_id, recipient_id, booking_id, subject, content)
SELECT 
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440002',
    b.id,
    'Equipment Setup',
    'Hi! We''ll need to set up some additional equipment for our practice. Is that okay?'
FROM public.bookings b
WHERE b.renter_id = '550e8400-e29b-41d4-a716-446655440003' AND b.venue_id = '660e8400-e29b-41d4-a716-446655440001'
LIMIT 1;

INSERT INTO public.messages (sender_id, recipient_id, booking_id, subject, content)
SELECT 
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003',
    b.id,
    'Re: Equipment Setup',
    'Absolutely! Just let us know what you need and we''ll have it ready.'
FROM public.bookings b
WHERE b.renter_id = '550e8400-e29b-41d4-a716-446655440003' AND b.venue_id = '660e8400-e29b-41d4-a716-446655440001'
LIMIT 1;

INSERT INTO public.messages (sender_id, recipient_id, booking_id, subject, content)
SELECT 
    '550e8400-e29b-41d4-a716-446655440004',
    '550e8400-e29b-41d4-a716-446655440002',
    b.id,
    'Insurance Question',
    'I''m working on getting the insurance certificate. Should be ready by tomorrow.'
FROM public.bookings b
WHERE b.renter_id = '550e8400-e29b-41d4-a716-446655440004' AND b.venue_id = '660e8400-e29b-41d4-a716-446655440001'
LIMIT 1;

-- Update availability to reflect existing bookings
-- Mark all availability slots that overlap with bookings as unavailable
UPDATE public.availability 
SET is_available = false
WHERE EXISTS (
    SELECT 1 FROM public.bookings b
    WHERE b.venue_id = availability.venue_id
    AND b.date = availability.date
    AND (
        -- Check for any overlapping time between booking and availability slot
        (b.start_time < availability.end_time AND b.end_time > availability.start_time)
    )
    AND b.status IN ('confirmed', 'pending')
);
