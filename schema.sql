-- Families table
CREATE TABLE IF NOT EXISTS public.families (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  family_name TEXT NOT NULL,
  parent_pin TEXT NOT NULL,
  currency TEXT DEFAULT '₪',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Children table
CREATE TABLE IF NOT EXISTS public.children (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  family_id UUID REFERENCES public.families(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  birthdate DATE,
  avatar_emoji TEXT DEFAULT '👦',
  color TEXT DEFAULT '#F59E0B',
  weekly_allowance NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Categories table
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  family_id UUID REFERENCES public.families(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  icon TEXT DEFAULT '📦',
  type TEXT CHECK (type IN ('deposit', 'withdrawal')),
  color TEXT DEFAULT '#6B7280',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Transactions table
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  child_id UUID REFERENCES public.children(id) ON DELETE CASCADE,
  family_id UUID REFERENCES public.families(id) ON DELETE CASCADE,
  type TEXT CHECK (type IN ('deposit', 'withdrawal')),
  amount NUMERIC NOT NULL CHECK (amount > 0),
  category_id UUID REFERENCES public.categories(id),
  description TEXT NOT NULL,
  notes TEXT,
  transaction_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Balance at date function
CREATE OR REPLACE FUNCTION public.get_balance_at_date(p_child_id UUID, p_date DATE)
RETURNS NUMERIC AS $$
  SELECT COALESCE(
    SUM(CASE WHEN type = 'deposit' THEN amount ELSE -amount END), 0
  )
  FROM public.transactions
  WHERE child_id = p_child_id AND transaction_date <= p_date;
$$ LANGUAGE sql STABLE;

-- Enable RLS
ALTER TABLE public.families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.children ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Anon policies (security via PIN in app)
DROP POLICY IF EXISTS "anon_families" ON public.families;
DROP POLICY IF EXISTS "anon_children" ON public.children;
DROP POLICY IF EXISTS "anon_categories" ON public.categories;
DROP POLICY IF EXISTS "anon_transactions" ON public.transactions;

CREATE POLICY "anon_families" ON public.families FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_children" ON public.children FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_categories" ON public.categories FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_transactions" ON public.transactions FOR ALL TO anon USING (true) WITH CHECK (true);

-- Default categories (only if not present)
INSERT INTO public.categories (family_id, name, icon, type, color)
SELECT * FROM (VALUES
  (NULL::uuid, 'דמי כיס', '💰', 'deposit', '#10B981'),
  (NULL::uuid, 'יום הולדת', '🎂', 'deposit', '#F59E0B'),
  (NULL::uuid, 'מתנה', '🎁', 'deposit', '#8B5CF6'),
  (NULL::uuid, 'עבודות בית', '🧹', 'deposit', '#3B82F6'),
  (NULL::uuid, 'ציונים', '📚', 'deposit', '#EC4899'),
  (NULL::uuid, 'ממתקים', '🍬', 'withdrawal', '#F43F5E'),
  (NULL::uuid, 'צעצועים', '🧸', 'withdrawal', '#F97316'),
  (NULL::uuid, 'משחקים', '🎮', 'withdrawal', '#6366F1'),
  (NULL::uuid, 'ספרים', '📖', 'withdrawal', '#14B8A6'),
  (NULL::uuid, 'חיסכון', '🏦', 'withdrawal', '#64748B'),
  (NULL::uuid, 'צדקה', '❤️', 'withdrawal', '#E11D48')
) AS v(family_id, name, icon, type, color)
WHERE NOT EXISTS (
  SELECT 1 FROM public.categories WHERE family_id IS NULL AND name = v.name
);
