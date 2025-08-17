# 🚀 Supabase Setup Guide for PlayBookings

## 📋 Overview

This guide will walk you through setting up Supabase for the PlayBookings application, including:
- Database schema creation
- Row-Level Security (RLS) policies
- Google OAuth authentication
- Environment configuration

## 🗄️ Database Schema Status

✅ **COMPLETED:**
- Initial database schema with all tables
- Row-Level Security policies for multi-tenant isolation
- Audit trail triggers and functions
- Booking conflict detection
- Sample seed data

## 🔧 Next Steps

### 1. Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign in with your GitHub account
3. Click "New Project"
4. Choose your organization
5. Enter project details:
   - **Name**: `playbookings`
   - **Database Password**: Generate a strong password
   - **Region**: Choose closest to your users (e.g., `us-west-1` for LA)
6. Click "Create new project"

### 2. Get Project Credentials

1. In your project dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://abcdefghijklmnop.supabase.co`)
   - **anon public** key
   - **service_role** key (keep this secret!)

### 3. Configure Environment Variables

1. Copy `env.example` to `.env.local`:
   ```bash
   cp env.example .env.local
   ```

2. Update `.env.local` with your Supabase credentials:
   ```bash
   # Supabase Configuration
   NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
   ```

### 4. Set Up Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the **Google+ API**
4. Go to **Credentials** → **Create Credentials** → **OAuth 2.0 Client IDs**
5. Configure OAuth consent screen:
   - **User Type**: External
   - **App name**: PlayBookings
   - **User support email**: Your email
   - **Developer contact information**: Your email
6. Create OAuth 2.0 Client ID:
   - **Application type**: Web application
   - **Name**: PlayBookings Web Client
   - **Authorized redirect URIs**: 
     - `https://your-project-id.supabase.co/auth/v1/callback`
     - `http://localhost:3000/auth/callback` (for development)
7. Copy the **Client ID** and **Client Secret**

8. Update `.env.local`:
   ```bash
   # Google OAuth
   GOOGLE_CLIENT_ID=your_google_client_id
   GOOGLE_CLIENT_SECRET=your_google_client_secret
   SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID=your_google_client_id
   SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET=your_google_client_secret
   ```

### 5. Deploy Database Schema

#### Option A: Using Supabase Dashboard (Recommended for first deployment)

1. Go to **SQL Editor** in your Supabase dashboard
2. Copy and paste the contents of `supabase/migrations/001_initial_schema.sql`
3. Click "Run" to execute the schema
4. Copy and paste the contents of `supabase/migrations/002_rls_policies.sql`
5. Click "Run" to execute the RLS policies
6. Copy and paste the contents of `supabase/seed.sql`
7. Click "Run" to insert sample data

#### Option B: Using Supabase CLI (Advanced)

1. Install Supabase CLI: `brew install supabase/tap/supabase`
2. Link your project: `supabase link --project-ref your-project-id`
3. Push migrations: `supabase db push`

### 6. Configure Authentication Settings

1. In Supabase dashboard, go to **Authentication** → **Settings**
2. Update **Site URL**: `http://localhost:3000` (for development)
3. Add **Redirect URLs**:
   - `http://localhost:3000/auth/callback`
   - `http://localhost:3000/dashboard`
4. Go to **Authentication** → **Providers**
5. Enable **Google** provider
6. Enter your Google OAuth credentials

### 7. Test the Setup

1. Start your development server: `npm run dev`
2. Navigate to `http://localhost:3000/auth/login`
3. Try signing in with Google
4. Check the **Authentication** → **Users** section in Supabase dashboard

## 🔒 Security Features Implemented

### Row-Level Security (RLS)
- **Multi-tenant isolation**: Each venue owner only sees their own data
- **User data privacy**: Users only see their own bookings and insurance documents
- **Admin access**: Admins can view all data for platform management

### Data Protection
- **Audit trails**: Every change is logged with user and timestamp
- **Booking conflicts**: Prevents double-booking of time slots
- **Input validation**: Zod schemas validate all user inputs

### Authentication
- **Google OAuth**: Secure, trusted authentication
- **Role-based access**: Different permissions for venue owners, renters, and admins
- **Session management**: Secure JWT tokens with refresh rotation

## 📊 Database Tables

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `users` | User profiles and roles | Role-based permissions, extends auth.users |
| `venues` | Basketball court listings | Location, pricing, amenities, owner management |
| `availability` | Time slot management | Hourly blocks, conflict prevention |
| `bookings` | Reservation system | Status tracking, insurance approval |
| `insurance_documents` | Compliance management | Document storage, approval workflow |
| `audit_logs` | Change tracking | Complete audit trail for compliance |
| `subscriptions` | Billing management | Stripe integration, trial periods |
| `messages` | User communication | In-app messaging between parties |

## 🚨 Important Notes

1. **Never commit `.env.local`** to version control
2. **Keep service role key secret** - it bypasses RLS policies
3. **Test RLS policies** thoroughly before production
4. **Monitor audit logs** for security and compliance
5. **Backup your database** regularly

## 🔍 Troubleshooting

### Common Issues

1. **"Invalid JWT" errors**: Check your Supabase URL and keys
2. **RLS policy violations**: Verify user authentication and role assignments
3. **Google OAuth redirect errors**: Check redirect URIs in both Google Console and Supabase
4. **Database connection errors**: Verify your Supabase project is active

### Getting Help

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Discord](https://discord.supabase.com)
- [GitHub Issues](https://github.com/supabase/supabase/issues)

## ✅ Next Phase

Once Supabase is configured and working:
1. **Test authentication flow** with Google OAuth
2. **Verify RLS policies** are working correctly
3. **Implement venue management** interface
4. **Build booking system** with real-time updates
5. **Add insurance workflow** components

---

**Status**: 🟡 Ready for Supabase project creation and deployment
**Next**: Create Supabase project and configure environment variables
