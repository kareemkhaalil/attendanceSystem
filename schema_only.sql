CREATE TABLE public.attendance (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    date date NOT NULL,
    check_in_time timestamp with time zone,
    check_out_time timestamp with time zone,
    status text NOT NULL,
    working_hours numeric(4,2),
    overtime_hours numeric(4,2),
    notes text,
    method text DEFAULT 'manual'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT attendance_method_check CHECK ((method = ANY (ARRAY['manual'::text, 'gps'::text, 'qr_code'::text]))),
    CONSTRAINT attendance_status_check CHECK ((status = ANY (ARRAY['present'::text, 'absent'::text, 'late'::text, 'early_leave'::text, 'on_leave'::text])))
);

CREATE TABLE public.attendance_rules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    name text,
    details jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.users (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    branch_id uuid,
    email text,
    role text NOT NULL,
    name text NOT NULL,
    phone text,
    avatar text,
    base_salary numeric(10,2) DEFAULT 0,
    allowances jsonb DEFAULT '[]'::jsonb,
    deductions jsonb DEFAULT '[]'::jsonb,
    work_schedule jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    full_name text,
    CONSTRAINT users_role_check CHECK ((role = ANY (ARRAY['super_admin'::text, 'cad'::text, 'employee'::text])))
);

CREATE TABLE public.audit_logs (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    action text NOT NULL,
    entity_type text DEFAULT 'unknown'::text NOT NULL,
    entity_id uuid,
    old_value jsonb,
    new_value jsonb,
    ip_address inet,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    meta jsonb
);

CREATE TABLE public.billing_history (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    invoice_number text NOT NULL,
    amount numeric(10,2) NOT NULL,
    currency text DEFAULT 'USD'::text NOT NULL,
    payment_date date NOT NULL,
    status text NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT billing_history_status_check CHECK ((status = ANY (ARRAY['paid'::text, 'pending'::text, 'failed'::text])))
);

CREATE TABLE public.branches (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    address text,
    radius_meters numeric DEFAULT 50 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    details jsonb
);

CREATE TABLE public.employee_salaries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    base_salary numeric(12,2) DEFAULT 0 NOT NULL,
    currency text DEFAULT 'EGP'::text,
    effective_date date DEFAULT CURRENT_DATE,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.employee_salary_rules (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    rule_id uuid NOT NULL
);

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    payroll_period_id uuid,
    amount numeric(14,2) NOT NULL,
    currency text DEFAULT 'USD'::text,
    method text,
    status text DEFAULT 'pending'::text,
    external_ref text,
    paid_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.payroll (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    user_name text NOT NULL,
    period text NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    base_salary numeric(10,2) NOT NULL,
    gross numeric(10,2) NOT NULL,
    net_salary numeric(10,2) NOT NULL,
    working_days integer NOT NULL,
    actual_working_days integer NOT NULL,
    status text NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    payroll_period_id uuid,
    period_id uuid,
    overtime_hours numeric(10,2) DEFAULT 0,
    additions jsonb DEFAULT '[]'::jsonb,
    extra jsonb DEFAULT '{}'::jsonb,
    overtime numeric(10,2) DEFAULT 0,
    details jsonb,
    basic_salary numeric(10,2) DEFAULT 0 NOT NULL,
    allowances jsonb DEFAULT '[]'::jsonb,
    deductions jsonb DEFAULT '[]'::jsonb,
    CONSTRAINT payroll_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'approved'::text, 'paid'::text, 'cancelled'::text])))
);

CREATE TABLE public.payroll_details (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    payroll_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    rule_name text NOT NULL,
    calculation_method text NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    amount numeric(10,2) NOT NULL,
    CONSTRAINT payroll_details_type_check CHECK ((type = ANY (ARRAY['allowance'::text, 'deduction'::text])))
);

CREATE TABLE public.payroll_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    payroll_period_id uuid,
    user_id uuid,
    base_salary numeric(10,2) DEFAULT 0,
    worked_hours numeric(6,2),
    expected_hours numeric(6,2),
    lateness_minutes integer,
    overtime_hours numeric(6,2),
    deductions jsonb,
    additions jsonb DEFAULT '{}'::jsonb,
    net_pay numeric(12,2),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    tenant_id uuid NOT NULL,
    user_name text,
    gross numeric(12,2) DEFAULT 0,
    net_salary numeric(12,2) DEFAULT 0,
    allowances jsonb,
    overtime numeric(12,2) DEFAULT 0,
    details jsonb DEFAULT '{}'::jsonb
);

CREATE TABLE public.payroll_periods (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    period_start date,
    period_end date,
    status text DEFAULT 'draft'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    start_date date DEFAULT CURRENT_DATE NOT NULL,
    end_date date DEFAULT CURRENT_DATE NOT NULL,
    employees_count integer DEFAULT 0,
    total_amount numeric(12,2) DEFAULT 0,
    created_by uuid
);

CREATE TABLE public.payroll_rules (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    type text NOT NULL,
    calculation_method text NOT NULL,
    value numeric(10,2) DEFAULT 0 NOT NULL,
    is_automatic boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payroll_rules_calculation_method_check CHECK ((calculation_method = ANY (ARRAY['fixed'::text, 'percentage'::text, 'per_hour'::text, 'custom'::text]))),
    CONSTRAINT payroll_rules_type_check CHECK ((type = ANY (ARRAY['allowance'::text, 'deduction'::text])))
);

CREATE TABLE public.profiles (
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid NOT NULL
);

CREATE TABLE public.qr_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    branch_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    session_token text NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL
);

CREATE TABLE public.tenants (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    plan text DEFAULT 'free'::text NOT NULL,
    subscription_start timestamp with time zone DEFAULT now() NOT NULL,
    subscription_end timestamp with time zone DEFAULT (now() + '1 year'::interval) NOT NULL,
    billing_amount numeric(10,2) DEFAULT 0.00 NOT NULL,
    billing_interval text DEFAULT 'monthly'::text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    allowed_branches integer DEFAULT 1 NOT NULL,
    allowed_users integer DEFAULT 5 NOT NULL,
    current_branches integer DEFAULT 0 NOT NULL,
    current_users integer DEFAULT 0 NOT NULL
);

CREATE TABLE public.used_qr_tokens (
    token text NOT NULL,
    used_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.users_view_table (
    instance_id uuid,
    id uuid,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text,
    phone_confirmed_at timestamp with time zone,
    phone_change text,
    phone_change_token character varying(255),
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone,
    email_change_token_current character varying(255),
    email_change_confirm_status smallint,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255),
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean,
    deleted_at timestamp with time zone,
    is_anonymous boolean
);