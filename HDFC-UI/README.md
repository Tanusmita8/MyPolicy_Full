# HDFC Insurance Dashboard - Flutter UI

A Flutter implementation of the HDFC Bank insurance dashboard, featuring Material 3 design with custom HDFC branding.

## 🎨 Features

- **Material 3** with custom HDFC theme
- **Responsive layout** - adapts to desktop/tablet/mobile
- **Reusable widgets** - clean, modular architecture
- **Category filtering** - filter policies by type
- **Dynamic status badges** - Active (green) / Due (yellow) / expired (grey)
- **Indian currency formatting** - proper ₹ symbol and number formatting
- **Null safety** enabled

## Backend integration (direct microservices, no BFF)

Default base URLs:

| Service | Port | Role |
|--------|------|------|
| **customer-service** | 8081 | Login, `GET /api/v1/customers/details/{id}` → `customer_details` |
| **policy-service** | 8085 | Profile & policy detail from read models (`customer_details` + `unified_portfolio`) |
| **data-pipeline-service** | 8082 | `GET /api/portfolio/{id}`, `GET /api/advisory/{id}` |

The Flutter app merges **customer_details** + **unified_portfolio** for the dashboard (same data the BFF used to aggregate).

- **Insurance insights** (`insights_screen.dart`): loads portfolio + advisory from the pipeline, then computes per-category current vs recommended cover and gaps (same thresholds as server advisory: life = premium×10, health ≥ ₹3L per policy, vehicle ≥ ₹1L per policy).

- **Login**: `POST /api/v1/customers/login` — full name + PAN matching `customer_details`.

Override URLs (optional):

`flutter run -d chrome --dart-define=CUSTOMER_SERVICE_URL=http://localhost:8081 --dart-define=POLICY_SERVICE_URL=http://localhost:8085 --dart-define=DATA_PIPELINE_URL=http://localhost:8082`

## 📁 Folder Structure

lib/
├── main.dart                    # App entry point
├── models/
│   └── policy_model.dart        # Policy data model
├── screens/
│   ├── analytical_dashboard.dart # Analytical dashboard with charts
│   ├── dashboard_screen.dart    # Main dashboard screen
│   ├── login_screen.dart        # User login screen
│   ├── policy_detail_screen.dart # Detailed policy view
│   ├── recovery_otp_screen.dart  # OTP verification for recovery
│   └── recovery_verification_screen.dart # Recovery process verification
├── theme/
│   └── app_theme.dart           # Theme configuration
└── widgets/
    ├── category_filter.dart     # Filter pill buttons
    ├── custom_appbar.dart       # HDFC branded AppBar
    ├── donut_chart.dart         # Custom donut chart for analytics
    ├── info_card.dart           # Informational cards
    ├── policy_card.dart         # Policy information cards
    └── summary_card.dart        # Metric summary cards
## Key Components

### CustomAppBar
- HDFC logo with blue background
- Customer name and ID
- Avatar with initials
- Logout button

### SummaryCard
- Icon with background
- Title and value
- Optional subtitle
- Soft shadow and border

### CategoryFilter
- Pill-shaped buttons
- Active/inactive states
- Smooth selection animation

### PolicyCard
- Shield icon
- Status badge (Active/Due)
- Policy details
- Premium and sum insured
- Arrow indicator

