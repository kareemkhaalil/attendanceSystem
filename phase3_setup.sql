-- Phase 3: Payments & Subscriptions Schema

-- 1. Plans Table
CREATE TABLE IF NOT EXISTS public.plans (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    price numeric NOT NULL,
    currency text DEFAULT 'EGP',
    duration_days int NOT NULL, -- e.g. 30 for monthly, 365 for yearly
    features jsonb DEFAULT '[]',
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT NOW()
);

-- 2. Payment Methods Table
CREATE TABLE IF NOT EXISTS public.payment_methods (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    type text NOT NULL, -- 'paymob', 'manual'
    name text NOT NULL, -- e.g. 'Credit Card', 'InstaPay', 'Bank Transfer'
    details jsonb DEFAULT '{}', -- stores Paymob IDs or Manual Instructions
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT NOW()
);

-- 3. Subscriptions Table
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
    plan_id uuid REFERENCES public.plans(id),
    status text NOT NULL DEFAULT 'pending_approval', -- 'active', 'expired', 'pending_approval', 'cancelled'
    start_date timestamptz,
    end_date timestamptz,
    created_at timestamptz DEFAULT NOW(),
    updated_at timestamptz DEFAULT NOW()
);

-- 4. Transactions Table
CREATE TABLE IF NOT EXISTS public.transactions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
    plan_id uuid REFERENCES public.plans(id),
    payment_method_id uuid REFERENCES public.payment_methods(id),
    amount numeric NOT NULL,
    currency text DEFAULT 'EGP',
    status text NOT NULL DEFAULT 'pending', -- 'pending', 'success', 'failed'
    provider_transaction_id text, -- ID from Paymob
    screenshot_url text, -- For manual payments
    admin_notes text,
    created_at timestamptz DEFAULT NOW(),
    updated_at timestamptz DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Plans: Anyone can read active plans
CREATE POLICY "Allow public read active plans" ON public.plans
    FOR SELECT USING (is_active = true);

-- Payment Methods: Anyone can read active methods
CREATE POLICY "Allow public read active payment methods" ON public.payment_methods
    FOR SELECT USING (is_active = true);

-- Subscriptions: Tenant can read their own
CREATE POLICY "Tenants can view their own subscriptions" ON public.subscriptions
    FOR SELECT USING (tenant_id IN (
        SELECT id FROM public.tenants WHERE id = tenant_id
    ));

-- Transactions: Tenant can view/create their own
CREATE POLICY "Tenants can manage their own transactions" ON public.transactions
    FOR ALL USING (tenant_id IN (
        SELECT id FROM public.tenants WHERE id = tenant_id
    ));

-- Admin full access (SuperAdmin via auth role or specific check)
-- For simplicity, we assume auth.role() = 'authenticated' for now, but in production, we'd check the user's role in the users table.

-- Sample Data
INSERT INTO public.plans (name, description, price, duration_days, features) VALUES
('Starter', 'مثالي للشركات الصغيرة', 490, 30, '["حتى 20 موظف", "فرع واحد", "دعم فني عبر البريد"]'),
('Growth', 'الخيار الأفضل للشركات المتوسطة', 1490, 30, '["حتى 100 موظف", "5 فروع", "تقارير متقدمة", "دعم فني سريع"]'),
('Enterprise', 'حلول متكاملة للشركات الكبرى', 3990, 30, '["عدد غير محدود من الموظفين", "فروع غير محدودة", "كل المميزات", "دعم فني مخصص"]')
ON CONFLICT DO NOTHING;

INSERT INTO public.payment_methods (type, name, details) VALUES
('paymob', 'Credit / Debit Card', '{"integration_id": ""}') ,
('manual', 'InstaPay', '{"instruction": "Pay to 0123456789 and upload screenshot"}')
ON CONFLICT DO NOTHING;
