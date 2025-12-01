-- 1) إحذف الجدول لو موجود
DROP TABLE IF EXISTS public.trials;

-- 2) إنشاء الجدول مع default start_date على مستوى DB
CREATE TABLE public.trials (
    device_id TEXT PRIMARY KEY,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    duration_days INT NOT NULL DEFAULT 7,
    status TEXT NOT NULL DEFAULT 'active'
);

CREATE INDEX IF NOT EXISTS idx_trials_status ON public.trials(status);

ALTER TABLE public.trials ENABLE ROW LEVEL SECURITY;

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



ALTER TABLE public.trials
ADD COLUMN expiry_date TIMESTAMP WITH TIME ZONE;

UPDATE public.trials
SET expiry_date = start_date + (duration_days || ' days')::interval;

CREATE OR REPLACE FUNCTION set_expiry_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.expiry_date := NEW.start_date + (NEW.duration_days || ' days')::interval;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_expiry_date
BEFORE INSERT OR UPDATE OF start_date, duration_days
ON public.trials
FOR EACH ROW
EXECUTE FUNCTION set_expiry_date();


-- for controll the trail for devieces 
UPDATE public.trials
SET start_date = now() - interval '1 days'
WHERE device_id = 'AP3A.240905.015.A2';

--------------------------------------------------------- after finish the trail

DROP TABLE IF EXISTS public.trials;

CREATE TABLE public.trials (
    device_id TEXT PRIMARY KEY,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    is_blocked BOOLEAN NOT NULL DEFAULT false,
    status TEXT NOT NULL DEFAULT 'active'
);

-- -- Global Kill Switch
-- CREATE TABLE public.global_controls (
--     id INT PRIMARY KEY DEFAULT 1,
--     is_global_blocked BOOLEAN NOT NULL DEFAULT false
-- );

-- INSERT INTO public.global_controls (id, is_global_blocked)
-- VALUES (1, false)
-- ON CONFLICT (id) DO NOTHING;

-- Index
CREATE INDEX IF NOT EXISTS idx_trials_block ON public.trials(is_blocked);

-- RLS
ALTER TABLE public.trials ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.global_controls ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "allow_all_select_trials"
  ON public.trials FOR SELECT USING (true);
CREATE POLICY "allow_all_insert_trials"
  ON public.trials FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_all_update_trials"
  ON public.trials FOR UPDATE USING (true) WITH CHECK (true);


UPDATE public.trials
SET is_blocked = true
WHERE device_id = 'DEVICE_ID_HERE';

UPDATE public.global_controls
SET is_global_blocked = true
WHERE id = 1;



DROP TABLE IF EXISTS public.trials;

CREATE TABLE public.trials (
    device_id TEXT PRIMARY KEY,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_blocked BOOLEAN NOT NULL DEFAULT false,
    status TEXT NOT NULL,
    user_name TEXT
);



