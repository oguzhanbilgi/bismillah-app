# Drift schema snapshots

Bu klasör Bismillah'ın Drift/SQLite veritabanının **kanonik schema
snapshot'larını** tutar. Amaç: her `schemaVersion` için sabit bir referans
bırakmak ve gelecekteki migration'larda schema drift'ini yakalamak.

## Dosyalar

- `app_database_v1_schema.sql` — `schemaVersion = 1` için kanonik DDL
  (`prayer_log_days`, `prayer_entries`, `sync_operations` + index'leri).

## Snapshot GENERATED'dır — elle düzenlemeyin

Dosyalar çalışan veritabanının kendi `sqlite_master` DDL'inden **otomatik**
üretilir. Elle yazılmaz, elle düzenlenmez.

### Neden `drift_dev schema` CLI değil?

Bu repoda kurulu `drift` (2.34.1) + `drift_dev` (2.34.0) ikilisinde resmî
`dart run drift_dev schema` CLI'ı derlenmiyor (drift3_preview API skew:
`GeneratedDatabase.schema` / `allSchemaEntities`). CLI çalışır hâle geldiğinde
(veya sürümler hizalandığında) resmî Drift JSON snapshot'ına geçilmelidir; o
zamana kadar bu deterministik SQL snapshot kanonik kayıttır.

## Yeniden üretme (yeni schemaVersion öncesinde zorunlu)

Snapshot, test harness'ı üzerinden üretilir:

```powershell
cd C:\dev\Bismillah\bismillah_app
$env:SCHEMA_SNAPSHOT_UPDATE = "1"
flutter test test/core/storage/app_database_migration_test.dart
Remove-Item Env:\SCHEMA_SNAPSHOT_UPDATE
```

Üretim mantığı: `test/core/storage/schema_snapshot_util.dart`
(`dumpCanonicalSchema` → `sqlite_master`, tür+isme göre sıralı, makineden
bağımsız; path/timestamp içermez).

## Kural

`schemaVersion` yükseltmeden **önce** mevcut sürümün snapshot'ı alınmış
olmalı; migration testleri eski snapshot ile yeni runtime schema'yı
karşılaştırır.
