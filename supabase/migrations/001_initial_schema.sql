-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE user_role AS ENUM ('venue_owner', 'renter', 'admin');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');
CREATE TYPE insurance_status AS ENUM ('pending', 'approved', 'rejected', 'needs_changes');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'refunded', 'failed');
CREATE TYPE recurring_type AS ENUM ('none', 'weekly', 'monthly');

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    role user_role NOT NULL DEFAULT 'renter',
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Venues table
CREATE TABLE public.venues (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    owner_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    hourly_rate DECIMAL(10, 2) NOT NULL CHECK (hourly_rate > 0),
    instant_booking BOOLEAN DEFAULT false,
    insurance_required BOOLEAN DEFAULT true,
    max_advance_booking_days INTEGER DEFAULT 180 CHECK (max_advance_booking_days > 0),
    photos TEXT[] DEFAULT '{}',
    amenities TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Availability table for hourly blocks
CREATE TABLE public.availability (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    venue_id UUID NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(venue_id, date, start_time, end_time),
    CONSTRAINT check_availability_times CHECK (start_time < end_time)
);

-- Bookings table
CREATE TABLE public.bookings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    venue_id UUID NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
    renter_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status booking_status DEFAULT 'pending',
    total_amount DECIMAL(10, 2) NOT NULL,
    insurance_approved BOOLEAN DEFAULT false,
    insurance_required BOOLEAN DEFAULT true,
    recurring_type recurring_type DEFAULT 'none',
    recurring_end_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_booking_times CHECK (start_time < end_time),
    CONSTRAINT check_booking_date_advance CHECK (
        date <= CURRENT_DATE + INTERVAL '180 days'
    )
);

-- Recurring bookings table for weekly/monthly patterns
CREATE TABLE public.recurring_bookings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    parent_booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    venue_id UUID NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
    renter_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status booking_status DEFAULT 'pending',
    total_amount DECIMAL(10, 2) NOT NULL,
    insurance_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_recurring_booking_times CHECK (start_time < end_time)
);

-- Insurance documents table
CREATE TABLE public.insurance_documents (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    renter_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    document_url TEXT NOT NULL,
    policy_number TEXT,
    coverage_amount DECIMAL(12, 2),
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    status insurance_status DEFAULT 'pending',
    rejection_reason TEXT,
    reviewed_by UUID REFERENCES public.users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_insurance_dates CHECK (effective_date < expiration_date)
);

-- Payments table for tracking financial transactions
CREATE TABLE public.payments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    renter_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    venue_id UUID NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
    stripe_payment_intent_id TEXT UNIQUE,
    stripe_transfer_id TEXT,
    amount DECIMAL(10, 2) NOT NULL,
    platform_fee DECIMAL(10, 2) NOT NULL DEFAULT 0,
    venue_owner_amount DECIMAL(10, 2) NOT NULL,
    status payment_status DEFAULT 'pending',
    paid_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE,
    refund_amount DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit logs table for comprehensive tracking
CREATE TABLE public.audit_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('create', 'update', 'delete')),
    old_values JSONB,
    new_values JSONB,
    user_id UUID NOT NULL REFERENCES public.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subscriptions table for venue owners
CREATE TABLE public.subscriptions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    stripe_subscription_id TEXT UNIQUE,
    stripe_customer_id TEXT,
    status TEXT NOT NULL,
    current_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    trial_end TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_subscription_dates CHECK (current_period_start < current_period_end)
);

-- Messages table for communication between users
CREATE TABLE public.messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
    subject TEXT,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_venues_owner_id ON public.venues(owner_id);
CREATE INDEX idx_venues_location ON public.venues(city, state);
CREATE INDEX idx_venues_insurance_required ON public.venues(insurance_required);
CREATE INDEX idx_availability_venue_date ON public.availability(venue_id, date);
CREATE INDEX idx_bookings_venue_date ON public.bookings(venue_id, date);
CREATE INDEX idx_bookings_renter_id ON public.bookings(renter_id);
CREATE INDEX idx_bookings_status ON public.bookings(status);
CREATE INDEX idx_bookings_venue_time ON public.bookings(venue_id, date, start_time, end_time);
CREATE INDEX idx_bookings_recurring ON public.bookings(recurring_type, recurring_end_date);
CREATE INDEX idx_recurring_bookings_venue_date ON public.recurring_bookings(venue_id, date);
CREATE INDEX idx_recurring_bookings_parent ON public.recurring_bookings(parent_booking_id);
CREATE INDEX idx_insurance_booking_id ON public.insurance_documents(booking_id);
CREATE INDEX idx_insurance_status ON public.insurance_documents(status);
CREATE INDEX idx_payments_booking_id ON public.payments(booking_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_audit_logs_table_record ON public.audit_logs(table_name, record_id);
CREATE INDEX idx_messages_sender_recipient ON public.messages(sender_id, recipient_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_venues_updated_at BEFORE UPDATE ON public.venues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_recurring_bookings_updated_at BEFORE UPDATE ON public.recurring_bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_insurance_documents_updated_at BEFORE UPDATE ON public.insurance_documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to check booking conflicts
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
    IF NOT EXISTS (
        SELECT 1 FROM public.availability 
        WHERE venue_id = NEW.venue_id 
        AND date = NEW.date 
        AND start_time <= NEW.start_time 
        AND end_time >= NEW.end_time 
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

-- Apply booking conflict check trigger
CREATE TRIGGER check_booking_conflicts_trigger 
    BEFORE INSERT OR UPDATE ON public.bookings 
    FOR EACH ROW EXECUTE FUNCTION check_booking_conflicts();

-- Create function to check recurring booking conflicts
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
    IF NOT EXISTS (
        SELECT 1 FROM public.availability 
        WHERE venue_id = NEW.venue_id 
        AND date = NEW.date 
        AND start_time <= NEW.start_time 
        AND end_time >= NEW.end_time 
        AND is_available = true
    ) THEN
        RAISE EXCEPTION 'Requested recurring booking time slot is not available';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply recurring booking conflict check trigger
CREATE TRIGGER check_recurring_booking_conflicts_trigger 
    BEFORE INSERT OR UPDATE ON public.recurring_bookings 
    FOR EACH ROW EXECUTE FUNCTION check_recurring_booking_conflicts();

-- Create function to log audit trails with proper user identification
CREATE OR REPLACE FUNCTION log_audit_trail()
RETURNS TRIGGER AS $$
DECLARE
    user_id_value UUID;
BEGIN
    -- Determine the user ID based on the table being audited
    IF TG_TABLE_NAME = 'venues' THEN
        user_id_value := COALESCE(NEW.owner_id, OLD.owner_id);
    ELSIF TG_TABLE_NAME IN ('bookings', 'recurring_bookings') THEN
        user_id_value := COALESCE(NEW.renter_id, OLD.renter_id);
    ELSIF TG_TABLE_NAME = 'insurance_documents' THEN
        user_id_value := COALESCE(NEW.renter_id, OLD.renter_id);
    ELSIF TG_TABLE_NAME = 'payments' THEN
        user_id_value := COALESCE(NEW.renter_id, OLD.renter_id);
    ELSIF TG_TABLE_NAME = 'subscriptions' THEN
        user_id_value := COALESCE(NEW.user_id, OLD.user_id);
    ELSIF TG_TABLE_NAME = 'messages' THEN
        user_id_value := COALESCE(NEW.sender_id, OLD.sender_id);
    ELSIF TG_TABLE_NAME = 'users' THEN
        user_id_value := COALESCE(NEW.id, OLD.id);
    ELSE
        -- For tables without clear user ownership, use a default or skip
        user_id_value := NULL;
    END IF;
    
    -- Only log if we have a valid user ID
    IF user_id_value IS NOT NULL THEN
        IF TG_OP = 'INSERT' THEN
            INSERT INTO public.audit_logs (table_name, record_id, action, new_values, user_id)
            VALUES (TG_TABLE_NAME, NEW.id, 'create', to_jsonb(NEW), user_id_value);
            RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
            INSERT INTO public.audit_logs (table_name, record_id, action, old_values, new_values, user_id)
            VALUES (TG_TABLE_NAME, NEW.id, 'update', to_jsonb(OLD), to_jsonb(NEW), user_id_value);
            RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
            INSERT INTO public.audit_logs (table_name, record_id, action, old_values, user_id)
            VALUES (TG_TABLE_NAME, OLD.id, 'delete', to_jsonb(OLD), user_id_value);
            RETURN OLD;
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply audit logging triggers
CREATE TRIGGER audit_venues_trigger AFTER INSERT OR UPDATE OR DELETE ON public.venues FOR EACH ROW EXECUTE FUNCTION log_audit_trail();
CREATE TRIGGER audit_bookings_trigger AFTER INSERT OR UPDATE OR DELETE ON public.bookings FOR EACH ROW EXECUTE FUNCTION log_audit_trail();
CREATE TRIGGER audit_recurring_bookings_trigger AFTER INSERT OR UPDATE OR DELETE ON public.recurring_bookings FOR EACH ROW EXECUTE FUNCTION log_audit_trail();
CREATE TRIGGER audit_insurance_trigger AFTER INSERT OR UPDATE OR DELETE ON public.insurance_documents FOR EACH ROW EXECUTE FUNCTION log_audit_trail();
CREATE TRIGGER audit_payments_trigger AFTER INSERT OR UPDATE OR DELETE ON public.payments FOR EACH ROW EXECUTE FUNCTION log_audit_trail();
CREATE TRIGGER audit_subscriptions_trigger AFTER INSERT OR UPDATE OR DELETE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION log_audit_trail();
CREATE TRIGGER audit_messages_trigger AFTER INSERT OR UPDATE OR DELETE ON public.messages FOR EACH ROW EXECUTE FUNCTION log_audit_trail();
CREATE TRIGGER audit_users_trigger AFTER INSERT OR UPDATE OR DELETE ON public.users FOR EACH ROW EXECUTE FUNCTION log_audit_trail();

-- Create function to handle user creation after auth signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, role)
    VALUES (NEW.id, NEW.email, 'renter');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create user profile
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create function to generate recurring bookings
CREATE OR REPLACE FUNCTION generate_recurring_bookings()
RETURNS TRIGGER AS $$
DECLARE
    current_date DATE;
    end_date DATE;
    booking_date DATE;
BEGIN
    -- Only process if this is a recurring booking
    IF NEW.recurring_type = 'none' THEN
        RETURN NEW;
    END IF;
    
    -- Set the end date (3 months for weekly, 6 months for monthly)
    IF NEW.recurring_type = 'weekly' THEN
        end_date := NEW.date + INTERVAL '3 months';
    ELSIF NEW.recurring_type = 'monthly' THEN
        end_date := NEW.date + INTERVAL '6 months';
    END IF;
    
    -- Generate individual recurring bookings
    current_date := NEW.date;
    WHILE current_date <= end_date LOOP
        -- Skip the original date as it's already in the main bookings table
        IF current_date != NEW.date THEN
            INSERT INTO public.recurring_bookings (
                parent_booking_id, venue_id, renter_id, date, start_time, end_time,
                status, total_amount, insurance_approved, insurance_required
            ) VALUES (
                NEW.id, NEW.venue_id, NEW.renter_id, current_date, NEW.start_time, NEW.end_time,
                'pending', NEW.total_amount, NEW.insurance_approved, NEW.insurance_required
            );
        END IF;
        
        -- Move to next occurrence
        IF NEW.recurring_type = 'weekly' THEN
            current_date := current_date + INTERVAL '1 week';
        ELSIF NEW.recurring_type = 'monthly' THEN
            current_date := current_date + INTERVAL '1 month';
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply recurring booking generation trigger
CREATE TRIGGER generate_recurring_bookings_trigger 
    AFTER INSERT ON public.bookings 
    FOR EACH ROW EXECUTE FUNCTION generate_recurring_bookings();

-- Create function to check cancellation policy
CREATE OR REPLACE FUNCTION check_cancellation_policy()
RETURNS TRIGGER AS $$
BEGIN
    -- Only check when status changes to cancelled
    IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
        -- Check if cancellation is within 48 hours
        IF NEW.date <= CURRENT_DATE + INTERVAL '2 days' THEN
            RAISE EXCEPTION 'Cancellations must be made at least 48 hours in advance';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply cancellation policy trigger
CREATE TRIGGER check_cancellation_policy_trigger 
    BEFORE UPDATE ON public.bookings 
    FOR EACH ROW EXECUTE FUNCTION check_cancellation_policy();

-- Create function to check insurance requirements
CREATE OR REPLACE FUNCTION check_insurance_requirements()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if insurance is required for this venue
    IF EXISTS (
        SELECT 1 FROM public.venues 
        WHERE id = NEW.venue_id AND insurance_required = true
    ) THEN
        -- If insurance is required, ensure it's approved before confirming
        IF NEW.status = 'confirmed' AND NOT NEW.insurance_approved THEN
            RAISE EXCEPTION 'Insurance approval required before confirming booking';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply insurance requirements trigger
CREATE TRIGGER check_insurance_requirements_trigger 
    BEFORE UPDATE ON public.bookings 
    FOR EACH ROW EXECUTE FUNCTION check_insurance_requirements();

-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.venues TO authenticated;
GRANT ALL ON public.availability TO authenticated;
GRANT ALL ON public.bookings TO authenticated;
GRANT ALL ON public.recurring_bookings TO authenticated;
GRANT ALL ON public.insurance_documents TO authenticated;
GRANT ALL ON public.payments TO authenticated;
GRANT ALL ON public.audit_logs TO authenticated;
GRANT ALL ON public.subscriptions TO authenticated;
GRANT ALL ON public.messages TO authenticated;

-- Grant sequence permissions for auto-incrementing IDs
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
