-- Requêtes du monitoring Klaris (workflows n8n « Surveillance » et « Rapport du matin »).
-- Testées sur Supabase fhqybnkxqfvbsjvwrcob le 2026-10-27.

-- 1) Surveillance (toutes les 10 min) : anomalies à signaler
with last_msg as (
  select distinct on (c.prospect_id) c.prospect_id, c.role, c.created_at
  from conversations c order by c.prospect_id, c.created_at desc)
select 'sans_reponse' as type, p.id, p.prenom, right(p.telephone,4) tel4, lm.created_at as depuis
from last_msg lm join prospects p on p.id=lm.prospect_id
where lm.role='prospect' and lm.created_at < now()-interval '5 minutes' and lm.created_at > now()-interval '24 hours' and p.opted_out_at is null
union all
select 'formulaire_sans_sms', p.id, p.prenom, right(p.telephone,4), p.consentement_sms_at
from prospects p
where p.consentement_sms_at > now()-interval '2 hours' and p.consentement_sms_at < now()-interval '5 minutes'
  and not exists (select 1 from conversations c where c.prospect_id=p.id and c.role='assistant' and c.created_at >= p.consentement_sms_at)
union all
select 'lead_chaud_non_notifie', p.id, p.prenom, right(p.telephone,4), p.updated_at
from prospects p
where p.score_chaleur >= 7 and p.notifie_at is null and p.updated_at < now()-interval '15 minutes' and p.opted_out_at is null;

-- 2) Rapport du matin (8 h America/Toronto) : chiffres de la veille
with b as (select (date_trunc('day', now() at time zone 'America/Toronto') - interval '1 day') at time zone 'America/Toronto' as d0,
                  date_trunc('day', now() at time zone 'America/Toronto') at time zone 'America/Toronto' as d1)
select
 (select count(*) from prospects p,b where p.created_at>=d0 and p.created_at<d1) nouveaux_prospects,
 (select coalesce(json_object_agg(src,n),'{}') from (select coalesce(canal_source,'?') src,count(*) n from prospects p,b where p.created_at>=d0 and p.created_at<d1 group by 1) s) par_source,
 (select count(*) from conversations c,b where c.created_at>=d0 and c.created_at<d1 and role='prospect') msgs_entrants,
 (select count(*) from conversations c,b where c.created_at>=d0 and c.created_at<d1 and role='assistant') msgs_sortants,
 (select count(distinct prospect_id) from conversations c,b where c.created_at>=d0 and c.created_at<d1) conversations_actives,
 (select count(*) from prospects p,b where p.notifie_at>=d0 and p.notifie_at<d1) leads_notifies,
 (select count(*) from prospects p,b where p.notifie_at>=d0 and p.notifie_at<d1 and score_chaleur>=9) leads_urgents,
 (select count(*) from prospects p,b where p.opted_out_at>=d0 and p.opted_out_at<d1) stops,
 (select count(*) from prospects) total_prospects;
