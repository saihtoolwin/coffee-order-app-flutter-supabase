# BrewOrder - Coffee Order System

A mobile coffee ordering application built with Flutter and Supabase, developed with assistance from AI coding agents.

## Features

- User authentication (login/register)
- Browse coffee menu
- Place orders
- View order history
- Persistent login state

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL)
- **State Management**: Built-in Flutter state management
- **Storage**: SharedPreferences for local storage
- **Environment**: flutter_dotenv

## Project Structure

```
lib/
├── main.dart                    # App entry point & auth wrapper
├── landing_page.dart            # Landing/home page
├── menu_page.dart               # Coffee menu display
├── pages/
│   ├── login_page.dart          # User login
│   ├── register_page.dart       # User registration
│   └── order_history_page.dart  # Order history view
└── services/
    ├── user_service.dart        # User authentication
    ├── product_service.dart     # Product/menu data
    └── order_service.dart       # Order management
```

## Getting Started

### Prerequisites

- Flutter SDK 3.9+
- Supabase account
- Xcode (for iOS development)
- Android SDK (for Android development)

### Installation

1. Clone the repository
2. Install dependencies:

```bash
flutter pub get
```

3. Create a `.env` file in the project root with your Supabase credentials:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Run the app:

```bash
flutter run
```

### Database Setup

The project includes a Supabase schema file (`supabase_schema.sql`) that defines the required tables. Import this into your Supabase project to set up the database.

## Built With AI Assistance

This project was developed with the assistance of:

- **opencode** - AI coding agent for task automation and code generation
- **Cursor** - AI-powered code editor

Both AI agents contributed to architecture decisions, code implementation, and optimization.

## License

This project is for educational/personal use.