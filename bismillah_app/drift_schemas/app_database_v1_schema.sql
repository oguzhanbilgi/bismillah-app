-- Bismillah AppDatabase canonical schema snapshot
-- GENERATED from the running database (sqlite_master).
-- Do NOT edit by hand. See drift_schemas/README.md.
-- schemaVersion / PRAGMA user_version: 1

CREATE INDEX prayer_log_days_updated_at ON prayer_log_days (updated_at);

CREATE INDEX sync_operations_entity ON sync_operations (entity_type, entity_id);

CREATE INDEX sync_operations_status_next_retry_at ON sync_operations (status, next_retry_at);

CREATE TABLE "prayer_entries" ("day_key" TEXT NOT NULL REFERENCES prayer_log_days (day_key) ON DELETE CASCADE, "prayer_name" TEXT NOT NULL, "status" TEXT NOT NULL, "logged_at" INTEGER NULL, "undone" INTEGER NOT NULL DEFAULT 0 CHECK ("undone" IN (0, 1)), PRIMARY KEY ("day_key", "prayer_name"));

CREATE TABLE "prayer_log_days" ("day_key" TEXT NOT NULL, "device_id" TEXT NOT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("day_key"));

CREATE TABLE "sync_operations" ("operation_id" TEXT NOT NULL, "uid" TEXT NOT NULL, "device_id" TEXT NOT NULL, "entity_type" TEXT NOT NULL, "entity_id" TEXT NOT NULL, "operation_type" TEXT NOT NULL, "payload_ref" TEXT NOT NULL, "payload_hash" TEXT NOT NULL, "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, "retry_count" INTEGER NOT NULL DEFAULT 0, "next_retry_at" INTEGER NULL, "status" TEXT NOT NULL, "last_error_code" TEXT NULL, "idempotency_key" TEXT NOT NULL, "sensitivity_class" TEXT NOT NULL, PRIMARY KEY ("operation_id"));
