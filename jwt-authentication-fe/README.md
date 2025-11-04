# JWT Authentication Frontend

A React + TypeScript + Vite application with Material-UI (MUI) for JWT authentication.

## Tech Stack

- **React 19** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Material-UI (MUI)** - Component library
- **Emotion** - CSS-in-JS styling (required by MUI)

## Project Structure

```
src/
├── components/       # Reusable UI components
│   ├── Base/         # Base/foundation components
│   └── Common/       # Common shared components
├── containers/       # Container components/page logic
├── hooks/            # Custom React hooks
├── utils/            # Utility functions
├── types/            # TypeScript type definitions
├── services/         # Service classes (API calls, etc.)
├── configs/          # Configuration files (theme, etc.)
└── styles/           # Global styles
```

## Getting Started

### Installation

```bash
npm install
```

### Development

```bash
npm run dev
```

### Build

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## Code Conventions

This project follows the Bitkub Infinity code conventions:

- **Components**: PascalCase (e.g., `Button.tsx`, `HomeContainer.tsx`)
- **Hooks**: camelCase starting with "use" (e.g., `useBoolean.ts`)
- **Utils**: camelCase (e.g., `function.ts`, `number.ts`)
- **Types**: PascalCase (e.g., `User`, `IUserLoginParams`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)
