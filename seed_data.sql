-- =============================================================
-- Manzoma - Final Seed Data (بالـ UUIDs الحقيقية من Supabase)
-- شغّل الـ SQL ده في Supabase SQL Editor
-- =============================================================

-- =====================
-- STEP 1: الشركة (Tenant)
-- =====================
INSERT INTO public.tenants (
  id, name, plan,
  subscription_start, subscription_end,
  billing_amount, billing_interval,
  is_active, allowed_branches, allowed_users,
  current_branches, current_users,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-0000-0000-0000-000000000001',
  'Devbile Company', 'pro',
  NOW(), NOW() + INTERVAL '1 year',
  199.00, 'monthly',
  true, 5, 20, 0, 0,
  NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- =====================
-- STEP 2: public.users (بروفايل التطبيق)
-- =====================
INSERT INTO public.users (
  id, email, name, role, tenant_id,
  branch_id, is_active, base_salary,
  created_at, updated_at
) VALUES
(
  '1ef4764e-e062-4de2-94b3-f62eb4ed36b3',
  'superadmin@manzoma.com',
  'Super Admin',
  'super_admin',
  'aaaaaaaa-0000-0000-0000-000000000001',
  NULL, true, 0, NOW(), NOW()
),
(
  'c406bd41-09cf-4ea2-989b-60af735b982f',
  'admin@devbile.com',
  'Kareem - Company Admin',
  'cad',
  'aaaaaaaa-0000-0000-0000-000000000001',
  NULL, true, 5000, NOW(), NOW()
),
(
  '87a92e51-ed55-4ec6-96ca-2995f9f2a613',
  'emp@devbile.com',
  'Ahmed - Employee',
  'employee',
  'aaaaaaaa-0000-0000-0000-000000000001',
  NULL, true, 3000, NOW(), NOW()
)
ON CONFLICT (id) DO NOTHING;

-- =====================
-- تحقق من النتيجة
-- =====================
SELECT 
  au.email,
  pu.name,
  pu.role,
  t.name AS company,
  pu.is_active
FROM auth.users au
LEFT JOIN public.users pu ON pu.id = au.id
LEFT JOIN public.tenants t ON t.id = pu.tenant_id
WHERE au.email IN (
  'superadmin@manzoma.com',
  'admin@devbile.com',
  'emp@devbile.com'
);
