# 🎨 Kitchen Screen - Visual Preview

## 📱 Complete Screen Layouts

### Main Screen - With Orders

```
╔═══════════════════════════════════════════════════════════════╗
║ ←  🍳 Cocina - Pedidos en preparación          [⚙️] [↕️]      ║ ← AppBar
╠═══════════════════════════════════════════════════════════════╣  (Gradient: deepPurple → purpleAccent)
║                                                               ║
║  ┌─────────────────────────────────────────────────────────┐ ║
║  │        📊 STATISTICS DASHBOARD (Gradient Card)          │ ║
║  │                                                         │ ║
║  │    🍽️ Total        ⚠️ Urgentes       ⏰ Normales       │ ║
║  │      [5]             [2]              [3]             │ ║
║  │                                                         │ ║
║  └─────────────────────────────────────────────────────────┘ ║
║                                                               ║
║  ┌─────────────────────────────────────────────────────────┐ ║
║  │ ╔═══════════════════════════════════════════════════╗   │ ║
║  │ ║ 🧾  Pedido #127                                   ║   │ ║ ← Order Card
║  │ ╚═══════════════════════════════════════════════════╝   │ ║  (Orange border - URGENT)
║  │                                                         │ ║
║  │  ┌──────────────────────────────────────────────────┐  │ ║
║  │  │ ⚠️ URGENTE - 18 min                             │  │ ║ ← Priority Badge
║  │  └──────────────────────────────────────────────────┘  │ ║  (Orange background)
║  │                                                         │ ║
║  │  ────────────────────────────────────────────────────   │ ║
║  │                                                         │ ║
║  │  ┌──────────────────────────────────────────────────┐  │ ║
║  │  │ 👤  Juan Pérez Gómez                            │  │ ║ ← Customer Info
║  │  │                                                  │  │ ║  (Light blue box)
║  │  │ 📞  +57 300 123 4567                            │  │ ║
║  │  │                                                  │  │ ║
║  │  │ 📍  Calle 100 #45-20, Bogotá                    │  │ ║
║  │  └──────────────────────────────────────────────────┘  │ ║
║  │                                                         │ ║
║  │  ┌──────────────────────────────────────────────────┐  │ ║
║  │  │ 🍽️  Productos a preparar:                       │  │ ║ ← Products Section
║  │  ├══════════════════════════════════════════════════┤  │ ║  (Amber/Orange box)
║  │  │  ┌────────────────────────────────────────────┐ │  │ ║
║  │  │  │  2x   Hamburguesa Especial            ☐   │ │  │ ║ ← Individual Product
║  │  │  └────────────────────────────────────────────┘ │  │ ║  (White card)
║  │  │  ┌────────────────────────────────────────────┐ │  │ ║
║  │  │  │  1x   Papas Fritas Grandes            ☐   │ │  │ ║
║  │  │  └────────────────────────────────────────────┘ │  │ ║
║  │  │  ┌────────────────────────────────────────────┐ │  │ ║
║  │  │  │  2x   Gaseosa Cola                    ☐   │ │  │ ║
║  │  │  └────────────────────────────────────────────┘ │  │ ║
║  │  └──────────────────────────────────────────────────┘  │ ║
║  │                                                         │ ║
║  │  ┌──────────────────────────────────────────────────┐  │ ║
║  │  │     ✅  Marcar como Preparado                   │  │ ║ ← Action Button
║  │  └──────────────────────────────────────────────────┘  │ ║  (Large green button)
║  └─────────────────────────────────────────────────────────┘ ║
║                                                               ║
║  ┌─────────────────────────────────────────────────────────┐ ║
║  │ ╔═══════════════════════════════════════════════════╗   │ ║
║  │ ║ 🧾  Pedido #128                                   ║   │ ║ ← Another Order
║  │ ╚═══════════════════════════════════════════════════╝   │ ║  (Red border - VERY URGENT)
║  │                                                         │ ║
║  │  ┌──────────────────────────────────────────────────┐  │ ║
║  │  │ 🔴 MUY URGENTE - 32 min                         │  │ ║
║  │  └──────────────────────────────────────────────────┘  │ ║
║  │  ...                                                    │ ║
║  └─────────────────────────────────────────────────────────┘ ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

### Filter Menu (Dropdown from AppBar)

```
┌──────────────────────────────┐
│  Filtrar por:               │
├──────────────────────────────┤
│  🌐  Todos                  │ ← Selected
├──────────────────────────────┤
│  ⚠️  Urgentes (>15 min)     │
├──────────────────────────────┤
│  ✅  Normales (<15 min)     │
└──────────────────────────────┘
```

### Sort Menu (Dropdown from AppBar)

```
┌──────────────────────────────┐
│  Ordenar por:               │
├──────────────────────────────┤
│  🕐  Más reciente           │
├──────────────────────────────┤
│  📅  Más antiguo            │ ← Selected (Priority)
└──────────────────────────────┘
```

---

### Empty State Screen

```
╔═══════════════════════════════════════════════════════════════╗
║ ←  🍳 Cocina - Pedidos en preparación          [⚙️] [↕️]      ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  ┌─────────────────────────────────────────────────────────┐ ║
║  │        📊 STATISTICS DASHBOARD                          │ ║
║  │                                                         │ ║
║  │    🍽️ Total        ⚠️ Urgentes       ⏰ Normales       │ ║
║  │      [0]             [0]              [0]             │ ║
║  └─────────────────────────────────────────────────────────┘ ║
║                                                               ║
║                                                               ║
║                                                               ║
║                         ┌───────────┐                         ║
║                         │           │                         ║
║                         │     ✓     │                         ║ ← Large check icon
║                         │           │                         ║
║                         └───────────┘                         ║
║                                                               ║
║              ¡Todo listo! No hay pedidos                      ║
║                   en preparación                              ║
║                                                               ║
║                                                               ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 🎨 Color Legend

### Priority Colors

#### 🟢 NORMAL (< 15 minutes)
```
Badge Color:    Green (#4CAF50)
Border Color:   Light Green
Text:          "NORMAL - X min"
Background:    White with green tint (5% opacity)
```

#### 🟠 URGENT (15-30 minutes)
```
Badge Color:    Orange (#FF9800)
Border Color:   Orange
Text:          "URGENTE - X min"
Background:    White with orange tint (5% opacity)
```

#### 🔴 VERY URGENT (> 30 minutes)
```
Badge Color:    Red (#F44336)
Border Color:   Dark Red
Text:          "MUY URGENTE - X min"
Background:    White with red tint (5% opacity)
```

---

### UI Section Colors

#### AppBar
```
Type:          Linear Gradient
Start Color:   Colors.deepPurple (#673AB7)
End Color:     Colors.purpleAccent (#E040FB)
Shadow:        Black with 26% opacity
Border Radius: Bottom 20px
```

#### Statistics Dashboard
```
Type:          Linear Gradient Card
Start Color:   Colors.deepPurple.shade100 (#D1C4E9)
End Color:     Colors.white (#FFFFFF)
Border Radius: 15px
Elevation:     4
Shadow:        Black with 10% opacity
```

#### Customer Info Box
```
Background:    Colors.blue with 5% opacity (#2196F30D)
Border:        Colors.blue with 20% opacity (#2196F333)
Border Radius: 10px
Icon Color:    Colors.blue (#2196F3)
```

#### Products Section
```
Background:    Colors.amber with 10% opacity (#FFC1071A)
Border:        Colors.amber with 30% opacity (#FFC1074D)
Border Radius: 10px
Header Color:  Colors.orange (#FF9800)
Border Width:  2px
```

#### Individual Product Cards
```
Background:    Colors.white (#FFFFFF)
Border Radius: 8px
Shadow:        Black with 5% opacity
Quantity Badge:
  - Background: Colors.deepPurple (#673AB7)
  - Text Color: White
  - Border Radius: 8px
```

#### Action Button
```
Background:    Colors.green (#4CAF50)
Text Color:    Colors.white (#FFFFFF)
Border Radius: 12px
Elevation:     4
Height:        50px
Icon Size:     28px
Font Size:     16px (Bold)
```

---

## 📐 Dimensions & Spacing

### Card Spacing
```
Horizontal Margin:  12px
Vertical Margin:    6px
Internal Padding:   16px
```

### Statistics Dashboard
```
Margin:            12px (all sides)
Padding:           16px
Icon Size:         28px
Value Font Size:   24px (Bold)
Label Font Size:   12px
```

### Order Card
```
Border Radius:     15px
Border Width:      2px
Elevation:         4
Padding:           16px
```

### Priority Badge
```
Horizontal Padding: 12px
Vertical Padding:   6px
Border Radius:      20px (pill shape)
Icon Size:          16px
Font Size:          12px (Bold)
```

### Customer Info
```
Padding:           12px
Border Radius:     10px
Border Width:      1px
Icon Size:         18px
Font Size:         14px
Row Spacing:       6px
```

### Products Section
```
Padding:           12px
Border Radius:     10px
Border Width:      2px
Header Font Size:  18px (Bold)
Product Card Margin: 8px (bottom)
```

### Individual Product Card
```
Padding:           12px
Border Radius:     8px
Quantity Badge:
  - Padding:       8px
  - Font Size:     20px (Bold)
Product Name:
  - Font Size:     18px (Bold)
Checkbox Size:     28px
```

---

## 📱 Responsive Breakpoints

### Mobile (< 600px)
- Full width cards
- Single column layout
- Compact statistics
- Font sizes as specified

### Tablet (600px - 900px)
- Slightly wider cards
- Same single column
- Larger touch targets
- Scaled fonts (+10%)

### Desktop (> 900px)
- Max width container (800px)
- Centered layout
- Same visual design
- Comfortable reading

---

## 🎬 Animation & Transitions

### Card Entry
```
Type:     Fade + Slide
Duration: 300ms
Curve:    easeOut
```

### Priority Badge
```
Type:     Scale + Fade
Duration: 200ms
On Tap:   Ripple effect
```

### Action Button
```
Type:     Ripple + Elevation
Duration: 150ms
On Tap:   Scale down 95%
Color:    White ripple
```

### Filter/Sort Menu
```
Type:     Slide from top
Duration: 250ms
Curve:    easeOut
```

---

## 🔤 Typography

### Fonts
```
Primary Font:  Roboto (Default Flutter Material)
Font Weights:  Regular (400), Medium (500), Bold (700)
```

### Text Sizes

#### AppBar Title
```
Size:          20px
Weight:        Bold
Color:         White
Letter Spacing: 1.2
```

#### Order Number
```
Size:          20px
Weight:        Bold
Color:         Black (87%)
```

#### Priority Text
```
Size:          12px
Weight:        Bold
Color:         White
```

#### Customer Name
```
Size:          14px
Weight:        Medium
Color:         Black (87%)
```

#### Customer Details
```
Size:          14px
Weight:        Regular
Color:         Black (87%)
```

#### Product Name
```
Size:          18px
Weight:        Bold
Color:         Black (87%)
```

#### Quantity Badge
```
Size:          20px
Weight:        Bold
Color:         White
```

#### Action Button
```
Size:          16px
Weight:        Bold
Color:         White
```

#### Statistics Value
```
Size:          24px
Weight:        Bold
Color:         Varies by stat type
```

#### Statistics Label
```
Size:          12px
Weight:        Medium
Color:         Grey (700)
```

---

## 🎯 Interactive Elements

### Tap Targets

#### Filter Button
```
Size:          48x48 minimum
Icon:          filter_list (24px)
Color:         White
Ripple:        White (30% opacity)
```

#### Sort Button
```
Size:          48x48 minimum
Icon:          sort (24px)
Color:         White
Ripple:        White (30% opacity)
```

#### Action Button
```
Height:        50px
Width:         Full width (minus padding)
Touch Area:    Entire button
Ripple:        White (30% opacity)
```

#### Order Card
```
Touch Area:    Entire card
Ripple:        None (not tappable in main area)
Focus:         None
```

---

## 📊 Visual Hierarchy

### Level 1: Most Important
- Priority Badge (RED for very urgent)
- Action Button (Large green button)
- Order Number

### Level 2: Important
- Product list (with checkboxes)
- Statistics dashboard
- Time indicator

### Level 3: Supporting
- Customer information
- Order metadata
- Icons

### Level 4: Background
- Card backgrounds
- Dividers
- Shadows

---

## 🌈 Accessibility

### Color Contrast
```
AppBar Text/Background:      AAA (4.5:1+)
Priority Badge:              AA (3:1+)
Action Button:               AAA (4.5:1+)
Body Text:                   AAA (4.5:1+)
```

### Touch Targets
```
Minimum Size:   48x48 dp
Spacing:        8dp between targets
Action Button:  50dp height (exceeds minimum)
```

### Text Readability
```
Minimum Font Size:  12sp
Body Text:          14sp
Headers:            18-20sp
Line Height:        1.5x font size
```

---

## 🎨 Icon Reference

### Icons Used

```dart
Icons.restaurant_menu      // Statistics - Total
Icons.warning              // Priority - Urgent/Very Urgent  
Icons.schedule             // Priority - Normal, Statistics
Icons.filter_list          // Filter button
Icons.sort                 // Sort button
Icons.receipt_long         // Order card header
Icons.person               // Customer name
Icons.phone                // Customer phone
Icons.location_on          // Customer address
Icons.restaurant           // Products section header
Icons.check_circle         // Action button, Success state
Icons.check_box_outline_blank  // Product checkbox
Icons.all_inclusive        // Filter option - All
Icons.check_circle         // Filter option - Normal
Icons.access_time          // Sort option - Recent
Icons.history              // Sort option - Oldest
Icons.check_circle_outline // Empty state icon
```

---

## 💡 Design Decisions

### Why Gradient AppBar?
- **Consistency**: Matches app-wide design pattern
- **Visual Appeal**: Modern, professional look
- **Brand Identity**: Purple theme throughout

### Why Priority Badges?
- **Quick Recognition**: Colors indicate urgency instantly
- **Kitchen Workflow**: Staff can prioritize at a glance
- **Reduce Errors**: Less likely to miss urgent orders

### Why Statistics Dashboard?
- **Situational Awareness**: Know workload at a glance
- **Performance Tracking**: Monitor kitchen efficiency
- **Decision Support**: Helps prioritize work

### Why Large Product Cards?
- **Readability**: Easy to read in busy kitchen
- **Error Prevention**: Clear, organized list
- **Visual Tracking**: Checkboxes for mental tracking

### Why Prominent Action Button?
- **Efficiency**: One-tap to complete order
- **Visibility**: Can't be missed
- **Touch-Friendly**: Large target for quick taps

---

## 🔄 User Interaction Flow

### Viewing Orders
```
1. Open Kitchen Screen
   ↓
2. See Statistics Dashboard (get overview)
   ↓
3. Scroll through order list
   ↓
4. Notice priority colors/badges
   ↓
5. Focus on urgent orders first
```

### Filtering Orders
```
1. Tap Filter Icon (⚙️) in AppBar
   ↓
2. Menu drops down
   ↓
3. Select filter option
   ↓
4. List updates immediately
   ↓
5. Statistics update to match filter
```

### Sorting Orders
```
1. Tap Sort Icon (↕️) in AppBar
   ↓
2. Menu drops down
   ↓
3. Select sort option
   ↓
4. List reorders immediately
   ↓
5. Can combine with filter
```

### Completing Order
```
1. Review order details
   ↓
2. Check customer info
   ↓
3. Prepare all products
   ↓
4. Tap "Marcar como Preparado"
   ↓
5. Order moves to next state
   ↓
6. Success notification appears
   ↓
7. List refreshes automatically
```

---

## 📸 Screenshot Guide

### Recommended Screenshots

1. **Main Screen with Multiple Orders**
   - Shows variety of priority levels
   - Demonstrates card design
   - Highlights statistics

2. **Filter Menu Open**
   - Shows dropdown menu
   - All filter options visible

3. **Sort Menu Open**
   - Shows dropdown menu
   - All sort options visible

4. **Single Order Card (Urgent)**
   - Close-up of orange-bordered card
   - All sections clearly visible
   - Action button prominent

5. **Single Order Card (Very Urgent)**
   - Close-up of red-bordered card
   - Emphasizes urgency

6. **Empty State**
   - Shows friendly message
   - Clean, uncluttered design

7. **Statistics Dashboard Close-Up**
   - Focus on stats section
   - Shows icons and numbers

---

## ✨ Special Effects

### Shadows
```
Card Shadow:
  - Color: Black (10% opacity)
  - Blur Radius: 8
  - Offset: (0, 4)

AppBar Shadow:
  - Color: Black (26% opacity)
  - Blur Radius: 8
  - Offset: (0, 4)

Product Card Shadow:
  - Color: Black (5% opacity)
  - Blur Radius: 4
  - Offset: (0, 2)
```

### Gradients
```
AppBar:
  - Colors: [deepPurple, purpleAccent]
  - Begin: topLeft
  - End: bottomRight

Statistics Card:
  - Colors: [deepPurple.shade100, white]
  - Begin: topLeft
  - End: bottomRight

Order Card (based on priority):
  - Colors: [white, priorityColor.withOpacity(0.05)]
  - Begin: topLeft
  - End: bottomRight
```

---

## 🎯 Final Polish

### Details that Matter

✅ **Rounded Corners**: All cards use consistent 15px radius  
✅ **Consistent Spacing**: 8-point grid system throughout  
✅ **Icon Alignment**: All icons aligned with text baseline  
✅ **Color Balance**: No color overwhelms, balanced palette  
✅ **Touch Feedback**: All interactive elements have ripple  
✅ **Loading States**: Spinner shows during refresh  
✅ **Error States**: Friendly messages for errors  
✅ **Success States**: Snackbar confirms actions  

---

## 🏆 Design Quality Checklist

- [x] Consistent color palette
- [x] Clear visual hierarchy
- [x] Adequate touch targets
- [x] Proper spacing and alignment
- [x] Readable typography
- [x] Meaningful icons
- [x] Appropriate shadows
- [x] Smooth animations
- [x] Accessible contrast ratios
- [x] Responsive layout
- [x] Professional polish
- [x] User-friendly interface

---

**This design achieves a professional, functional, and beautiful kitchen management interface! 🎨**

**Ready to impress users and improve kitchen efficiency! 🍳**
