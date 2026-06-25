# 📦 NPM Offline Package Collection

Pre-downloaded `node_modules` for 11 web development framework configurations.
Built for offline development environments — no internet required after setup.

---

## 🗂 Frameworks Included

| Folder | Framework | Key Packages |
|--------|-----------|-------------|
| `typescript-vite` | React 18 + TypeScript + Vite | AG Grid Enterprise, Syncfusion (all), MUI v6, POS printing, MSSQL, PostgreSQL |
| `react-vite` | React 18 + Vite | Full React ecosystem, charting, state management |
| `nextjs` | Next.js 14 | App Router, Auth.js, SEO, i18n |
| `vuejs-vite` | Vue 3 + Vite | Vuetify, Element Plus, Naive UI, Pinia |
| `nuxt` | Nuxt 3 | Nuxt UI, @nuxtjs/*, content, image |
| `angular` | Angular 18 | NgRx, Angular Material, PrimeNG, Syncfusion Angular |
| `svelte` | SvelteKit | SMUI, Threlte (3D), SvelteKit adapters |
| `remix` | Remix v2 | remix-auth, remix-utils, full React ecosystem |
| `astro` | Astro 4 | Multi-framework (React/Vue/Svelte), MDX, SSG/SSR |
| `gatsby` | Gatsby 5 | Source plugins, image, MDX, i18n |
| `nodejs-backend` | Node.js Backend | Express, Fastify, NestJS, Hono, MSSQL, PostgreSQL, Redis |

---

## 🚀 Quick Start

### Option 1 — Download from Releases (Recommended)

1. Go to the [**Releases**](../../releases) page
2. Download the tarball for your framework (e.g. `typescript-vite-node_modules.tar.gz`)
   - Or download `npm-offline-all-frameworks-vX.X.X.tar.gz` for everything
3. Extract into your project:

**Linux / macOS:**
```bash
tar -xzf typescript-vite-node_modules.tar.gz -C /path/to/your/project/
```

**Windows (PowerShell):**
```powershell
tar -xzf typescript-vite-node_modules.tar.gz -C C:\path\to\project\
```

### Option 2 — Use the Install Scripts (in cumulative tarball)

**Linux / macOS:**
```bash
# Extract the cumulative tarball first
tar -xzf npm-offline-all-frameworks-v1.0.0.tar.gz

# Then install a specific framework
chmod +x install-offline.sh
./install-offline.sh typescript-vite /path/to/your/project

# Or install all frameworks
./install-offline.sh all /path/to/projects/
```

**Windows (PowerShell):**
```powershell
.\install-offline.ps1 -Framework typescript-vite -TargetPath C:\path\to\project
# Or all frameworks:
.\install-offline.ps1 -Framework all -TargetPath C:\projects
```

### Option 3 — Run the Workflow Yourself

1. Fork this repo
2. Go to **Actions → Download NPM Packages & Create Release**
3. Click **Run workflow**
4. Enter a tag (e.g. `v1.0.0`) and click **Run**
5. Wait ~15–30 minutes for all parallel downloads to complete
6. Download your release from the **Releases** page

---

## ⚙️ After Extracting

Your project folder will contain:
```
your-project/
├── node_modules/     ← extracted from tarball
├── package.json      ← copied automatically by install script
└── .npmrc            ← sets prefer-offline=true
```

To install any additional packages or resolve lockfiles:
```bash
npm install --prefer-offline --legacy-peer-deps
```

---

## 🔧 Requirements

- **Node.js** >= 20.0.0
- **npm** >= 10.0.0
- **tar** (built into Linux, macOS, Windows 10+)

---

## 📋 Package Counts

| Framework | Dependencies | DevDependencies | Total |
|-----------|-------------|-----------------|-------|
| typescript-vite | 621 | 251 | **872** |
| react-vite | 621 | 251 | **872** |
| nextjs | 485 | 180 | **665** |
| vuejs-vite | 313 | 197 | **510** |
| nuxt | 287 | 130 | **417** |
| angular | 296 | 190 | **486** |
| svelte | 258 | 175 | **433** |
| remix | 461 | 174 | **635** |
| astro | 313 | 158 | **471** |
| gatsby | 392 | 192 | **584** |
| nodejs-backend | 447 | 201 | **648** |

---

## 🏗 How the Workflow Works

```
Push tag / Manual trigger
        │
        ▼
┌─────────────────────────────────────┐
│  11 parallel jobs (one per framework)│
│  Each:                               │
│    1. npm install --legacy-peer-deps │
│    2. tar -czf node_modules.tar.gz   │
│    3. Upload artifact                │
└──────────────┬──────────────────────┘
               │  all complete
               ▼
┌─────────────────────────────────────┐
│  create-release job                 │
│    1. Download all 11 artifacts     │
│    2. Bundle into cumulative tarball│
│    3. Publish GitHub Release with   │
│       all tarballs as assets        │
└─────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
npm-offline-repo/
├── .github/
│   └── workflows/
│       └── download-packages.yml    ← Main workflow
├── packages/
│   ├── typescript-vite/
│   │   └── package.json
│   ├── react-vite/
│   │   └── package.json
│   ├── nextjs/
│   │   └── package.json
│   ├── vuejs-vite/
│   │   └── package.json
│   ├── nuxt/
│   │   └── package.json
│   ├── angular/
│   │   └── package.json
│   ├── svelte/
│   │   └── package.json
│   ├── remix/
│   │   └── package.json
│   ├── astro/
│   │   └── package.json
│   ├── gatsby/
│   │   └── package.json
│   └── nodejs-backend/
│       └── package.json
├── scripts/
│   ├── install-offline.sh           ← Linux/macOS installer
│   └── install-offline.ps1          ← Windows installer
└── README.md
```

---

## ⚠️ Notes

- All packages installed with `--legacy-peer-deps` for maximum compatibility
- Some native addons (e.g. `sharp`, `argon2`, `better-sqlite3`) may need
  recompilation for your target OS/architecture after extraction
- The `node_modules` tarballs are built on **Ubuntu** (GitHub Actions runner)
- For Windows targets, native modules may need: `npm rebuild`
- Tarball sizes vary: expect 500MB–2GB per framework uncompressed

---

## 📜 License

MIT — free to use, modify, and distribute.
