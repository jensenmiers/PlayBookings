-- Enable Row Level Security on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.venues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insurance_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all users" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Venues table policies
CREATE POLICY "Venue owners can view their own venues" ON public.venues
    FOR SELECT USING (owner_id = auth.uid());

CREATE POLICY "Venue owners can insert their own venues" ON public.venues
    FOR INSERT WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Venue owners can update their own venues" ON public.venues
    FOR UPDATE USING (owner_id = auth.uid());

CREATE POLICY "Venue owners can delete their own venues" ON public.venues
    FOR DELETE USING (owner_id = auth.uid());

CREATE POLICY "Anyone can view active venues" ON public.venues
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can view all venues" ON public.venues
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Availability table policies
CREATE POLICY "Venue owners can manage their venue availability" ON public.availability
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.venues 
            WHERE id = venue_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Anyone can view venue availability" ON public.availability
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage all availability" ON public.availability
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Bookings table policies
CREATE POLICY "Users can view their own bookings" ON public.bookings
    FOR SELECT USING (
        renter_id = auth.uid() OR 
        EXISTS (
            SELECT 1 FROM public.venues 
            WHERE id = venue_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Users can create their own bookings" ON public.bookings
    FOR INSERT WITH CHECK (renter_id = auth.uid());

CREATE POLICY "Users can update their own bookings" ON public.bookings
    FOR UPDATE USING (
        renter_id = auth.uid() OR 
        EXISTS (
            SELECT 1 FROM public.venues 
            WHERE id = venue_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all bookings" ON public.bookings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Insurance documents table policies
CREATE POLICY "Users can view their own insurance documents" ON public.insurance_documents
    FOR SELECT USING (
        renter_id = auth.uid() OR 
        EXISTS (
            SELECT 1 FROM public.bookings b
            JOIN public.venues v ON b.venue_id = v.id
            WHERE b.id = booking_id AND v.owner_id = auth.uid()
        )
    );

CREATE POLICY "Users can create their own insurance documents" ON public.insurance_documents
    FOR INSERT WITH CHECK (renter_id = auth.uid());

CREATE POLICY "Users can update their own insurance documents" ON public.insurance_documents
    FOR UPDATE USING (
        renter_id = auth.uid() OR 
        EXISTS (
            SELECT 1 FROM public.bookings b
            JOIN public.venues v ON b.venue_id = v.id
            WHERE b.id = booking_id AND v.owner_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all insurance documents" ON public.insurance_documents
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Audit logs table policies
CREATE POLICY "Users can view audit logs for their own records" ON public.audit_logs
    FOR SELECT USING (
        user_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.venues 
            WHERE id::text = record_id::text AND owner_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM public.bookings 
            WHERE id::text = record_id::text AND renter_id = auth.uid()
        )
    );

CREATE POLICY "Admins can view all audit logs" ON public.audit_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Subscriptions table policies
CREATE POLICY "Users can view their own subscriptions" ON public.subscriptions
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can manage their own subscriptions" ON public.subscriptions
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Admins can view all subscriptions" ON public.subscriptions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Messages table policies
CREATE POLICY "Users can view messages they sent or received" ON public.messages
    FOR SELECT USING (
        sender_id = auth.uid() OR recipient_id = auth.uid()
    );

CREATE POLICY "Users can send messages" ON public.messages
    FOR INSERT WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Users can update their own messages" ON public.messages
    FOR UPDATE USING (sender_id = auth.uid());

CREATE POLICY "Admins can view all messages" ON public.messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

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

-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.venues TO authenticated;
GRANT ALL ON public.availability TO authenticated;
GRANT ALL ON public.bookings TO authenticated;
GRANT ALL ON public.insurance_documents TO authenticated;
GRANT ALL ON public.audit_logs TO authenticated;
GRANT ALL ON public.subscriptions TO authenticated;
GRANT ALL ON public.messages TO authenticated;

-- Grant sequence permissions for auto-incrementing IDs
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
