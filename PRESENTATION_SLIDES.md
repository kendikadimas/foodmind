# FoodMind - AI Food Recommendation App
## Presentation Slides Content

---

## Slide 1: Title Slide
**FoodMind**
AI-Powered Food Recommendation System

Tagline: "Udah Laper? Bingung Mau Makan Apa? Tenang aja! Kita bantu cari makanan yang cocok sama selera kamu kok~"

Date: December 2025

---

## Slide 2: Problem Statement
### Masalah yang Dihadapi
- 🤔 Kebingungan memilih makanan sesuai mood dan budget
- 🏥 Kesulitan menemukan makanan yang aman untuk kondisi kesehatan tertentu
- 💰 Tidak tahu rekomendasi makanan dalam budget yang tersedia
- 📍 Susah mencari restoran terdekat yang sesuai preferensi
- 🕐 Membuang waktu untuk memutuskan mau makan apa

---

## Slide 3: Solution - FoodMind
### Solusi Kami
FoodMind adalah aplikasi mobile berbasis AI yang memberikan rekomendasi makanan personal berdasarkan:
- ✅ Preferensi rasa & gaya makan
- ✅ Budget harian
- ✅ Kondisi kesehatan & alergi
- ✅ Lokasi & cuaca saat ini
- ✅ Riwayat makanan favorit

---

## Slide 4: Key Features
### Fitur Utama

**1. AI Food Recommendation**
- Powered by OpenAI GPT
- Analisis preferensi mendalam
- Rekomendasi personal & akurat

**2. Smart Input System**
- Filter rasa (Manis, Pedas, Asin, dll)
- Style makanan (Fine dining, Street food, dll)
- Budget range
- Alergi & kondisi kesehatan

**3. Location Integration**
- GPS auto-detect
- Google Maps integration
- Cari restoran terdekat

---

## Slide 5: Key Features (Cont.)
### Fitur Utama (Lanjutan)

**4. Community Platform**
- Berbagi rekomendasi makanan
- Like & comment system
- Real-time updates
- User interaction

**5. Profile & History**
- Save preferences
- Auto-save riwayat
- Track budget harian
- Manage alergi & kondisi kesehatan

**6. Authentication**
- Email/Password login
- Google Sign-In
- Guest mode available

---

## Slide 6: Technology Stack
### Tech Stack

**Frontend:**
- Flutter (Cross-platform: Android, iOS, Web)
- Material Design 3
- Google Fonts (Poppins)

**Backend & Database:**
- Supabase (PostgreSQL)
- Real-time database
- Row Level Security (RLS)

**AI & APIs:**
- OpenAI GPT API
- Google Maps API
- Geolocator API
- Geocoding API

**Authentication:**
- Supabase Auth
- Google OAuth 2.0

**Local Storage:**
- Hive (Offline cache)

---

## Slide 7: Architecture
### System Architecture

```
┌─────────────────┐
│   Flutter App   │
│  (Mobile/Web)   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐  ┌─▼──────┐
│Supabase│  │ OpenAI │
│ (BaaS) │  │  API   │
└───┬────┘  └────────┘
    │
┌───▼─────────────┐
│   PostgreSQL    │
│   (Database)    │
└─────────────────┘
```

**Architecture Pattern:**
- Service Layer Architecture
- State Management: StatefulWidget
- Responsive UI Design

---

## Slide 8: Database Schema
### Database Structure

**Users Table:**
- User profile data
- Preferences & allergies
- Medical conditions
- Budget settings

**Posts Table:**
- Community posts
- Likes & responses (JSONB)
- Location data
- Real-time updates

**Security:**
- Row Level Security (RLS)
- User-specific data isolation
- Authenticated access only

---

## Slide 9: User Flow
### App Navigation Flow

```
Landing Page
     ↓
Login/Register ←→ Skip (Guest Mode)
     ↓
Onboarding Preferences (New User)
     ↓
Main App (TabBar)
     ├─→ Input Page (AI Search)
     ├─→ Community (Posts)
     └─→ Profile (Settings)
```

**Guest Mode:**
- ✅ Search makanan
- ✅ View community (read-only)
- ❌ Post/comment
- ❌ Save preferences

---

## Slide 10: AI Recommendation Process
### How AI Works

**Input Analysis:**
1. User preferences (taste, style, budget)
2. Health conditions & allergies
3. Current location & weather
4. Historical data

**AI Processing:**
- OpenAI GPT analyzes all inputs
- Generates personalized recommendations
- Considers safety & allergies
- Matches with nearby restaurants

**Output:**
- Primary recommendation
- Alternative options
- Price estimates
- Location & maps

---

## Slide 10B: Data Flow Diagram - Food Recommendation
### Technical Architecture Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          1. INPUT PAGE (UI Layer)                        │
│                         lib/pages/input_page.dart                        │
├─────────────────────────────────────────────────────────────────────────┤
│  User Input Collection:                                                  │
│  • Taste Tags: Set<String> selectedTastes (Asin, Pedas, Manis, dll)    │
│  • Style Tags: Set<String> selectedStyles (Berkuah, Kering, dll)       │
│  • Weather: String selectedWeather (Cerah, Hujan, dll)                 │
│  • Budget: String from TextEditingController (e.g., "25000")            │
│  • Allergies: String from TextEditingController (e.g., "kacang, susu")  │
│  • Likes: String from TextEditingController (e.g., "ayam, seafood")     │
│  • Location: Position? _currentPosition (lat/long from GPS)             │
│  • Location Name: String? _locationName (e.g., "Bandung, Jawa Barat")   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Navigator.pushNamed('/reasoning')
                                    │ with arguments: Map<String, dynamic>
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      2. REASONING PAGE (Processing Layer)                │
│                       lib/pages/reasoning_page.dart                      │
├─────────────────────────────────────────────────────────────────────────┤
│  Data Transformation:                                                    │
│  • taste: selectedTastes.join(', ') → "Asin, Pedas"                    │
│  • style: selectedStyles.join(', ') → "Berkuah, Pakai Nasi"            │
│  • weather: selectedWeather → "Hujan"                                   │
│  • position: Position? (latitude, longitude)                            │
│  • allergies: String + healthConditions                                 │
│  • likes: String + budget info                                          │
│                                                                          │
│  UI State: FutureBuilder<Map<String, dynamic>>                          │
│  • Shows loading animation with CircularProgressIndicator               │
│  • Displays "Sedang Mencari Rekomendasi..." message                     │
│  • Calls: _foodRecommendation = OpenAIService.getFoodRecommendation()   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ async API call
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    3. OPENAI SERVICE (Business Logic)                    │
│                     lib/services/openai_service.dart                     │
├─────────────────────────────────────────────────────────────────────────┤
│  Step 3.1: Rate Limiting Check                                           │
│  • RateLimiter: 3 requests per minute                                   │
│  • Returns error if limit exceeded with waitTime                        │
│                                                                          │
│  Step 3.2: Cache Check                                                   │
│  • Generate cacheKey from all parameters                                │
│  • If valid cache exists (< 30 min), return cached data                 │
│                                                                          │
│  Step 3.3: Historical Data Analysis                                      │
│  • _getFrequentlyEatenFoods() from Hive                                 │
│  • Finds foods eaten > 2 times to avoid repetition                      │
│  • Returns List<String> frequentFoods                                   │
│                                                                          │
│  Step 3.4: Location-Based Search (if position != null)                  │
│  • _findNearbyFoods(lat, long) → Foursquare API                         │
│  • Radius: 5km, Category: Restaurants (13000)                           │
│  • Returns: List<String> nearbyFoods + Map locationData                 │
│                                                                          │
│  Step 3.5: AI Provider Selection                                        │
│  • aiProvider = 'gemini' (default)                                      │
│  • Calls: _callGeminiAPI() with all parameters                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTP POST Request
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    4. GEMINI API (External AI Service)                   │
│          https://generativelanguage.googleapis.com/v1beta/              │
├─────────────────────────────────────────────────────────────────────────┤
│  Request Structure:                                                      │
│  • URL: /models/gemini-2.5-flash:generateContent?key={API_KEY}         │
│  • Method: POST                                                          │
│  • Content-Type: application/json                                       │
│  • Timeout: 30 seconds                                                   │
│                                                                          │
│  Request Body:                                                           │
│  {                                                                       │
│    "contents": [{                                                        │
│      "parts": [{                                                         │
│        "text": "PROMPT with all user inputs + rules"                    │
│      }]                                                                  │
│    }]                                                                    │
│  }                                                                       │
│                                                                          │
│  Prompt Engineering:                                                     │
│  • Input: taste, style, weather, allergies, likes, budget               │
│  • Context: nearbyFoods list, frequentFoods (to avoid)                  │
│  • Rules:                                                                │
│    - NEVER recommend foods with allergens                               │
│    - NEVER recommend frequentFoods                                      │
│    - Prioritize liked ingredients                                       │
│    - Match with nearby restaurants if available                         │
│    - Consider weather (e.g., hot soup for rain)                         │
│  • Output Format: Strict JSON only                                      │
│                                                                          │
│  AI Processing:                                                          │
│  • Analyzes all inputs holistically                                     │
│  • Generates contextual reasoning                                       │
│  • Returns structured JSON response                                     │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTP 200 OK Response
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    5. RESPONSE PARSING (Service Layer)                   │
│                     lib/services/openai_service.dart                     │
├─────────────────────────────────────────────────────────────────────────┤
│  Raw Response:                                                           │
│  {                                                                       │
│    "candidates": [{                                                      │
│      "content": {                                                        │
│        "parts": [{                                                       │
│          "text": "```json\n{...}\n```"                                  │
│        }]                                                                │
│      }                                                                   │
│    }]                                                                    │
│  }                                                                       │
│                                                                          │
│  Parsing Steps:                                                          │
│  1. Extract text from candidates[0].content.parts[0].text               │
│  2. Clean markdown: remove ```json and ``` markers                      │
│  3. jsonDecode() to Map<String, dynamic>                                │
│                                                                          │
│  Parsed Data Structure:                                                 │
│  {                                                                       │
│    "main_food": "Soto Ayam",                                            │
│    "alternatives": ["Bakso", "Mie Ayam"],                               │
│    "reasoning": [                                                        │
│      "Soto ayam cocok untuk cuaca hujan karena berkuah hangat...",     │
│      "Bakso juga berkuah dan sesuai budget Rp 25000...",               │
│      "Mie ayam alternatif gurih dengan tekstur berbeda..."             │
│    ],                                                                    │
│    "location_match": true                                               │
│  }                                                                       │
│                                                                          │
│  Return Value:                                                           │
│  {                                                                       │
│    'success': true,                                                      │
│    'data': {parsed JSON},                                               │
│    'location_data': {coordinates, radius, places},                      │
│    'fromCache': false                                                    │
│  }                                                                       │
│                                                                          │
│  Cache Update:                                                           │
│  • Save to _cache[cacheKey] with timestamp                              │
│  • Valid for 30 minutes                                                  │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Returns Map<String, dynamic>
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    6. REASONING PAGE (Response Handler)                  │
│                       lib/pages/reasoning_page.dart                      │
├─────────────────────────────────────────────────────────────────────────┤
│  FutureBuilder State Management:                                         │
│  • ConnectionState.waiting → Show loading UI                            │
│  • snapshot.hasError → _buildErrorState()                               │
│  • snapshot.hasData:                                                     │
│    - Check data['success'] == true                                      │
│    - Extract: foodData = data['data']                                   │
│    - Extract: locationInfo = data['location_data']                      │
│                                                                          │
│  Navigation:                                                             │
│  • WidgetsBinding.instance.addPostFrameCallback()                       │
│  • Navigator.pushReplacement() to ResultPage                            │
│  • Pass: foodData + locationInfo                                        │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Navigate to /result
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     7. RESULT PAGE (Display Layer)                       │
│                      lib/pages/result_page.dart                          │
├─────────────────────────────────────────────────────────────────────────┤
│  Data Initialization:                                                    │
│  • mainFood = widget.foodData['main_food']                              │
│  • alternatives = widget.foodData['alternatives'] as List               │
│  • reasoning = widget.foodData['reasoning'] as List                     │
│  • locationMatch = widget.foodData['location_match'] as bool            │
│  • locationInfo = widget.locationInfo                                   │
│                                                                          │
│  UI Components:                                                          │
│  ┌──────────────────────────────────────────────────┐                   │
│  │ Main Food Card:                                  │                   │
│  │ • Food emoji + name                              │                   │
│  │ • Favorite button (Heart icon)                   │                   │
│  │ • "Cari di Maps" button → url_launcher           │                   │
│  │   Opens: https://www.google.com/maps/search/    │                   │
│  │           ?api=1&query={mainFood}+{locationName} │                   │
│  └──────────────────────────────────────────────────┘                   │
│                                                                          │
│  ┌──────────────────────────────────────────────────┐                   │
│  │ Reasoning Cards (Loop through reasoning[]):     │                   │
│  │ • Icon + reasoning text                          │                   │
│  │ • Background: primaryOrange.withOpacity(0.1)     │                   │
│  └──────────────────────────────────────────────────┘                   │
│                                                                          │
│  ┌──────────────────────────────────────────────────┐                   │
│  │ Alternatives Section:                            │                   │
│  │ • GridView.builder for each alternative          │                   │
│  │ • Each card has Maps button + Favorite button    │                   │
│  └──────────────────────────────────────────────────┘                   │
│                                                                          │
│  ┌──────────────────────────────────────────────────┐                   │
│  │ Location Info (if available):                    │                   │
│  │ • Coordinates display                            │                   │
│  │ • Radius information                             │                   │
│  │ • Places found count                             │                   │
│  └──────────────────────────────────────────────────┘                   │
│                                                                          │
│  Persistent Storage:                                                     │
│  • _saveToHistory() → Hive.box<FoodHistory>                             │
│  • Stores: mainFood, alternatives, reasoning, timestamp                 │
│  • Used for analytics and frequent food detection                       │
│                                                                          │
│  User Actions:                                                           │
│  • "Refresh" button → _refreshRecommendation()                          │
│    Calls OpenAIService again with useCache=false                        │
│  • "Cari di Maps" → _launchMaps(foodName)                               │
│    Uses url_launcher package                                            │
│  • Heart icon → _toggleFavorite()                                       │
│    Saves/removes from Hive favorites                                    │
│  • Back button → Returns to /main (MainScaffold)                        │
└─────────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════
                            KEY DATA STRUCTURES                             
═══════════════════════════════════════════════════════════════════════════

Input Arguments (Navigator):
Map<String, dynamic> {
  'taste': 'Asin, Pedas',
  'style': 'Berkuah, Pakai Nasi',
  'weather': 'Hujan',
  'position': Position(latitude: -6.9175, longitude: 107.6191),
  'locationName': 'Bandung, Jawa Barat',
  'maxDistance': 10.0,
  'allergies': 'kacang, susu',
  'likes': 'ayam, seafood',
  'budget': '25000'
}

API Response Format:
Map<String, dynamic> {
  'success': true,
  'data': {
    'main_food': 'Soto Ayam',
    'alternatives': ['Bakso', 'Mie Ayam'],
    'reasoning': [
      'Soto ayam cocok karena...',
      'Bakso alternatif...',
      'Mie ayam pilihan...'
    ],
    'location_match': true
  },
  'location_data': {
    'coordinates': '-6.9175, 107.6191',
    'radius': '5 km',
    'source': 'Foursquare Places API',
    'total_found': 15,
    'places': ['Warung Soto Pak Sastro', 'Bakso Malang', ...]
  },
  'fromCache': false
}

═══════════════════════════════════════════════════════════════════════════
                          ERROR HANDLING FLOW                               
═══════════════════════════════════════════════════════════════════════════

Rate Limit Error:
• Detected in OpenAIService._rateLimiter.canMakeRequest()
• Returns: {'success': false, 'rateLimited': true, 'waitTime': 45}
• UI shows: "Rate limit exceeded. Please wait 45s..."

API Error (429/500):
• Caught in HTTP response status check
• Returns: {'success': false, 'error': 'API rate limit exceeded'}
• UI shows: _buildErrorState() with error message

Network Error:
• Caught in try-catch with .timeout(30 seconds)
• Returns: {'success': false, 'error': 'TimeoutException: ...'}
• UI shows: Error state with retry option

JSON Parse Error:
• Caught during jsonDecode(cleanedText)
• Returns: {'success': false, 'error': 'FormatException: ...'}
• UI shows: Error state with "Invalid response format"

Location Permission Denied:
• Handled in InputPage._getCurrentLocation()
• Sets: _useLocation = false, _locationMessage = 'Izin lokasi ditolak'
• Continues without location data (nearbyFoods = [])

═══════════════════════════════════════════════════════════════════════════
                        PERFORMANCE OPTIMIZATIONS                           
═══════════════════════════════════════════════════════════════════════════

1. Caching System:
   • In-memory Map cache with 30-minute expiry
   • Reduces API calls for duplicate requests
   • Cache key generated from all parameters

2. Rate Limiting:
   • Queue-based rate limiter (3 requests/minute)
   • Prevents exceeding free tier limits
   • Shows wait time to user

3. Lazy Loading:
   • Foursquare API only called when position != null
   • Historical data fetched asynchronously
   • UI renders while data loads

4. Timeout Protection:
   • 30-second timeout on all HTTP requests
   • Prevents hanging on slow connections
   • Shows error state immediately

5. Local Storage:
   • Hive used for offline history
   • Instant load on app restart
   • No network required for history view

---

## Slide 11: Screenshots - Landing & Auth
### User Interface

**Landing Page:**
- Modern gradient design
- Clear call-to-action
- Skip option for quick access

**Login/Register:**
- Toggle between modes
- Email/Password authentication
- Google Sign-In integration
- Gen Z Indonesian copywriting

---

## Slide 12: Screenshots - Main Features
### User Interface (Cont.)

**Input Page:**
- Interactive filters (Taste, Style)
- Budget slider
- Allergies selection
- Weather-based suggestions

**Result Page:**
- AI-generated recommendation
- Restaurant details
- Price estimation
- Google Maps integration

---

## Slide 13: Screenshots - Community
### User Interface (Cont.)

**Community Feed:**
- Real-time posts
- Like & comment system
- User interactions
- Post creation form

**Profile Page:**
- User information
- Budget management
- Allergies & health conditions
- Food preferences

---

## Slide 14: Security Features
### Keamanan Aplikasi

**Authentication:**
- Secure password hashing
- OAuth 2.0 (Google)
- Session management
- Auto logout

**Database Security:**
- Row Level Security (RLS)
- User data isolation
- Secure API keys (Environment Variables)
- HTTPS only

**Data Privacy:**
- User-specific data access
- No cross-user data leakage
- Encrypted connections

---

## Slide 15: Development Highlights
### Technical Achievements

**Performance:**
- Fast AI response (<3s)
- Real-time community updates
- Offline cache with Hive
- Optimized for mobile

**Code Quality:**
- Clean architecture
- Service layer separation
- Reusable widgets
- Proper error handling

**Developer Experience:**
- VS Code launch configurations
- Environment variables
- Git version control
- Comprehensive documentation

---

## Slide 16: Future Enhancements
### Roadmap

**Phase 1 (Current):**
✅ AI recommendations
✅ Community platform
✅ Profile management

**Phase 2 (Q1 2026):**
- 🔄 Meal planning calendar
- 🔄 Nutrition tracking
- 🔄 Restaurant ratings
- 🔄 Social media sharing

**Phase 3 (Q2 2026):**
- 🔄 Premium features
- 🔄 Advanced AI personalization
- 🔄 Multi-language support
- 🔄 iOS app store release

---

## Slide 17: Business Model
### Monetization Strategy

**Free Tier:**
- Basic AI recommendations
- 3 searches per day
- Community access
- Standard support

**Premium ($4.99/month):**
- Unlimited AI searches
- Advanced preferences
- Priority support
- Ad-free experience
- Exclusive community features

**Revenue Streams:**
- Subscription
- Restaurant partnerships
- Sponsored recommendations
- Premium features

---

## Slide 18: Target Market
### Target Audience

**Primary:**
- 🎯 Gen Z & Millennials (18-35 years)
- 📱 Mobile-first users
- 🍔 Food enthusiasts
- 💰 Budget-conscious individuals

**Secondary:**
- 👥 Health-conscious people
- 🏥 People with dietary restrictions
- 🌍 Travelers & tourists
- 👨‍👩‍👧‍👦 Families

**Market Size:**
- Indonesia: 270M population
- Smartphone users: 190M+
- Food delivery market: Growing 25%/year

---

## Slide 19: Competitive Advantage
### What Makes Us Different?

**vs Traditional Food Apps:**
- ✅ AI-powered personalization
- ✅ Health-aware recommendations
- ✅ Weather-based suggestions

**vs Food Delivery Apps:**
- ✅ Focus on discovery, not just delivery
- ✅ Community engagement
- ✅ Budget optimization

**vs Social Food Apps:**
- ✅ Smart AI recommendations
- ✅ Real-time updates
- ✅ Privacy-focused

**Our USP:**
"AI yang beneran ngerti kamu, bukan cuma random suggestion!"

---

## Slide 20: Demo
### Live Demonstration

**Demo Flow:**
1. Open app → Landing page
2. Skip to main app (Guest mode)
3. Input preferences (Pedas, Street Food, Rp 50,000)
4. Show AI reasoning process
5. Display recommendation with map
6. Browse community feed
7. Create a post (Login required)
8. Show profile management

**Backup:** Video demo if live fails

---

## Slide 21: Technical Challenges & Solutions
### Problems Solved

**Challenge 1: Real-time Community**
- Solution: Supabase real-time subscriptions
- StreamBuilder for live updates

**Challenge 2: Offline Support**
- Solution: Hive local cache
- Sync when online

**Challenge 3: AI Response Time**
- Solution: Loading states
- Streaming responses
- User feedback

**Challenge 4: Cross-platform**
- Solution: Flutter framework
- Responsive design
- Platform-specific configs

---

## Slide 22: Metrics & KPIs
### Success Indicators

**Technical Metrics:**
- ⚡ App load time: <2s
- 🤖 AI response: <3s
- 📊 Real-time latency: <500ms
- 💾 App size: <50MB

**User Metrics (Target):**
- 👥 1,000 users in 3 months
- 📱 70% retention rate
- ⭐ 4.5+ rating
- 🔄 5+ searches per user/week

**Business Metrics:**
- 💰 10% conversion to premium
- 📈 25% MoM growth
- 🤝 50+ restaurant partnerships

---

## Slide 23: Team & Contributions
### Development Team

**[Your Name]** - Full Stack Developer
- Flutter frontend development
- Supabase backend integration
- AI implementation
- UI/UX design

**Technologies Mastered:**
- Flutter/Dart
- Supabase/PostgreSQL
- OpenAI API integration
- Google Cloud Services
- Git version control

**Development Time:**
- Planning & Design: 1 week
- Development: 4 weeks
- Testing & Refinement: 1 week
- Total: 6 weeks

---

## Slide 24: Resources & Links
### Project Information

**GitHub Repository:**
- https://github.com/kendikadimas/foodmind

**Documentation:**
- SUPABASE_SETUP.md
- README.md
- API documentation

**Technologies:**
- Flutter: flutter.dev
- Supabase: supabase.com
- OpenAI: openai.com

**Package Name:**
- com.foodmind

**Version:**
- 1.0.0+1

---

## Slide 25: Q&A
### Questions?

**Contact:**
- GitHub: @kendikadimas
- Email: [your-email]
- Repository: github.com/kendikadimas/foodmind

**Thank You!**

"Laper Nih, Makan Apa Ya? 
FoodMind tau jawabannya! 🍽️🧠"

---

## Appendix: Code Highlights
### Key Code Snippets

**AI Service Integration:**
```dart
class OpenAIService {
  Future<Map<String, dynamic>> getFoodRecommendation({
    required String taste,
    required String style,
    required String budget,
    String? allergies,
  }) async {
    // OpenAI API call
  }
}
```

**Supabase Real-time:**
```dart
Stream<List<Map<String, dynamic>>> streamAllPosts() {
  return _supabase.client
    .from('posts')
    .stream(primaryKey: ['id'])
    .order('created_at');
}
```

---

## Notes for Presenter:

**Timing:**
- Total: 20-25 minutes
- Introduction: 2 min
- Problem & Solution: 3 min
- Features & Demo: 10 min
- Technical Details: 5 min
- Business & Future: 3 min
- Q&A: 5 min

**Tips:**
- Use demo video as backup
- Prepare test account
- Show real AI responses
- Emphasize Gen Z appeal
- Highlight technical skills

**Key Messages:**
1. AI-powered personalization
2. Health & budget aware
3. Real-time community
4. Cross-platform & scalable
5. Modern tech stack
