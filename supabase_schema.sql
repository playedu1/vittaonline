-- Setup script for VittaOnline database schema

-- 0. Clean up existing tables and triggers (Optional: use with caution)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP TABLE IF EXISTS public.messages;
DROP TABLE IF EXISTS public.profiles;

-- 1. Create profiles table
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'auxiliar',
  status TEXT NOT NULL DEFAULT 'offline',
  last_active TIMESTAMPTZ,
  clinic_id TEXT NOT NULL,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by everyone in the same clinic"
  ON public.profiles FOR SELECT
  USING ( true );

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING ( auth.uid() = id );

-- 2. Create messages table
CREATE TABLE public.messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  clinic_id TEXT NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT,
  media_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for messages
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Messages are viewable by everyone in same clinic"
  ON public.messages FOR SELECT
  USING ( true );

CREATE POLICY "Users can insert their own messages"
  ON public.messages FOR INSERT
  WITH CHECK ( auth.uid() = user_id );

-- 3. Storage Setup (Policies for Private Bucket)
-- Run these after creating the 'chat-media' bucket
-- Bucket must be created as PRIVATE in the dashboard

CREATE POLICY "Authenticated users can upload images"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'chat-media');

CREATE POLICY "Authenticated users can view chat images"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'chat-media');

-- 4. Automatic profile creation on signup (Trigger)
-- This might be what's failing if it was already partially set up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, clinic_id, role, status)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Novo Usuário'),
    COALESCE(new.raw_user_meta_data->>'clinic_id', 'default_clinic'),
    'auxiliar',
    'offline'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Uncomment the next block if you want to enable automatic profile creation
/*
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
*/
