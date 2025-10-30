-- STG3_SIRE_ADM.NS_POSITION_OF_TRUST_LIST bulk load
-- Columns: APPLICATION_KEY, ORGANIZATION_ID, PARTICIPANT_ID, PARTICIPANT_NAME,
--          NOTIFICATION_BASIS_CODE, TITLE, POSITION_OF_TRUST,
--          ENTITY_OF_POSITION_OF_TRUST, END_DATE

SET SERVEROUTPUT ON;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

DECLARE
  v_end_date  DATE := TO_DATE('31-DEC-1999','DD-MON-YYYY');  -- adjust if you need 2099
  -- convenience procedure to upsert one row
  PROCEDURE upsert_row(
    p_app_key   IN VARCHAR2,
    p_org_id    IN NUMBER,
    p_part_id   IN NUMBER,
    p_name      IN VARCHAR2,
    p_basis     IN VARCHAR2,
    p_title     IN VARCHAR2,
    p_pos       IN VARCHAR2,
    p_entity    IN VARCHAR2,
    p_end_date  IN DATE
  ) IS
  BEGIN
    MERGE INTO STG3_SIRE_ADM.NS_POSITION_OF_TRUST_LIST t
    USING (SELECT p_app_key   AS application_key,
                  p_org_id    AS organization_id,
                  p_part_id   AS participant_id,
                  p_name      AS participant_name,
                  p_basis     AS notification_basis_code,
                  p_title     AS title,
                  p_pos       AS position_of_trust,
                  p_entity    AS entity_of_position_of_trust,
                  p_end_date  AS end_date
             FROM dual) s
       ON (t.application_key = s.application_key
           AND t.organization_id = s.organization_id
           AND t.participant_id  = s.participant_id)
    WHEN MATCHED THEN
      UPDATE SET
        t.participant_name             = s.participant_name,
        t.notification_basis_code      = s.notification_basis_code,
        t.title                        = s.title,
        t.position_of_trust            = s.position_of_trust,
        t.entity_of_position_of_trust  = s.entity_of_position_of_trust,
        t.end_date                     = s.end_date
    WHEN NOT MATCHED THEN
      INSERT (application_key, organization_id, participant_id, participant_name,
              notification_basis_code, title, position_of_trust,
              entity_of_position_of_trust, end_date)
      VALUES (s.application_key, s.organization_id, s.participant_id, s.participant_name,
              s.notification_basis_code, s.title, s.position_of_trust,
              s.entity_of_position_of_trust, s.end_date);
  END;
BEGIN
  -- 1) Four specific rows from your screenshots
  upsert_row('POSTR', 10012785, 10012821, 'BROWN JAMES',           'POSOTR_001', NULL, 'Trusted man',        'Trusting company 1', v_end_date);
  upsert_row('POSTR', 10012785, 10012822, 'ÅKE TEST–JUNIOR–FIRST',  'POSOTR_002', NULL, 'Trusted junior',     'Trusting company 2', v_end_date);
  upsert_row('POSTR', 10012785, 10012825, 'AFFÄR BJÖRN ÅKE',        'POSOTR_003', NULL, 'Member of bård',     'Trusting company 3', v_end_date);
  upsert_row('POSTR', 10012814, 10012814, 'Cousteau Jacques',       'POSOTR_001', NULL, 'Head of seas',       'Globe',              v_end_date);

  -- 2) Pattern rows PUH1…PUH69 for org 11012786
  FOR i IN 1..69 LOOP
    upsert_row(
      p_app_key  => 'POSTR',
      p_org_id   => 11012786,
      p_part_id  => 20000000 + i,                -- 20000001 … 20000069
      p_name     => 'PUH' || i || ' NALLE',
      p_basis    => 'POSOTR_001',
      p_title    => NULL,
      p_pos      => 'Position of trust',
      p_entity   => 'Entity of position of trust',
      p_end_date => v_end_date
    );
  END LOOP;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Upsert complete.');
END;
/
