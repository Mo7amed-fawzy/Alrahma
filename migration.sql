-- 1) إحذف الجدول لو موجود
DROP TABLE IF EXISTS public.trials;

-- 2) إنشاء الجدول مع default start_date على مستوى DB
CREATE TABLE public.trials (
    device_id TEXT PRIMARY KEY,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    duration_days INT NOT NULL DEFAULT 7,
    status TEXT NOT NULL DEFAULT 'active'
);

-- 3) Index لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_trials_status ON public.trials(status);

-- 4) تفعيل RLS
ALTER TABLE public.trials ENABLE ROW LEVEL SECURITY;

-- 5) سياسات تجريبية (خلال الاختبار فقط)
CREATE POLICY "public_select"
  ON public.trials
  FOR SELECT
  USING (true);

CREATE POLICY "public_insert"
  ON public.trials
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "public_update"
  ON public.trials
  FOR UPDATE
  USING (true)
  WITH CHECK (true);



UPDATE public.trials
SET start_date = now() - interval '1 days'
WHERE device_id = 'AP3A.240905.015.A2';
