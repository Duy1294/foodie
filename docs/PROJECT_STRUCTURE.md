# 📁 CẤU TRÚC DỰ ÁN FOODIE

## Tổng quan

```
Foodie/
├── lib/                    # Flutter app source code
├── backend/                # Backend API (Node.js/Express)
├── assets/                 # Assets (images, icons)
├── docs/                   # Documentation
└── README.md              # Main documentation
```

## Chi tiết

### Flutter App (`lib/`)
```
lib/
├── main.dart              # Entry point
├── core/                  # Core functionality
│   ├── constants/        # Constants (API, colors, app)
│   ├── models/           # Data models
│   ├── services/         # Services (API, Auth, Storage)
│   └── utils/            # Utilities
├── features/             # Feature modules
│   ├── auth/             # Authentication
│   ├── home/             # Home screen
│   ├── restaurants/      # Restaurant features
│   ├── cart/             # Shopping cart
│   ├── orders/           # Order management
│   └── profile/          # User profile
└── shared/               # Shared components
    ├── themes/           # App themes
    └── widgets/          # Reusable widgets
```

### Backend (`backend/`)
```
backend/
├── src/
│   ├── config/           # Configuration
│   ├── models/           # Database models
│   ├── routes/           # API routes
│   ├── middleware/       # Middleware
│   └── utils/            # Utilities
├── .env                  # Environment variables
├── package.json          # Dependencies
└── README.md            # Backend documentation
```

### Documentation (`docs/`)
```
docs/
├── REQUIREMENTS.md                    # Requirements & permissions
├── TECHNICAL_IMPLEMENTATION.md        # Technical guide
├── DATABASE_SCHEMA.md                 # Database schema
└── PERMISSIONS_QUICK_REFERENCE.md     # Permissions reference
```

## File quan trọng

### Root
- `README.md` - Main documentation
- `pubspec.yaml` - Flutter dependencies
- `.gitignore` - Git ignore rules
- `analysis_options.yaml` - Dart linter rules

### Backend
- `backend/package.json` - Node.js dependencies
- `backend/.env` - Environment variables (not in git)
- `backend/ENV_TEMPLATE.txt` - Environment template

---

**Cấu trúc này tuân theo Clean Architecture và best practices.**

