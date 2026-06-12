-- Assertions post-010 (communes aux chemins legacy et 008)
\set ON_ERROR_STOP on

DO $$
DECLARE
  v_count INT;
  v_txt   TEXT;
  v_json  JSONB;
  v_bool  BOOLEAN;
  v_ts    TIMESTAMPTZ;
BEGIN
  -- 1. Forme canonique : colonnes attendues presentes, anciennes absentes
  PERFORM 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='relances' AND column_name='type_relance';
  IF NOT FOUND THEN RAISE EXCEPTION 'ASSERT 1a: type_relance manquant'; END IF;
  PERFORM 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='relances' AND column_name='scheduled_for';
  IF NOT FOUND THEN RAISE EXCEPTION 'ASSERT 1b: scheduled_for manquant'; END IF;
  PERFORM 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='relances' AND column_name='sent_at';
  IF NOT FOUND THEN RAISE EXCEPTION 'ASSERT 1c: sent_at manquant'; END IF;
  PERFORM 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='relances' AND column_name='date_prevue';
  IF FOUND THEN RAISE EXCEPTION 'ASSERT 1d: date_prevue encore present'; END IF;
  PERFORM 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='relances' AND column_name='step';
  IF FOUND THEN RAISE EXCEPTION 'ASSERT 1e: step encore present'; END IF;

  -- 2. Zero perte de donnees + mappings appliques
  SELECT count(*) INTO v_count FROM public.relances;
  IF v_count <> 6 THEN RAISE EXCEPTION 'ASSERT 2a: % relances au lieu de 6 (perte/ajout)', v_count; END IF;
  SELECT count(*) INTO v_count FROM public.relances
  WHERE type_relance IN ('rappel_documents','proposition_aide','alerte_courtier_froid','rappel_rdv','post_visite');
  IF v_count <> 0 THEN RAISE EXCEPTION 'ASSERT 2b: anciens types restants: %', v_count; END IF;
  SELECT count(*) INTO v_count FROM public.relances WHERE status IN ('planifiee','envoyee','annulee');
  IF v_count <> 0 THEN RAISE EXCEPTION 'ASSERT 2c: anciens statuts restants: %', v_count; END IF;
  SELECT count(*) INTO v_count FROM public.relances WHERE status = 'sent' AND sent_at IS NULL;
  IF v_count <> 0 THEN RAISE EXCEPTION 'ASSERT 2d: sent sans sent_at: %', v_count; END IF;
  SELECT count(*) INTO v_count FROM public.relances WHERE courtier_id IS NULL;
  IF v_count <> 0 THEN RAISE EXCEPTION 'ASSERT 2e: courtier_id non backfille: %', v_count; END IF;
  SELECT count(*) INTO v_count FROM public.prospects;
  IF v_count <> 14 THEN RAISE EXCEPTION 'ASSERT 2f: % prospects au lieu de 14', v_count; END IF;

  -- 3. Vue compat iOS : alias step
  SELECT step INTO v_txt FROM public.relances_enriched WHERE type_relance='inactif_j5' LIMIT 1;
  IF v_txt IS DISTINCT FROM 'j5' THEN RAISE EXCEPTION 'ASSERT 3: step alias=% pour inactif_j5', v_txt; END IF;

  -- 4. Seeds templates + config
  SELECT count(*) INTO v_count FROM public.relance_templates;
  IF v_count < 9 THEN RAISE EXCEPTION 'ASSERT 4a: % templates < 9', v_count; END IF;
  SELECT count(*) INTO v_count FROM public.relance_config;
  IF v_count < 9 THEN RAISE EXCEPTION 'ASSERT 4b: % cles config < 9', v_count; END IF;

  -- 5. type_projet nullable
  SELECT is_nullable INTO v_txt FROM information_schema.columns
  WHERE table_schema='public' AND table_name='prospects' AND column_name='type_projet';
  IF v_txt <> 'YES' THEN RAISE EXCEPTION 'ASSERT 5: type_projet NOT NULL'; END IF;

  -- 6. Index unique upsert intake
  PERFORM 1 FROM pg_indexes WHERE schemaname='public' AND indexname='ux_prospects_courtier_telephone';
  IF NOT FOUND THEN RAISE EXCEPTION 'ASSERT 6: ux_prospects_courtier_telephone manquant'; END IF;

  -- 7. can_send_relance : kill switch + garde opt-out
  SELECT public.can_send_relance('00000000-0000-0000-0000-000000000001'::uuid,'inactif_j2') INTO v_json;
  IF v_json->>'action' NOT IN ('SEND','BLOCK','DEFER') THEN RAISE EXCEPTION 'ASSERT 7a: verdict invalide %', v_json; END IF;
  UPDATE public.relance_config SET valeur='false'::jsonb WHERE cle='relance_active';
  SELECT public.can_send_relance('00000000-0000-0000-0000-000000000001'::uuid,'inactif_j2') INTO v_json;
  IF v_json->>'garde' <> 'G0' THEN RAISE EXCEPTION 'ASSERT 7b: kill switch inoperant %', v_json; END IF;
  DELETE FROM public.relance_config WHERE cle='relance_active';
  SELECT public.can_send_relance('00000000-0000-0000-0000-000000000001'::uuid,'inactif_j2') INTO v_json;
  IF v_json->>'garde' <> 'G0' THEN RAISE EXCEPTION 'ASSERT 7c: fail-closed inoperant %', v_json; END IF;
  INSERT INTO public.relance_config (cle, valeur) VALUES ('relance_active','true'::jsonb);

  INSERT INTO public.sms_optout (telephone, reason) VALUES ('+15145551001','stop_keyword');
  SELECT public.can_send_relance('00000000-0000-0000-0000-000000000001'::uuid,'inactif_j2') INTO v_json;
  IF v_json->>'garde' <> 'G1' THEN RAISE EXCEPTION 'ASSERT 7d: G1 optout inoperant %', v_json; END IF;
  DELETE FROM public.sms_optout WHERE telephone='+15145551001';

  -- 8. Candidats T1 : prospect en_qualification, msg il y a 3 jours
  UPDATE public.prospects SET statut='en_qualification', last_inbound_message_at=now()-interval '72 hours'
  WHERE id='00000000-0000-0000-0000-000000000001';
  SELECT count(*) INTO v_count FROM public.get_relance_candidates() c
  WHERE c.prospect_id='00000000-0000-0000-0000-000000000001' AND c.type_relance='inactif_j2';
  IF v_count <> 1 THEN RAISE EXCEPTION 'ASSERT 8a: candidat T1 attendu, trouve %', v_count; END IF;
  -- NULL last_inbound -> exclu (D23)
  UPDATE public.prospects SET last_inbound_message_at=NULL WHERE id='00000000-0000-0000-0000-000000000001';
  SELECT count(*) INTO v_count FROM public.get_relance_candidates() c
  WHERE c.prospect_id='00000000-0000-0000-0000-000000000001';
  IF v_count <> 0 THEN RAISE EXCEPTION 'ASSERT 8b: prospect NULL inbound devrait etre exclu'; END IF;

  -- 9. Lock : 1er appel true, 2e false (jamais NULL)
  SELECT public.acquire_relance_lock('00000000-0000-0000-0000-000000000002'::uuid) INTO v_bool;
  IF v_bool IS DISTINCT FROM true THEN RAISE EXCEPTION 'ASSERT 9a: lock 1 = %', v_bool; END IF;
  SELECT public.acquire_relance_lock('00000000-0000-0000-0000-000000000002'::uuid) INTO v_bool;
  IF v_bool IS DISTINCT FROM false THEN RAISE EXCEPTION 'ASSERT 9b: lock 2 = % (attendu false)', v_bool; END IF;

  -- 10. relance_next_slot : dimanche 2026-06-14 15h -> lundi 11h locale
  SELECT public.relance_next_slot('America/Montreal', '2026-06-14 15:00:00-04'::timestamptz) INTO v_ts;
  IF (v_ts AT TIME ZONE 'America/Montreal')::date <> '2026-06-15'::date
     OR EXTRACT(HOUR FROM v_ts AT TIME ZONE 'America/Montreal') <> 11 THEN
    RAISE EXCEPTION 'ASSERT 10a: dimanche -> % (attendu lundi 11h)', v_ts AT TIME ZONE 'America/Montreal';
  END IF;
  -- vendredi 2026-06-12 17h -> samedi 10h
  SELECT public.relance_next_slot('America/Montreal', '2026-06-12 17:00:00-04'::timestamptz) INTO v_ts;
  IF (v_ts AT TIME ZONE 'America/Montreal')::date <> '2026-06-13'::date
     OR EXTRACT(HOUR FROM v_ts AT TIME ZONE 'America/Montreal') <> 10 THEN
    RAISE EXCEPTION 'ASSERT 10b: vendredi 17h -> % (attendu samedi 10h)', v_ts AT TIME ZONE 'America/Montreal';
  END IF;
  -- St-Jean 2026-06-24 12h -> 25 juin 9h
  SELECT public.relance_next_slot('America/Montreal', '2026-06-24 12:00:00-04'::timestamptz) INTO v_ts;
  IF (v_ts AT TIME ZONE 'America/Montreal')::date <> '2026-06-25'::date THEN
    RAISE EXCEPTION 'ASSERT 10c: ferie -> % (attendu 25 juin)', v_ts AT TIME ZONE 'America/Montreal';
  END IF;

  RAISE NOTICE 'TOUTES LES ASSERTIONS PASSENT';
END $$;
