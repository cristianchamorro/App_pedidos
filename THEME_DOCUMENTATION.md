# Theme Documentation - App Pedidos

## Overview

This document describes the application theme implementation for the food delivery application. The theme uses a light blue color scheme that is modern, clean, and suitable for food ordering applications.

## Theme Structure

### Location
The centralized theme is defined in:
```
app_frontend/lib/theme/app_theme.dart
```

### Color Palette

#### Primary Colors (Blue Theme)
- **Primary**: `#2196F3` (Blue 500) - Main brand color
- **Primary Light**: `#64B5F6` (Blue 300) - Lighter variant for gradients
- **Primary Dark**: `#1976D2` (Blue 700) - Darker variant for emphasis
- **Primary Very Light**: `#E3F2FD` (Blue 50) - Background tints

#### Secondary Colors (Orange/Food Theme)
- **Secondary**: `#FF9800` (Orange 500) - Call-to-action buttons
- **Secondary Light**: `#FFB74D` (Orange 300) - Lighter variant
- **Secondary Dark**: `#F57C00` (Orange 700) - Darker variant

#### Accent Colors
- **Accent**: `#00BCD4` (Cyan 500) - Search, highlights
- **Accent Light**: `#4DD0E1` (Cyan 300) - Lighter variant

#### Status Colors
- **Success**: `#4CAF50` (Green 500) - Success messages, completed states
- **Warning**: `#FF9800` (Orange 500) - Warning messages
- **Error**: `#F44336` (Red 500) - Error messages, alerts
- **Info**: `#2196F3` (Blue 500) - Informational messages

#### Neutral Colors
- **Background**: `#F5F5F5` (Grey 100) - App background
- **Surface**: White - Cards, dialogs
- **Surface Variant**: `#FAFAFA` (Grey 50) - Input fields

#### Text Colors
- **Text Primary**: `#212121` (Grey 900) - Main text
- **Text Secondary**: `#757575` (Grey 600) - Secondary text
- **Text Hint**: `#9E9E9E` (Grey 500) - Placeholder text
- **Text On Primary**: White - Text on colored backgrounds

## Usage

### Importing the Theme

In any Dart file where you need to use theme colors:

```dart
import 'package:app_pedidos/theme/app_theme.dart';
```

### Applying the Theme

The theme is applied globally in `main.dart`:

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  // ... other properties
)
```

### Using Theme Colors

#### Direct Color Access
```dart
// Use primary color
Container(
  color: AppTheme.primary,
)

// Use with opacity
Container(
  color: AppTheme.primary.withOpacity(0.3),
)
```

#### Predefined Gradients
```dart
// Primary gradient for AppBars
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient,
  ),
)

// Background gradient
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.backgroundGradient,
  ),
)

// Secondary gradient
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.secondaryGradient,
  ),
)
```

#### Text Styles
```dart
Text(
  "Main Heading",
  style: AppTheme.heading1,
)

Text(
  "Section Title",
  style: AppTheme.heading2,
)

Text(
  "Subsection Title",
  style: AppTheme.heading3,
)

Text(
  "Important text",
  style: AppTheme.subtitle1,
)

Text(
  "Regular text",
  style: AppTheme.body1,
)

Text(
  "Small caption",
  style: AppTheme.caption,
)
```

#### Shadow Effects
```dart
// Card shadow
Container(
  decoration: BoxDecoration(
    boxShadow: AppTheme.cardShadow,
  ),
)

// Elevated shadow (for buttons, important elements)
Container(
  decoration: BoxDecoration(
    boxShadow: AppTheme.elevatedShadow,
  ),
)
```

### Theme Components

The theme automatically styles the following Material components:

#### AppBar
- Transparent background with gradient via `flexibleSpace`
- Centered title
- White text and icons
- Rounded bottom corners

Example:
```dart
AppBar(
  title: const Text("Title"),
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: AppTheme.primaryGradient,
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(20),
      ),
    ),
  ),
)
```

#### Buttons
All buttons automatically use theme colors:

```dart
ElevatedButton(
  onPressed: () {},
  child: Text("Button"),
)

OutlinedButton(
  onPressed: () {},
  child: Text("Button"),
)

TextButton(
  onPressed: () {},
  child: Text("Button"),
)
```

#### Cards
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text("Card content"),
  ),
)
```

#### Input Fields
```dart
TextField(
  decoration: InputDecoration(
    labelText: "Label",
    hintText: "Hint",
    prefixIcon: Icon(Icons.search),
  ),
)
```

## Updated Pages

The following pages have been updated to use the new theme:

### Main Application
- ✅ `main.dart` - Theme applied globally

### Authentication Pages
- ✅ `login_choice_page.dart` - Welcome screen
- ✅ `login_admin_page.dart` - Admin login

### User Flow Pages
- ✅ `location_screen.dart` - Location capture
- ✅ `productos_por_categoria_page.dart` - Product catalog
- ✅ `confirmar_pedido_page.dart` - Order confirmation
- ✅ `pago_page.dart` - Payment screen

### Admin Pages
- ✅ `cajero_dashboard_page.dart` - Cashier dashboard
- ✅ `pedidos_cajero_page.dart` - Cashier orders
- ✅ `pedidos_cocinero_page.dart` - Kitchen orders
- ✅ `domiciliario_page.dart` - Delivery driver
- ✅ `detalle_pedido_page.dart` - Order details
- ✅ `agregar_producto_page.dart` - Add product

## Best Practices

1. **Always use theme colors** instead of hardcoded colors
   - ❌ Bad: `Colors.blue`
   - ✅ Good: `AppTheme.primary`

2. **Use predefined gradients** for consistency
   - ❌ Bad: `LinearGradient(colors: [Colors.blue, Colors.lightBlue])`
   - ✅ Good: `AppTheme.primaryGradient`

3. **Use semantic color names**
   - Use `AppTheme.success` for success states
   - Use `AppTheme.error` for error states
   - Use `AppTheme.warning` for warnings

4. **Leverage Material 3**
   - The theme uses Material 3 for modern design
   - Most components automatically adapt to theme colors

5. **Maintain consistency**
   - Always import the theme when using custom colors
   - Use theme text styles for typography consistency

## Theme Customization

To customize the theme:

1. Open `app_frontend/lib/theme/app_theme.dart`
2. Modify color constants at the top of the class
3. Changes will automatically apply throughout the app

### Example: Changing Primary Color

```dart
// Before
static const Color primary = Color(0xFF2196F3); // Blue

// After (to make it darker blue)
static const Color primary = Color(0xFF1565C0); // Dark Blue
```

## Design Rationale

### Why Blue?
- Blue is associated with trust and reliability
- Common in food delivery apps (Uber Eats uses blue)
- Creates calm, professional atmosphere
- Good contrast with food imagery

### Why Orange as Secondary?
- Orange stimulates appetite
- Creates visual warmth
- Complements blue (complementary colors)
- Perfect for call-to-action buttons

### Why Light Background?
- Easier on eyes for prolonged use
- Better for viewing food photos
- Modern, clean aesthetic
- Reduces battery consumption on OLED screens

## Testing

To test the theme implementation:

1. Run the application: `flutter run`
2. Navigate through all screens
3. Verify colors are consistent
4. Check that no hardcoded purple colors remain
5. Test on both light and dark mode devices

## Migration Checklist

- [x] Create centralized theme file
- [x] Update main.dart to use new theme
- [x] Replace all hardcoded purple colors
- [x] Add theme imports to all pages
- [x] Test for compilation errors
- [x] Document theme usage

## Support

For questions or issues related to the theme, please contact the development team or create an issue in the repository.

## Version History

- **v1.0.0** (Current) - Initial light blue theme implementation
  - Replaced purple theme with blue
  - Added comprehensive theming system
  - Updated all 13 pages to use centralized theme
