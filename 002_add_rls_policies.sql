-- ============================================================
-- RLS POLICIES
-- MVP: service_role (n8n) has full access, authenticated courtier sees own data
-- ============================================================

-- courtiers
CREATE POLICY "courtiers_select_own" ON public.courtiers FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY "courtiers_service_all" ON public.courtiers FOR ALL TO service_role USING (true) WITH CHECK (true);

-- prospects
CREATE POLICY "prospects_select_own" ON public.prospects FOR SELECT TO authenticated USING (courtier_id = auth.uid());
CREATE POLICY "prospects_service_all" ON public.prospects FOR ALL TO service_role USING (true) WITH CHECK (true);

-- besoins_acheteur
CREATE POLICY "besoins_acheteur_select_own" ON public.besoins_acheteur FOR SELECT TO authenticated
  USING (prospect_id IN (SELECT id FROM public.prospects WHERE courtier_id = auth.uid()));
CREATE POLICY "besoins_acheteur_service_all" ON public.besoins_acheteur FOR ALL TO service_role USING (true) WITH CHECK (true);

-- besoins_vendeur
CREATE POLICY "besoins_vendeur_select_own" ON public.besoins_vendeur FOR SELECT TO authenticated
  USING (prospect_id IN (SELECT id FROM public.prospects WHERE courtier_id = auth.uid()));
CREATE POLICY "besoins_vendeur_service_all" ON public.besoins_vendeur FOR ALL TO service_role USING (true) WITH CHECK (true);

-- conversations
CREATE POLICY "conversations_select_own" ON public.conversations FOR SELECT TO authenticated
  USING (prospect_id IN (SELECT id FROM public.prospects WHERE courtier_id = auth.uid()));
CREATE POLICY "conversations_service_all" ON public.conversations FOR ALL TO service_role USING (true) WITH CHECK (true);

-- relances
CREATE POLICY "relances_select_own" ON public.relances FOR SELECT TO authenticated
  USING (prospect_id IN (SELECT id FROM public.prospects WHERE courtier_id = auth.uid()));
CREATE POLICY "relances_service_all" ON public.relances FOR ALL TO service_role USING (true) WITH CHECK (true);
