# Quick Start Guide - Using the App Theme

## Import the Theme

In any Dart file where you need colors:

```dart
import 'package:app_pedidos/theme/app_theme.dart';
```

## Common Usage Examples

### Colors

```dart
// Primary blue color
Container(color: AppTheme.primary)

// Light blue color
Container(color: AppTheme.primaryLight)

// Very light blue (backgrounds)
Container(color: AppTheme.primaryVeryLight)

// Orange (CTAs, food actions)
Container(color: AppTheme.secondary)

// Cyan (search, highlights)
Container(color: AppTheme.accent)

// With opacity
Container(color: AppTheme.primary.withOpacity(0.5))
```

### Gradients

```dart
// AppBar gradient
AppBar(
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: AppTheme.primaryGradient,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
  ),
)

// Background gradient
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.backgroundGradient,
  ),
)

// Button gradient
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.secondaryGradient,
    borderRadius: BorderRadius.circular(12),
  ),
)
```

### Buttons

Buttons automatically use theme colors, but you can customize:

```dart
// Primary button (blue)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primary,
    foregroundColor: Colors.white,
  ),
  onPressed: () {},
  child: Text("Primary Action"),
)

// Secondary button (orange)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.secondary,
    foregroundColor: Colors.white,
  ),
  onPressed: () {},
  child: Text("Food Action"),
)

// Outlined button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: AppTheme.primary,
    side: BorderSide(color: AppTheme.primary, width: 2),
  ),
  onPressed: () {},
  child: Text("Secondary"),
)
```

### Text Styles

```dart
// Headings
Text("Main Title", style: AppTheme.heading1)
Text("Section Title", style: AppTheme.heading2)
Text("Subsection", style: AppTheme.heading3)

// Body text
Text("Important text", style: AppTheme.subtitle1)
Text("Regular text", style: AppTheme.body1)
Text("Secondary text", style: AppTheme.body2)
Text("Caption", style: AppTheme.caption)
```

### Status Colors

```dart
// Success (green)
Icon(Icons.check_circle, color: AppTheme.success)

// Warning (orange)
Icon(Icons.warning, color: AppTheme.warning)

// Error (red)
Icon(Icons.error, color: AppTheme.error)

// Info (blue)
Icon(Icons.info, color: AppTheme.info)
```

### Shadows

```dart
// Card shadow
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: AppTheme.cardShadow,
    borderRadius: BorderRadius.circular(12),
  ),
)

// Elevated shadow
Container(
  decoration: BoxDecoration(
    color: AppTheme.primary,
    boxShadow: AppTheme.elevatedShadow,
    borderRadius: BorderRadius.circular(12),
  ),
)
```

### Complete AppBar Example

```dart
AppBar(
  title: const Text(
    "My Screen",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      letterSpacing: 1.1,
    ),
  ),
  centerTitle: true,
  elevation: 8,
  backgroundColor: Colors.transparent,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: AppTheme.primaryGradient,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
)
```

### Complete Card Example

```dart
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppTheme.primaryVeryLight,
          Colors.white,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      children: [
        Icon(Icons.restaurant_menu, 
          size: 48, 
          color: AppTheme.primary
        ),
        SizedBox(height: 12),
        Text("Content", style: AppTheme.heading3),
        Text("Details", style: AppTheme.body2),
      ],
    ),
  ),
)
```

## Don't Use ❌

```dart
// Don't use hardcoded colors
Colors.blue ❌
Colors.deepPurple ❌
Color(0xFF2196F3) ❌

// Use theme instead
AppTheme.primary ✅
```

## When to Use Each Color

### Blue (Primary)
- Main navigation
- Primary actions
- Branding elements
- Headers

### Orange (Secondary)
- Food-related actions
- "Add to cart" buttons
- Price displays
- Call-to-action

### Cyan (Accent)
- Search functionality
- Highlights
- Special features
- Interactive elements

### Green (Success)
- Order completed
- Payment successful
- Delivery confirmed

### Orange (Warning)
- Pending orders
- Time-sensitive items

### Red (Error)
- Failed operations
- Cancellations
- Alerts

## Color Meanings in Food Apps

| Color | Emotion | Use Case |
|-------|---------|----------|
| Blue | Trust, Professional | Navigation, Headers |
| Orange | Appetite, Warmth | CTAs, Food Actions |
| Cyan | Fresh, Modern | Search, Highlights |
| Green | Success, Fresh | Confirmations |
| Red | Urgent, Stop | Errors, Cancellations |

## Pro Tips

1. **Consistency**: Always use theme colors, never hardcode
2. **Contrast**: Ensure text is readable on colored backgrounds
3. **Hierarchy**: Use color intensity to show importance
4. **Appetite**: Use orange near food images
5. **Trust**: Use blue for payment and sensitive actions

## Quick Reference

| Property | Theme Value |
|----------|-------------|
| Primary color | `AppTheme.primary` |
| Light variant | `AppTheme.primaryLight` |
| Background | `AppTheme.primaryVeryLight` |
| Secondary | `AppTheme.secondary` |
| Accent | `AppTheme.accent` |
| Success | `AppTheme.success` |
| Error | `AppTheme.error` |
| Main gradient | `AppTheme.primaryGradient` |
| BG gradient | `AppTheme.backgroundGradient` |

## Need Help?

See full documentation in `THEME_DOCUMENTATION.md`
