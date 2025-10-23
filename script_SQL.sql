-- Extensiones recomendadas para el manejo de la seguridad de los datos
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla ciudadano
CREATE TABLE ciudadano (
  ciudadano_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  national_id varchar(50) UNIQUE NOT NULL,
  given_name text NOT NULL,
  family_name text NOT NULL,
  birth_date date,
  contact jsonb, -- phone/email as JSON
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz
);

-- Tabla enrolamiento
CREATE TABLE enrolamiento (
  enrolamiento_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  ciudadano_id uuid REFERENCES ciudadano(ciudadano_id) ON DELETE CASCADE,
  channel varchar(20) NOT NULL, -- web/mobile/api
  provider varchar(100),
  status varchar(20) NOT NULL,
  validation_result jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz
);

-- Biometric samples: sólo metadatos; datos binarios en blob storage cifrado
CREATE TABLE biometric_sample (
  sample_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  enrolamiento_id uuid REFERENCES enrolamiento(enrolamiento_id) ON DELETE CASCADE,
  sample_type varchar(20), -- fingerprint/face
  storage_uri text NOT NULL,
  hash text, -- sha256 hash of blob
  created_at timestamptz DEFAULT now()
);

-- consentimientosimientos
CREATE TABLE consentimientos (
  consentimientos_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  enrolamiento_id uuid REFERENCES enrolamiento(enrolamiento_id) ON DELETE CASCADE,
  consentimientos_text text,
  consentimientos_hash text,
  signed_at timestamptz,
  signature_uri text
);

-- Auditoría
CREATE TABLE auditoria_log (
  audit_id BIGSERIAL PRIMARY KEY,
  entity_type varchar(50),
  entity_id uuid,
  operation varchar(10),
  actor varchar(100),
  changes jsonb,
  created_at timestamptz DEFAULT now()
);

-- Indexes
CREATE INDEX idx_ciudadano_national_id ON ciudadano(national_id);
CREATE INDEX idx_enrolamiento_status ON enrolamiento(status);
CREATE INDEX idx_biometric_enrolamiento ON biometric_sample(enrolamiento_id);

-- Row Level Security (RLS) example for PII access control
ALTER TABLE ciudadano ENABLE ROW LEVEL SECURITY;
-- crear políticas según roles (ejemplo omitido por brevedad)
