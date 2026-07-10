/// Build flavor'ları (06_FLUTTER_ARCHITECTURE §34).
enum Flavor { development, staging, production }

extension FlavorParsing on Flavor {
  static Flavor fromName(String? name) => switch (name) {
    'staging' => Flavor.staging,
    'production' => Flavor.production,
    _ => Flavor.development,
  };
}
