// Functions lint yapılandırması (TASK 039) — TypeScript recommended seti.
import tseslint from "typescript-eslint";

export default tseslint.config(
  { ignores: ["lib/**", "node_modules/**"] },
  ...tseslint.configs.recommended
);
