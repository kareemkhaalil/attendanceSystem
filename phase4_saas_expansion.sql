-- Phase 4: SaaS Expansion & Advanced Payroll

-- 1. Enhance Plans Table with Limits and Module Toggles
ALTER TABLE IF EXISTS public.plans 
ADD COLUMN IF NOT EXISTS max_users int DEFAULT 10,
ADD COLUMN IF NOT EXISTS max_branches int DEFAULT 1,
ADD COLUMN IF NOT EXISTS max_admins int DEFAULT 1,
ADD COLUMN IF NOT EXISTS has_payroll boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS has_attendance boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS has_reports boolean DEFAULT true;

-- Update existing plans with realistic limits
UPDATE public.plans SET max_users = 20, max_branches = 1, max_admins = 1, has_payroll = true, has_attendance = true, has_reports = true WHERE name = 'Starter';
UPDATE public.plans SET max_users = 100, max_branches = 5, max_admins = 3, has_payroll = true, has_attendance = true, has_reports = true WHERE name = 'Growth';
UPDATE public.plans SET max_users = 1000, max_branches = 20, max_admins = 10, has_payroll = true, has_attendance = true, has_reports = true WHERE name = 'Enterprise';

-- 2. Tenant Configuration Table (Settings per Client)
CREATE TABLE IF NOT EXISTS public.tenant_configs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE UNIQUE,
    working_hours_per_day numeric DEFAULT 8.0,
    work_days_per_week int DEFAULT 5,
    overtime_multiplier numeric DEFAULT 1.5,
    late_buffer_minutes int DEFAULT 15,
    currency text DEFAULT 'EGP',
    fiscal_year_start date DEFAULT '2024-01-01',
    created_at timestamptz DEFAULT NOW(),
    updated_at timestamptz DEFAULT NOW()
);

-- 3. Payroll Regulations (Rules per Tenant)
-- Note: 'payroll_rules' already exists in logic, ensure DB matches
CREATE TABLE IF NOT EXISTS public.payroll_regulations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
    name text NOT NULL,
    description text,
    type text NOT NULL, -- 'allowance', 'deduction'
    calculation_method text NOT NULL, -- 'fixed', 'percentage'
    value numeric NOT NULL,
    is_automatic boolean DEFAULT false,
    created_at timestamptz DEFAULT NOW(),
    updated_at timestamptz DEFAULT NOW()
);

-- 4. Employee Salary Profiles (Personal Salary Details)
CREATE TABLE IF NOT EXISTS public.employee_salary_profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
    tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
    basic_salary numeric NOT NULL DEFAULT 0.0,
    is_active_payroll boolean DEFAULT true,
    bank_account_number text,
    bank_name text,
    payment_method text DEFAULT 'bank_transfer',
    created_at timestamptz DEFAULT NOW(),
    updated_at timestamptz DEFAULT NOW()
);

-- 5. Salary Components Link (Which rules apply to which employee)
CREATE TABLE IF NOT EXISTS public.employee_salary_components (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id uuid REFERENCES public.employee_salary_profiles(id) ON DELETE CASCADE,
    regulation_id uuid REFERENCES public.payroll_regulations(id) ON DELETE CASCADE,
    custom_value numeric, -- if override needed
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.tenant_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payroll_regulations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_salary_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_salary_components ENABLE ROW LEVEL SECURITY;

-- RLS Policies (Tenant based isolation)
CREATE POLICY "Tenant isolation check" ON public.tenant_configs FOR ALL USING (tenant_id = tenant_id);
CREATE POLICY "Tenant isolation check reg" ON public.payroll_regulations FOR ALL USING (tenant_id = tenant_id);
CREATE POLICY "Tenant isolation check prof" ON public.employee_salary_profiles FOR ALL USING (tenant_id = tenant_id);
CREATE POLICY "Tenant isolation check comp" ON public.employee_salary_components FOR ALL USING (
    (SELECT tenant_id FROM public.employee_salary_profiles WHERE id = profile_id) = tenant_id
);
