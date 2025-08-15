Product Requirements Document (PRD)
Project: PlayBookings.com
Version: v1.0
Owner: Jensen Miers
Date: August 2025

Introduction

This Product Requirements Document (PRD) defines the vision, scope, and initial execution plan for Play Bookings, a web-based platform for streamlining the rental of underutilized middle school sports facilities. It is intended to guide technical development, and prioritize initial features that can be go-to-market focuses for the MVP launch. While the platform is designed for long-term adaptability, the initial market wedge targets private schools, faith-based community gyms, and privately/individually owned indoor basketball courts with flexible gym availability and revenue needs, connecting them to trusted, vetted renters such as athletic directors and league organizers.

1. Overview

Play Bookings is a web-based facility rental marketplace designed to connect underutilized  sports facilities (indoor basketball gyms) with trusted, vetted renters such as athletic directors, league coordinators, and club sports managers.

The platform streamlines the process of listing, discovering, booking, and paying for indoor basketball court rentals — prioritizing trust, safety, and ease of use.

2. Goals & Success Metrics
Goals

Acquire 3–5 venue partners within the first 90 days post-MVP.

Establish Play Bookings as a trusted source of repeat and one-time renters for venue owners.

Enable athletic directors to secure both season-long, recurring and ad-hoc bookings with minimal administrative effort.

3. Target Market

The initial focus is indoor gyms that are not public schools or public facilities. 

Assume our venues face budget pressures due to declining tuition or enrollment, or just purely underutilized.

Operate with lean staff and limited digital booking infrastructure.

Renter focus: Athletic directors, youth league managers, and club program coordinators seeking consistent, safe, and reliable gym space for practices, games, and events.

This niche is intentionally chosen for launch because:

Many private institutions actively seek supplemental revenue.

Athletic directors are high-value renters who carry trust and can fill recurring blocks.

4. Personas
Venue Owner Persona — “School Administrator with Idle Gym”

Role: CFO, Business Manager, Athletic Director, Facility Manager.

Motivations:

Generate revenue without burdening staff.

Strengthen community engagement.

Only host trustworthy, vetted renters.

Pain Points:

Manual and inconsistent rental processes.

Few or no qualified renter leads.

Liability and insurance concerns.

Success Metrics:

Increase in monthly rental revenue.

Reduced admin hours spent coordinating rentals.

Strong repeat renter relationships.

Renter Persona — “Athletic Director with Scheduling Headaches”

Role: Middle/high school AD, club sports manager, youth league coordinator.

Motivations:

Secure reliable, recurring venue space for a season. Or securing venues on short notice when pinched.

Avoid cancellations and conflicts.

Pain Points:

Lack of availability in local facilities.

Difficulty reserving the same time slot weekly.

Confusing pricing and booking terms.

Success Metrics:

Season-long slot secured.

Less time spent searching for venues.

Improved team satisfaction.

5. Core Features / MVP Scope

For Venue Owners:

Venue profile creation with photos, amenities, and availability.

Calendar-based availability management (manual entry and/or calendar import).

Ability to set custom pricing by time slot.

Renter vetting & approval process.

Payouts via Stripe Connect.

For Renters:

Search & filter venues by location, date/time, amenities.

Instant booking or booking request workflows.

Secure payments via Stripe.

Repeat booking option for recurring time slots.

Booking history dashboard.

For Both:

Messaging system for booking coordination.

Insurance verification workflow (e.g., CoverWallet integration). Or simple certificate of insurance upload.

Potential Email & SMS notifications for booking confirmations/changes.

6. Non-Goals

No mobile app for MVP (responsive web only).

No public renter review system at launch (trust managed via vetting process).

No tournament management or team roster tools in MVP.

7. Launch Strategy

Phase 1 — Venue Acquisition

Identify and reach out to indoor basketball gyms with idle gym space in Los Angeles County.

Prioritize private/faith-based schools with revenue needs and flexible schedules.

Approach CFOs, business managers, and athletic directors with a “hands-off revenue” pitch.

Phase 2 — Renter Acquisition

Once venues are live, reach out to athletic directors in nearby schools and leagues.


Phase 3 — Network Effect Growth

Use success stories to onboard more venues and renters.

Expand beyond Los Angeles to other Southern California markets.

Add premium features to increase stickiness.

8. Technical Requirements

Frontend: Next.js 14 App Router, React 18, TypeScript, TailwindCSS (Retro Gatorade theme), shadcn/ui components.

Backend: Supabase (Postgres) with Row-Level Security.

Auth: Google OAuth

Payments: Stripe Payment 


9. Design & Branding Guidelines

Theme: Retro Gatorade-inspired palette + beige/brown accents (Hipcamp aesthetic).

UI: Warm, inviting, mobile-first for renters, desktop-optimized for venue owners.

Components: Rounded edges, large tap targets, diffused shadows, minimal clutter.

10. Risks & Assumptions

Risk: Schools may have restrictive policies for external rentals despite interest.

Risk: Athletic directors may have existing relationships with venues.

Assumption: Early adopters will value trust and vetting over lowest possible price.

Assumption: Insurance compliance will be a key differentiator for schools.