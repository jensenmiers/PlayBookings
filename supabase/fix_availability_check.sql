-- Fix for booking availability check to handle bookings that span multiple slots
-- Run this in Supabase SQL editor to update the existing functions

-- Update the check_booking_conflicts function to handle span-multiple-slots bookings
CREATE OR REPLACE FUNCTION check_booking_conflicts()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the new booking conflicts with existing bookings
    IF EXISTS (
        SELECT 1 FROM public.bookings 
        WHERE venue_id = NEW.venue_id 
        AND date = NEW.date 
        AND status IN ('confirmed', 'pending')
        AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
        AND (
            (NEW.start_time < end_time AND NEW.end_time > start_time)
        )
    ) THEN
        RAISE EXCEPTION 'Booking time conflicts with existing booking';
    END IF;
    
    -- Check if the new booking conflicts with recurring bookings
    IF EXISTS (
        SELECT 1 FROM public.recurring_bookings 
        WHERE venue_id = NEW.venue_id 
        AND date = NEW.date 
        AND status IN ('confirmed', 'pending')
        AND (
            (NEW.start_time < end_time AND NEW.end_time > start_time)
        )
    ) THEN
        RAISE EXCEPTION 'Booking time conflicts with existing recurring booking';
    END IF;
    
    -- Check if the time slot is available
    -- For bookings that span multiple slots, ensure all overlapping slots are available
    IF EXISTS (
        SELECT 1 FROM public.availability 
        WHERE venue_id = NEW.venue_id 
        AND date = NEW.date 
        AND (
            -- Check for any overlapping time slots that are not available
            (start_time < NEW.end_time AND end_time > NEW.start_time)
        )
        AND is_available = false
    ) THEN
        RAISE EXCEPTION 'Requested time slot is not available';
    END IF;
    
    -- Also ensure there is at least some availability coverage for the requested time
    IF NOT EXISTS (
        SELECT 1 FROM public.availability 
        WHERE venue_id = NEW.venue_id 
        AND date = NEW.date 
        AND (
            -- Check for any overlapping time slots that are available
            (start_time < NEW.end_time AND end_time > NEW.start_time)
        )
        AND is_available = true
    ) THEN
        RAISE EXCEPTION 'Requested time slot is not available';
    END IF;
    
    -- Check advance booking policy
    IF NEW.date > CURRENT_DATE + (SELECT max_advance_booking_days FROM public.venues WHERE id = NEW.venue_id) THEN
        RAISE EXCEPTION 'Booking exceeds maximum advance booking period';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Update the check_recurring_booking_conflicts function to handle span-multiple-slots bookings
CREATE OR REPLACE FUNCTION check_recurring_booking_conflicts()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the new recurring booking conflicts with existing bookings
    IF EXISTS (
        SELECT 1 FROM public.bookings 
        WHERE venue_id = NEW.venue_id 
        AND date = NEW.date 
        AND status IN ('confirmed', 'pending')
        AND (
            (NEW.start_time < end_time AND NEW.end_time > start_time)
        )
    ) THEN
        RAISE EXCEPTION 'Recurring booking time conflicts with existing booking';
    END IF;
    
    -- Check if the new recurring booking conflicts with other recurring bookings
    IF EXISTS (
        SELECT 1 FROM public.recurring_bookings 
        WHERE venue_id = NEW.venue_id 
        AND date = NEW.date 
        AND status IN ('confirmed', 'pending')
        AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
        AND (
            (NEW.start_time < end_time AND NEW.end_time > start_time)
        )
    ) THEN
        RAISE EXCEPTION 'Recurring booking time conflicts with existing recurring booking';
    END IF;
    
    -- Check if the time slot is available
    -- For bookings that span multiple slots, ensure all overlapping slots are available
    IF EXISTS (
        SELECT 1 FROM public.availability 
        WHERE venue_id = NEW.venue_id 
        AND date = NEW.date 
        AND (
            -- Check for any overlapping time slots that are not available
            (start_time < NEW.end_time AND end_time > NEW.start_time)
        )
        AND is_available = false
    ) THEN
        RAISE EXCEPTION 'Requested recurring booking time slot is not available';
    END IF;
    
    -- Also ensure there is at least some availability coverage for the requested time
    IF NOT EXISTS (
        SELECT 1 FROM public.availability 
        WHERE venue_id = NEW.venue_id 
        AND date = NEW.date 
        AND (
            -- Check for any overlapping time slots that are available
            (start_time < NEW.end_time AND end_time > NEW.start_time)
        )
        AND is_available = true
    ) THEN
        RAISE EXCEPTION 'Requested recurring booking time slot is not available';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
