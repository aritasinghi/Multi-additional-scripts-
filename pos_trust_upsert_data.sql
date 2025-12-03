-- =====================================================================
-- Position of Trust - Data Upsert Script
-- Table: NS_POSITION_OF_TRUST_LIST
-- Schema: STG_NETSIRE_ADM
-- =====================================================================
-- Description: Upsert data for Position of Trust records
-- Based on query results from PUBPOTR application
-- Participant: SKJOLDBRAND-ZERO THRAIN (ID: 10065286)
-- Organization: 10065190
-- =====================================================================

-- =====================================================================
-- SECTION 1: Upsert rows for POSOTR_001 basis
-- =====================================================================

-- Row 1: Future start no end - POSOTR_001
upsert_row(
    p_app_key  => 'PUBPOTR',
    p_org_id   => '10065190',
    p_part_id  => '10065286',
    p_name     => 'SKJOLDBRAND-ZERO THRAIN',
    p_basis    => 'POSOTR_001',
    p_title    => NULL,
    p_pos      => 'Future start no end',
    p_entity   => 'CEO',
    p_end_date => TO_DATE('31-DEC-99', 'DD-MON-YY')
);

-- Row 2: No start no end - POSOTR_001
upsert_row(
    p_app_key  => 'PUBPOTR',
    p_org_id   => '10065190',
    p_part_id  => '10065286',
    p_name     => 'SKJOLDBRAND-ZERO THRAIN',
    p_basis    => 'POSOTR_001',
    p_title    => NULL,
    p_pos      => 'No start no end',
    p_entity   => 'CEO',
    p_end_date => TO_DATE('31-DEC-99', 'DD-MON-YY')
);

-- Row 3: Past start No end - POSOTR_001
upsert_row(
    p_app_key  => 'PUBPOTR',
    p_org_id   => '10065190',
    p_part_id  => '10065286',
    p_name     => 'SKJOLDBRAND-ZERO THRAIN',
    p_basis    => 'POSOTR_001',
    p_title    => NULL,
    p_pos      => 'Past start No end',
    p_entity   => 'CEO',
    p_end_date => TO_DATE('31-DEC-99', 'DD-MON-YY')
);

-- =====================================================================
-- SECTION 2: Upsert rows for POT Custom second basis
-- =====================================================================

-- Row 4: Future start no end - POT Custom second basis
upsert_row(
    p_app_key  => 'PUBPOTR',
    p_org_id   => '10065190',
    p_part_id  => '10065286',
    p_name     => 'SKJOLDBRAND-ZERO THRAIN',
    p_basis    => 'POT',
    p_title    => 'Custom second basis',
    p_pos      => 'Future start no end',
    p_entity   => 'CEO',
    p_end_date => TO_DATE('31-DEC-99', 'DD-MON-YY')
);

-- Row 5: No start no end - POT Custom second basis
upsert_row(
    p_app_key  => 'PUBPOTR',
    p_org_id   => '10065190',
    p_part_id  => '10065286',
    p_name     => 'SKJOLDBRAND-ZERO THRAIN',
    p_basis    => 'POT',
    p_title    => 'Custom second basis',
    p_pos      => 'No start no end',
    p_entity   => 'CEO',
    p_end_date => TO_DATE('31-DEC-99', 'DD-MON-YY')
);

-- Row 6: Past start No end - POT Custom second basis
upsert_row(
    p_app_key  => 'PUBPOTR',
    p_org_id   => '10065190',
    p_part_id  => '10065286',
    p_name     => 'SKJOLDBRAND-ZERO THRAIN',
    p_basis    => 'POT',
    p_title    => 'Custom second basis',
    p_pos      => 'Past start No end',
    p_entity   => 'CEO',
    p_end_date => TO_DATE('31-DEC-99', 'DD-MON-YY')
);

-- =====================================================================
-- COMMIT
-- =====================================================================
COMMIT;

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
