# DeSci Launchpad

A decentralized science launchpad platform that enables communities to curate, fund, and launch BioDAOs, powered by Story Protocol.

## 📦 Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/piplabs/asclepius-monorepo.git
   cd asclepius-monorepo/frontend
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Run the development server**

   ```bash
   npm run dev
   ```

4. **Open your browser**
   ```
   http://localhost:3000
   ```

## 🏗️ Project Structure

```
desci-launchpad/
├── app/
│   ├── components/
│   │   ├── ui/              # Reusable UI components
│   │   ├── project/         # Project-specific components
│   │   └── layout/          # Layout components
│   ├── project/[id]/        # Dynamic project pages
│   ├── globals.css          # Global styles
│   ├── layout.tsx           # Root layout
│   └── page.tsx             # Homepage
├── lib/
│   ├── data/                # Mock data and utilities
│   ├── types/               # TypeScript interfaces
│   └── utils/               # Utility functions
└── public/                  # Static assets
```
