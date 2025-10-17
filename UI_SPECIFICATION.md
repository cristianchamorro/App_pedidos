# UI Specification - productos_por_categoria_page Enhanced

## Color Palette

### Primary Colors
- **Deep Purple**: `Colors.deepPurple` (RGB: 103, 58, 183)
- **Purple Accent**: `Colors.purpleAccent` (RGB: 224, 64, 251)
- **White**: `Colors.white` (RGB: 255, 255, 255)
- **Green Success**: `Colors.green.shade600` (RGB: 67, 160, 71)

### Secondary Colors
- **Red Badge**: `Colors.red` (RGB: 244, 67, 54)
- **Grey Background**: `Colors.grey.shade200` (RGB: 238, 238, 238)
- **Black Text**: `Colors.black87` (RGBA: 0, 0, 0, 0.87)

## Layout Structure

### AppBar (Top Bar)
```
┌────────────────────────────────────────────────────────┐
│ ← [Gradient Purple]  Lista de Productos    🛒(3) [+][💰][🍴] │
└────────────────────────────────────────────────────────┘
```
- **Height**: ~56px (default AppBar)
- **Background**: Linear gradient (deepPurple → purpleAccent)
- **Border Radius**: Bottom corners rounded (20px)
- **Elevation**: 6px shadow
- **Cart Badge**: Red circle with white number, positioned top-right of cart icon

### Search Bar
```
┌────────────────────────────────────────────────────────┐
│  🔍  Buscar productos...                          [×]  │
└────────────────────────────────────────────────────────┘
```
- **Height**: ~56px
- **Background**: Light purple tint (deepPurple with 0.05 opacity)
- **Border Radius**: 30px (fully rounded)
- **Border**: None
- **Icon Color**: Deep purple
- **Padding**: 12px all around

### Category Filters (Horizontal Scroll)
```
┌────────────────────────────────────────────────────────┐
│ [Todas (15)] [Comidas (8)] [Bebidas (5)] [Postres (2)] →│
└────────────────────────────────────────────────────────┘
```
- **Height**: 60px
- **Background**: White
- **Chip Spacing**: 8px horizontal padding between chips
- **Selected Chip**:
  - Background: Deep purple
  - Text: White, bold
  - Icon: White checkmark
- **Unselected Chip**:
  - Background: Grey.shade200
  - Text: Deep purple, bold
  - Border Radius: Default FilterChip
- **Elevation**: 2px shadow

### Address Card
```
┌────────────────────────────────────────────────────────┐
│ 📍  Entregar pedido en...                              │
│     [Editable text field]                              │
└────────────────────────────────────────────────────────┘
```
- **Background**: Light purple tint (deepPurple with 0.1 opacity)
- **Border Radius**: 12px
- **Padding**: 12px
- **Margin**: Bottom 12px

### Cart Summary (When cart has items)
```
┌────────────────────────────────────────────────────────┐
│ [Gradient Purple Background]                           │
│ 🛒  3 productos                      [Ver Carrito]     │
│     Total: $25.00                                      │
└────────────────────────────────────────────────────────┘
```
- **Background**: Linear gradient (deepPurple.shade400 → deepPurple.shade600)
- **Border Radius**: 12px
- **Padding**: 16px
- **Text Color**: White
- **Button**: White background, purple text, rounded (20px)
- **Shadow**: Purple glow (0.3 opacity, 8px blur, 4px offset)

### Category Section
```
┌────────────────────────────────────────────────────────┐
│ [📁] Comidas                                      [8] ▼│
├────────────────────────────────────────────────────────┤
│  Product Grid                                          │
└────────────────────────────────────────────────────────┘
```
- **Background**: Light purple tint (0.05 when expanded, 0.03 when collapsed)
- **Border Radius**: 16px
- **Elevation**: 4px shadow
- **Margin**: 6px vertical
- **Icon Background**: Light purple circle, 8px padding, rounded
- **Badge**: Purple background, white text, 12px border radius

### Product Card
```
┌──────────────────┐
│     [$10.00]     │ ← Price badge (top-right)
│                  │
│  Product Image   │ ← 1.2:1 aspect ratio
│                  │
├──────────────────┤
│  Product Name    │ ← Bold, purple, 15px, max 2 lines
│  Description...  │ ← Grey, 11px, max 1 line
│                  │
│   [-]  2  [+]    │ ← Quantity controls
│                  │
│  [🛒 Agregar]    │ ← Purple button
└──────────────────┘
```

#### Card Dimensions
- **Width**: Dynamic (220px max, responsive)
- **Aspect Ratio**: Card varies, but image is 1.2:1
- **Border Radius**: 16px
- **Shadow**: Purple tint, 0.25 opacity, 8px blur, 4px offset
- **Background**: White with subtle purple gradient at bottom

#### Price Badge
- **Position**: Top-right, 8px from edges
- **Background**: Green.shade600
- **Text**: White, bold, 12px
- **Padding**: 8px horizontal, 4px vertical
- **Border Radius**: 12px
- **Shadow**: Black, 0.2 opacity, 4px blur

#### Image Section
- **Height**: Calculated by 1.2:1 aspect ratio
- **Fit**: Cover (fills entire area)
- **Border Radius**: Top only (16px)
- **Overlay**: Subtle gradient (transparent → black 0.1 opacity)
- **Loading**: Grey background with CircularProgressIndicator
- **Error**: Grey background with icon + text

#### Content Section
- **Padding**: 8px all around
- **Name**: Bold, deepPurple, 15px, center aligned, max 2 lines with ellipsis
- **Description**: Grey.shade600, 11px, center aligned, max 1 line with ellipsis
- **Spacing**: 4px between name and description

#### Quantity Controls
- **Button Size**: 20px icons
- **Spacing**: Centered horizontally
- **Number**: 16px, center aligned

#### Add Button
- **Background**: Deep purple
- **Foreground**: White
- **Padding**: 8px vertical
- **Border Radius**: 12px
- **Elevation**: 4px
- **Icon**: 16px shopping cart
- **Text**: "Agregar", 13px

### Floating Action Button
```
┌──────────────────────────────┐
│  ✓  Confirmar Pedido         │
└──────────────────────────────┘
```
- **Background**: Deep purple
- **Text/Icon**: White
- **Shape**: Extended FAB (rounded pill)
- **Position**: Bottom-right corner

## Interactions & Animations

### Search Bar
- **On Focus**: Border highlight (optional)
- **On Type**: Instant filter (no delay)
- **Clear Button**: Appears when text.length > 0

### Category Chips
- **On Select**: 
  - Background changes to purple
  - Text changes to white
  - Checkmark appears
  - Selected category auto-expands
- **Animation**: 200ms ease

### Product Card
- **On Tap**: Shows detail dialog with larger image
- **On Add**: 
  - Shows green snackbar for 1 second
  - Updates cart badge
  - Shows/updates cart summary
- **Animation**: Container animation, 200ms ease

### Cart Badge
- **Appearance**: Fades in when first item added
- **Update**: Number changes with quick scale animation
- **On Tap**: Navigates to confirm order

### Cart Summary
- **Appearance**: Slides in from top when first item added
- **Update**: Text updates with smooth transition
- **Button Tap**: Navigates to confirm order

### SnackBar
- **Duration**: 1000ms (1 second)
- **Background**: Green.shade600
- **Content**: Icon (check_circle) + Text
- **Animation**: Slides up from bottom

## Responsive Behavior

### Grid Columns
- **Calculation**: `floor(screenWidth / 220).clamp(1, 6)`
- **Examples**:
  - 320px screen: 1 column
  - 640px screen: 2 columns
  - 880px screen: 4 columns
  - 1200px screen: 5 columns

### Category Chips
- **Scroll**: Horizontal scroll when chips exceed screen width
- **Padding**: 8px horizontal on container

### Search Bar
- **Width**: Full width minus 24px (12px padding each side)

## Typography

### AppBar Title
- **Font**: Default system font
- **Size**: 20px (default AppBar title)
- **Weight**: Bold
- **Letter Spacing**: 1.2px
- **Color**: White

### Category Title
- **Font**: Default system font
- **Size**: 20px
- **Weight**: Bold
- **Color**: Deep purple

### Product Name
- **Font**: Default system font
- **Size**: 15px
- **Weight**: Bold
- **Color**: Deep purple

### Product Description
- **Font**: Default system font
- **Size**: 11px
- **Weight**: Regular
- **Color**: Grey.shade600

### Price
- **Font**: Default system font
- **Size**: 12px (badge), 18px (cart summary)
- **Weight**: Bold
- **Color**: White (badge), White (cart summary)

### Cart Summary
- **Item Count**: 14px, medium weight
- **Total Price**: 18px, bold

## Accessibility

### Touch Targets
- All buttons: Minimum 48x48 dp
- IconButtons: Default 48x48 dp
- Category chips: Height 60px (includes padding)

### Contrast Ratios
- White on purple: >4.5:1 (AAA)
- Purple on white: >4.5:1 (AAA)
- Green on white: >3:1 (AA)

### Screen Reader Support
- All interactive elements have semantic labels
- Cart badge announces count
- Search field has hint text
- Category chips announce name and count

## Edge Cases & States

### Empty States
- **No Products**: Show message "No hay productos disponibles"
- **No Search Results**: Show "No se encontraron productos"
- **Empty Cart**: Hide cart badge and summary, show only FAB

### Loading States
- **Images Loading**: Grey background + CircularProgressIndicator
- **Images Error**: Grey background + broken_image icon + text

### Error States
- **Location Error**: SnackBar with error message
- **Empty Cart on Confirm**: SnackBar "No hay productos en el carrito"

This specification ensures a consistent, professional, and user-friendly interface.
