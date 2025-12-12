# Home Feature Refactoring - MVVM with Riverpod Generator

## 🎯 Summary

Successfully refactored the **Home feature** from a mixed UI/logic approach to a clean **MVVM (Model-View-ViewModel)** architecture using **Riverpod Generator** (`@riverpod`).

## ✅ What Was Done

### 1. **Created Feature Structure**
```
lib/features/home/
├── models/
│   └── home_state.dart              # Immutable state model
├── view_models/
│   ├── home_view_model.dart         # ViewModel with @riverpod
│   └── home_view_model.g.dart       # Generated code
└── README.md                        # Feature documentation
```

### 2. **Model Layer** (`home_state.dart`)
Created immutable state class with:
- `greeting`: Time-based greeting text
- `greetingEmoji`: Contextual emoji
- `motivationalText`: Dynamic motivational message
- `currentTime`: Current timestamp
- `copyWith()`: For immutable updates

### 3. **ViewModel Layer** (`home_view_model.dart`)
Created `HomeViewModel` using `@riverpod` annotation:
- **Business Logic**: 4 time periods (morning, afternoon, evening, night)
- **State Calculation**: `_calculateGreetingState()` determines greeting based on hour
- **Public Methods**:
  - `refreshGreeting()`: Recalculate greeting state
  - `getGreetingText()`: Get formatted greeting text
  - `getRecommendationType()`: Get meal type based on time

**Time Logic**:
- 🌅 04:00-11:59 → "Selamat Pagi"
- ☀️ 12:00-14:59 → "Selamat Siang"
- 🌤️ 15:00-17:59 → "Selamat Sore"
- 🌙 18:00-03:59 → "Selamat Malam"

### 4. **View Layer** (`home_page.dart`)
Refactored from business logic in build() to pure presentation:

**Before**:
```dart
final hour = DateTime.now().hour;
String greeting = 'Selamat Pagi';
if (hour >= 12 && hour < 15) {
  greeting = 'Selamat Siang';
} else if (hour >= 15 && hour < 18) {
  greeting = 'Selamat Sore';
} else if (hour >= 18 || hour < 4) {
  greeting = 'Selamat Malam';
}
```

**After**:
```dart
final homeState = ref.watch(homeViewModelProvider);
// Use homeState.greeting, homeState.greetingEmoji, homeState.motivationalText
```

## 🏗️ Architecture Benefits

| Aspect | Before | After |
|--------|--------|-------|
| **Separation** | Logic in UI | Logic in ViewModel |
| **Testability** | Hard to test UI logic | ViewModel easily testable |
| **Reusability** | Logic tied to widget | ViewModel reusable |
| **Type Safety** | Manual state management | Riverpod Generator types |
| **Reactivity** | Manual state updates | Automatic with Riverpod |

## 🔄 Data Flow

```
┌─────────────┐
│   HomePage  │ (View - Dumb Widget)
│ (Consumer)  │
└──────┬──────┘
       │ ref.watch()
       ↓
┌──────────────────────┐
│ homeViewModelProvider │ (Provider)
└──────────┬───────────┘
           │
           ↓
┌────────────────────┐
│  HomeViewModel     │ (ViewModel - Business Logic)
│  (@riverpod class) │
└─────────┬──────────┘
          │ returns
          ↓
┌──────────────┐
│  HomeState   │ (Model - Immutable State)
└──────────────┘
```

## 📦 Generated Files

Running `flutter pub run build_runner build --delete-conflicting-outputs` generated:
- `home_view_model.g.dart`: Contains `homeViewModelProvider` and `_$HomeViewModel` base class

## 🧪 Testing Strategy

```dart
// Unit test example
test('ViewModel returns correct greeting for morning', () {
  final container = ProviderContainer();
  
  // Mock time to 9 AM
  final viewModel = container.read(homeViewModelProvider);
  
  expect(viewModel.greeting, 'Selamat Pagi');
  expect(viewModel.greetingEmoji, '🌅');
});
```

## 📋 Checklist

- [x] Created `lib/features/home/` structure
- [x] Created `HomeState` model (immutable)
- [x] Created `HomeViewModel` with `@riverpod`
- [x] Extracted business logic from UI to ViewModel
- [x] Refactored `HomePage` to watch provider
- [x] Generated Riverpod code with build_runner
- [x] Verified no compile errors
- [x] Created feature documentation (README.md)
- [x] Created refactoring summary

## 🚀 Next Steps

To apply this pattern to other features:

1. **Community Feature**: Extract post filtering/sorting logic
2. **Profile Feature**: Extract form validation and save logic
3. **Input Feature**: Extract location and preference logic
4. **Result Feature**: Extract recommendation refresh logic

## 📚 References

- [Riverpod Documentation](https://riverpod.dev/)
- [Riverpod Generator](https://riverpod.dev/docs/concepts/about_code_generation)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)

---

**Migration Complete!** ✨ The Home feature now follows clean MVVM architecture with Riverpod Generator.
