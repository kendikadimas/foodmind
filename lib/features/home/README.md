# Home Feature - MVVM Architecture

## 📁 Structure

```
lib/features/home/
├── models/
│   └── home_state.dart          # Immutable state model
├── view_models/
│   ├── home_view_model.dart     # ViewModel with business logic
│   └── home_view_model.g.dart   # Generated Riverpod code
└── views/
    └── (home_page.dart is in lib/pages/ for now)
```

## 🏗️ Architecture Pattern: MVVM with Riverpod

### Model (`home_state.dart`)
- **Purpose**: Represents the UI state
- **Type**: Immutable data class
- **Fields**:
  - `greeting`: Time-based greeting (e.g., "Selamat Pagi")
  - `greetingEmoji`: Emoji matching the time (e.g., 🌅)
  - `motivationalText`: Contextual motivational message
  - `currentTime`: Current DateTime for reference

### ViewModel (`home_view_model.dart`)
- **Purpose**: Contains business logic and exposes state to UI
- **Type**: Riverpod Notifier (using `@riverpod` generator)
- **Responsibilities**:
  - Calculate greeting based on time of day (4 time periods)
  - Provide motivational text based on context
  - Expose methods for state refresh
  - Determine recommendation type (sarapan, makan_siang, etc.)

**Time Periods**:
- 🌅 **Pagi** (04:00 - 11:59): Morning greeting
- ☀️ **Siang** (12:00 - 14:59): Afternoon greeting
- 🌤️ **Sore** (15:00 - 17:59): Evening greeting
- 🌙 **Malam** (18:00 - 03:59): Night greeting

### View (`home_page.dart`)
- **Purpose**: Dumb widget that renders UI based on state
- **Type**: ConsumerWidget
- **Responsibilities**:
  - Watch `homeViewModelProvider` for state changes
  - Render UI components with data from state
  - No business logic (pure presentation)

## 🔄 Data Flow

```
User Opens App
     ↓
HomePage watches homeViewModelProvider
     ↓
HomeViewModel.build() called
     ↓
_calculateGreetingState() determines greeting based on time
     ↓
HomeState created with greeting, emoji, and motivational text
     ↓
HomePage rebuilds with new state
     ↓
UI displays greeting and motivational message
```

## 🎯 Benefits

1. **Separation of Concerns**: Business logic separated from UI
2. **Testability**: ViewModel can be tested independently
3. **Maintainability**: Changes to greeting logic don't affect UI code
4. **Type Safety**: Full type safety with Riverpod Generator
5. **Reactive**: UI automatically updates when state changes
6. **Immutability**: State is immutable, preventing unwanted mutations

## 🧪 Testing

```dart
// Example test for ViewModel
test('should return morning greeting between 4 AM and 12 PM', () {
  final container = ProviderContainer();
  final viewModel = container.read(homeViewModelProvider.notifier);
  
  // Mock time to 9 AM
  // Test that greeting == "Selamat Pagi"
  // Test that emoji == "🌅"
});
```

## 🚀 Usage

```dart
// In any widget
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state
    final state = ref.watch(homeViewModelProvider);
    
    // Access ViewModel methods
    final viewModel = ref.read(homeViewModelProvider.notifier);
    viewModel.refreshGreeting();
    
    // Use state in UI
    return Text(state.greeting);
  }
}
```

## 📝 Future Enhancements

- [ ] Add user preferences for custom greetings
- [ ] Integrate with user profile for personalized messages
- [ ] Add animation for greeting transitions
- [ ] Support different languages/locales
- [ ] Add special occasion greetings (holidays, birthdays)
