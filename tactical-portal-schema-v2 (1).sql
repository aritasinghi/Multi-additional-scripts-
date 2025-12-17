-- ====================================================================
-- TACTICAL PORTAL DATABASE SCHEMA v2.0
-- ====================================================================
-- Simplified 3-table design with multi-language support
-- Tables: notification_templates, notifications, contacts
-- Languages: English (EN), Finnish (FI), Swedish (SWE)
-- ====================================================================

-- ====================================================================
-- TABLE 1: NOTIFICATION_TEMPLATES
-- ====================================================================
-- Reusable message templates (optional usage)

CREATE TABLE notification_templates (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    -- Multi-Language Titles
    title_en VARCHAR(500) 
        COMMENT 'Template title in English',
    title_fi VARCHAR(500) 
        COMMENT 'Template title in Finnish',
    title_swe VARCHAR(500) 
        COMMENT 'Template title in Swedish',
    
    -- Multi-Language Message Templates
    message_template_en TEXT 
        COMMENT 'Message template in English',
    message_template_fi TEXT 
        COMMENT 'Message template in Finnish',
    message_template_swe TEXT 
        COMMENT 'Message template in Swedish',
    
    -- Tracking
    created_by VARCHAR(255) NOT NULL 
        COMMENT 'Username who created this template',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'When template was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
        COMMENT 'Last modification time',
    
    -- Indexes
    INDEX idx_created_at (created_at)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Reusable notification templates with multi-language support';


-- ====================================================================
-- TABLE 2: NOTIFICATIONS
-- ====================================================================
-- Individual notification instances

CREATE TABLE notifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    -- Template Reference (Optional)
    template_id BIGINT 
        COMMENT 'Optional reference to template (NULL for custom notifications)',
    
    -- Multi-Language Content
    title_en VARCHAR(500) NOT NULL 
        COMMENT 'Notification title in English',
    title_fi VARCHAR(500) 
        COMMENT 'Notification title in Finnish',
    title_swe VARCHAR(500) 
        COMMENT 'Notification title in Swedish',
    message_en TEXT NOT NULL 
        COMMENT 'Notification message in English',
    message_fi TEXT 
        COMMENT 'Notification message in Finnish',
    message_swe TEXT 
        COMMENT 'Notification message in Swedish',
    
    -- Status Flags (2 booleans - not VARCHAR)
    is_active BOOLEAN NOT NULL DEFAULT TRUE 
        COMMENT 'Admin toggle: enable/disable notification',
    is_ended BOOLEAN NOT NULL DEFAULT FALSE 
        COMMENT 'Tab routing: FALSE=Active tab, TRUE=Ended tab',
    
    -- Scheduling
    start_time TIMESTAMP NULL 
        COMMENT 'When notification becomes active',
    end_time TIMESTAMP NULL 
        COMMENT 'When notification ends (checked on fetch to update is_ended)',
    
    -- Targeting (Optional)
    target_roles VARCHAR(500) 
        COMMENT 'Comma-separated role codes for targeting',
    target_countries VARCHAR(100) 
        COMMENT 'Comma-separated country codes',
    
    -- Extensibility
    additional_info TEXT 
        COMMENT 'JSON field for custom data',
    
    -- Tracking
    created_by VARCHAR(255) NOT NULL 
        COMMENT 'Username who created this notification',
    updated_by VARCHAR(255) 
        COMMENT 'Username who last updated this',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Creation timestamp',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
        COMMENT 'Last update timestamp',
    
    -- Indexes for performance
    INDEX idx_ended (is_ended),
    INDEX idx_active (is_active),
    INDEX idx_template (template_id),
    INDEX idx_start_time (start_time),
    INDEX idx_end_time (end_time),
    INDEX idx_composite (is_ended, is_active, start_time),
    
    -- Foreign Key (optional template reference)
    CONSTRAINT fk_notification_template 
        FOREIGN KEY (template_id) 
        REFERENCES notification_templates(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
        
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Notification instances with 2-flag status system';


-- ====================================================================
-- TABLE 3: CONTACTS
-- ====================================================================
-- Contact information with multi-language support
-- Simplified single table - no separate contact_types needed

CREATE TABLE contacts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    -- Country
    country_code VARCHAR(10) NOT NULL 
        COMMENT 'Country code: FI (Finland) or SWE (Sweden)',
    
    -- Multi-Language Contact Type Names
    contact_type_name_en VARCHAR(255) NOT NULL 
        COMMENT 'Contact type in English (e.g., "Issuer services")',
    contact_type_name_fi VARCHAR(255) 
        COMMENT 'Contact type in Finnish (e.g., "Liikkeeseenlaskijapalvelut")',
    contact_type_name_swe VARCHAR(255) 
        COMMENT 'Contact type in Swedish (e.g., "Emittentservice")',
    
    -- Contact Details (Required)
    email VARCHAR(255) NOT NULL 
        COMMENT 'Contact email address',
    phone VARCHAR(50) NOT NULL 
        COMMENT 'Contact phone number with country code',
    
    -- Multi-Language Responsibilities/Description
    responsibilities_en TEXT 
        COMMENT 'Responsibilities/description in English',
    responsibilities_fi TEXT 
        COMMENT 'Responsibilities/description in Finnish',
    responsibilities_swe TEXT 
        COMMENT 'Responsibilities/description in Swedish',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Record creation time',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
        COMMENT 'Last update time',
    
    -- Indexes for performance
    INDEX idx_country_code (country_code)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Contact information with multi-language support for FI and SWE';


-- ====================================================================
-- SEED DATA - NOTIFICATION TEMPLATES
-- ====================================================================

INSERT INTO notification_templates (
    title_en, title_fi, title_swe,
    message_template_en, message_template_fi, message_template_swe,
    created_by
) VALUES
(
    'Portal Maintenance',
    'Portaalin huolto',
    'Portalunderhåll',
    'The portal will be unavailable for scheduled maintenance from {start_time} to {end_time}.',
    'Portaali ei ole käytettävissä suunnitellun huollon vuoksi {start_time} - {end_time}.',
    'Portalen är inte tillgänglig för planerat underhåll från {start_time} till {end_time}.',
    'admin'
),
(
    'System Update',
    'Järjestelmäpäivitys',
    'Systemuppdatering',
    'A system update will be deployed on {date}. Please save your work.',
    'Järjestelmäpäivitys otetaan käyttöön {date}. Tallenna työsi.',
    'En systemuppdatering kommer att distribueras {date}. Spara ditt arbete.',
    'admin'
);


-- ====================================================================
-- SEED DATA - NOTIFICATIONS
-- ====================================================================

INSERT INTO notifications (
    title_en, title_fi, title_swe,
    message_en, message_fi, message_swe,
    is_active, is_ended,
    start_time, end_time,
    created_by
) VALUES
(
    'Welcome to Tactical Portal',
    'Tervetuloa taktiseen portaaliin',
    'Välkommen till taktisk portal',
    'Welcome to the new Tactical Portal. Explore the features and services.',
    'Tervetuloa uuteen taktiseen portaaliin. Tutustu ominaisuuksiin ja palveluihin.',
    'Välkommen till den nya taktiska portalen. Utforska funktioner och tjänster.',
    TRUE,
    FALSE,
    '2025-12-01 00:00:00',
    '2026-01-31 23:59:59',
    'admin'
);


-- ====================================================================
-- SEED DATA - CONTACTS
-- ====================================================================

INSERT INTO contacts (
    country_code, 
    contact_type_name_en, contact_type_name_fi, contact_type_name_swe,
    email, phone,
    responsibilities_en, responsibilities_fi, responsibilities_swe
) VALUES

-- ====================================================================
-- FINLAND CONTACTS
-- ====================================================================

('FI', 
 'Issuer services', 
 'Liikkeeseenlaskijapalvelut', 
 'Emittentservice',
 'issuer.services@euroclear.fi', 
 '+358 20 770 6539',
 'Shareholder Information, General Meeting Services, Insider Register Services',
 'Osakastiedot, Yhtiökokoukset, Sisäpiirirekisteri',
 'Aktieägarinformation, Bolagsstämma, Insiderregister'),

('FI', 
 'Asset Servicing', 
 'Omaisuudenhoitopalvelut', 
 'Kapitalförvaltning',
 'corporate.actions@euroclear.fi', 
 '+358 20 770 6648',
 'Corporate Actions, Dividend Payments, Income Distribution',
 'Yritystapahtumien käsittely, Osingonmaksut, Tulonjako',
 'Företagshändelser, Utdelningar, Inkomstfördelning'),

('FI', 
 'Debt market instruments', 
 'Velkamarkkinainstrumentit', 
 'Skuldinstrument',
 'debt.market@euroclear.fi', 
 '+358 20 770 6700',
 'Bond Issuance, Debt Securities Management, Interest Payments',
 'Joukkolainojen liikkeeseenlasku, Velkapaperien hallinta, Korkomaksut',
 'Obligationsemission, Skuldförvaltning, Räntebetalningar'),

('FI', 
 'Registrations', 
 'Rekisteröinnit', 
 'Registreringar',
 'registrations@euroclear.fi', 
 '+358 20 770 6500',
 'Security Registration, Account Registration, Book-Entry System',
 'Arvopapereiden rekisteröinti, Tilin rekisteröinti, Arvo-osuusjärjestelmä',
 'Värdepappersregistrering, Kontoregistrering, Värdeandelssystem'),

('FI', 
 'Settlement', 
 'Selvitys', 
 'Avveckling',
 'settlement@euroclear.fi', 
 '+358 20 770 6600',
 'Trade Settlement, Clearing Services, Payment Processing',
 'Kauppojen selvitys, Clearingpalvelut, Maksujenkäsittely',
 'Handelsavveckling, Clearingtjänster, Betalningsbehandling'),

('FI', 
 'Service Desk', 
 'Asiakaspalvelu', 
 'Kundservice',
 'servicedesk.finland@euroclear.fi', 
 '+358 20 770 6000',
 'General Customer Support, Technical Assistance, Account Inquiries',
 'Yleinen asiakastuki, Tekninen tuki, Tilitiedustelut',
 'Allmän kundsupport, Teknisk support, Kontoförfrågningar'),

-- ====================================================================
-- SWEDEN CONTACTS
-- ====================================================================

('SWE', 
 'Issuer services', 
 'Liikkeeseenlaskijapalvelut', 
 'Emittentservice',
 'issuer.services@euroclear.se', 
 '+46 8 402 9100',
 'Shareholder Information, General Meeting Services, Corporate Governance',
 'Osakastiedot, Yhtiökokoukset, Hallinnointipalvelut',
 'Aktieägarinformation, Bolagsstämma, Företagsstyrning'),

('SWE', 
 'Orders', 
 'Tilaukset', 
 'Beställningar',
 'orders@euroclear.se', 
 '+46 8 402 9111',
 'Order Processing, Trade Execution, Transaction Services',
 'Tilausten käsittely, Kauppojen toteutus, Transaktiopalvelut',
 'Orderbehandling, Handelsutförande, Transaktionstjänster'),

('SWE', 
 'Securities information', 
 'Arvopaperitiedot', 
 'Värdepappersinformation',
 'securities.info@euroclear.se', 
 '+46 8 402 9150',
 'Security Master Data, ISIN Information, Corporate Actions Data',
 'Arvopaperien perustiedot, ISIN-tiedot, Yritystapahtumat',
 'Värdepappersdata, ISIN-information, Företagshändelsedata'),

('SWE', 
 'Analysts', 
 'Analyytikot', 
 'Analytiker',
 'analysts@euroclear.se', 
 '+46 8 402 9147',
 'Market Analysis, Research Services, Data Analytics',
 'Markkina-analyysi, Tutkimuspalvelut, Data-analytiikka',
 'Marknadsanalys, Forskningstjänster, Dataanalys'),

('SWE', 
 'Bond/Payments', 
 'Joukkolainat/Maksut', 
 'Obligationer/Betalningar',
 'bond.payments@euroclear.se', 
 '+46 8 402 9160',
 'Bond Payments, Coupon Distribution, Redemption Services',
 'Joukkolainamaksut, Kuponkijaot, Lunastuspalvelut',
 'Obligationsbetalningar, Kupongdistribution, Inlösningstjänster'),

('SWE', 
 'Customer Support', 
 'Asiakastuki', 
 'Kundsupport',
 'support@euroclear.se', 
 '+46 8 402 9000',
 'General Support, Account Services, Technical Help',
 'Yleinen tuki, Tilipalvelut, Tekninen apu',
 'Allmän support, Kontotjänster, Teknisk hjälp');


-- ====================================================================
-- VERIFICATION QUERIES
-- ====================================================================

-- Count records in each table
-- SELECT 'notification_templates' AS table_name, COUNT(*) AS record_count FROM notification_templates
-- UNION ALL
-- SELECT 'notifications', COUNT(*) FROM notifications
-- UNION ALL
-- SELECT 'contacts', COUNT(*) FROM contacts;

-- Get Finland contacts
-- SELECT 
--     contact_type_name_en AS type_en,
--     contact_type_name_fi AS type_fi,
--     email, phone, 
--     responsibilities_en
-- FROM contacts 
-- WHERE country_code = 'FI';

-- Get Sweden contacts
-- SELECT 
--     contact_type_name_en AS type_en,
--     contact_type_name_swe AS type_swe,
--     email, phone, 
--     responsibilities_en
-- FROM contacts 
-- WHERE country_code = 'SWE';
