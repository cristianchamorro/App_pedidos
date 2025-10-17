# Testing Guide for productos_por_categoria_page Improvements

## Manual Testing Steps

### 1. Test Search Functionality
**Steps:**
1. Navigate to the products page
2. Type text in the search bar at the top
3. Verify that products are filtered as you type
4. Click the 'X' button to clear the search
5. Verify all products are shown again

**Expected Results:**
- Products filter in real-time
- Only matching products (by name or description) are shown
- Clear button appears when there's text
- Categories without matching products are hidden

### 2. Test Category Filter
**Steps:**
1. Navigate to the products page
2. Click on different category chips in the horizontal scroll area
3. Verify that only products from the selected category are shown
4. Click "Todas" to see all products again

**Expected Results:**
- Only selected category's products are displayed
- Selected category chip is highlighted with purple background
- Product count is shown in each category chip
- "Todas" shows all products from all categories

### 3. Test Shopping Cart Badge
**Steps:**
1. Start with an empty cart
2. Verify no cart badge is shown
3. Add a product to the cart
4. Verify the cart badge appears with count "1"
5. Add more products
6. Verify the count increases

**Expected Results:**
- Badge only shows when cart has items
- Badge shows correct item count
- Badge is clickable and opens confirm order page

### 4. Test Cart Summary Widget
**Steps:**
1. Add products to the cart
2. Verify the cart summary appears below the address field
3. Check that it shows correct total items
4. Check that it shows correct total price
5. Click "Ver Carrito" button

**Expected Results:**
- Summary only shows when cart has items
- Shows correct item count (singular/plural form)
- Shows correct total price with 2 decimal places
- Button navigates to confirm order page

### 5. Test Enhanced Product Cards
**Steps:**
1. View the product grid
2. Check that images load correctly
3. Verify price badge appears on top-right of image
4. Tap on a product card to see details
5. Use +/- buttons to change quantity
6. Click "Agregar" button

**Expected Results:**
- Images display with 1.2:1 aspect ratio
- Price badge is visible on image
- Product name and description (if any) are shown
- Quantity controls work correctly
- Add button shows success snackbar with green background and check icon

### 6. Test Enhanced Category Cards
**Steps:**
1. View the category list
2. Verify each category shows product count badge
3. Verify category icon is shown with background
4. Tap on a category from the filter chips
5. Verify that category expands automatically

**Expected Results:**
- Product count badge shows correct number
- Category icon has rounded background
- Selected category expands automatically
- Categories maintain consistent styling

### 7. Test Combined Filters
**Steps:**
1. Select a category from the chips
2. Type text in the search bar
3. Verify both filters work together

**Expected Results:**
- Only products matching both category AND search text are shown
- If no products match, no categories are shown
- Clearing search shows all products from selected category
- Deselecting category shows all matching search results

### 8. Test Responsive Design
**Steps:**
1. View the page on different screen sizes (if possible)
2. Verify the grid adjusts column count
3. Verify horizontal category scroll works on small screens

**Expected Results:**
- Grid shows appropriate number of columns based on screen width
- All elements are properly sized and readable
- No horizontal overflow issues

### 9. Test Notifications
**Steps:**
1. Add a product to cart
2. Add the same product again
3. Verify different messages for add vs update

**Expected Results:**
- New product shows green snackbar with "agregado" message
- Existing product shows green snackbar with "actualizado" message
- Snackbars disappear after 1 second
- Snackbars show check icon

### 10. Test Backwards Compatibility
**Steps:**
1. Test with admin role
2. Verify admin buttons (Agregar Producto, Cajero, Cocinero) still work
3. Verify address field is editable
4. Verify location permission still works when confirming order

**Expected Results:**
- All existing functionality remains unchanged
- No features have been removed
- Admin features work as before

## Automated Testing (when Flutter SDK is available)

```dart
// Example widget test for search functionality
testWidgets('Search filters products correctly', (WidgetTester tester) async {
  // Create test data
  final products = [
    Product(id: 1, name: 'Pizza', categoryId: 1, categoryName: 'Comidas', price: 10.0, vendorId: 1),
    Product(id: 2, name: 'Hamburguesa', categoryId: 1, categoryName: 'Comidas', price: 8.0, vendorId: 1),
    Product(id: 3, name: 'Coca Cola', categoryId: 2, categoryName: 'Bebidas', price: 2.0, vendorId: 1),
  ];

  // Build widget
  await tester.pumpWidget(MaterialApp(
    home: ProductosPorCategoriaPage(
      productos: products,
      direccionEntrega: 'Test address',
      role: 'user',
    ),
  ));

  // Type in search field
  await tester.enterText(find.byType(TextField).first, 'Pizza');
  await tester.pump();

  // Verify only Pizza is shown
  expect(find.text('Pizza'), findsOneWidget);
  expect(find.text('Hamburguesa'), findsNothing);
  expect(find.text('Coca Cola'), findsNothing);
});
```

## Performance Testing
- Verify smooth scrolling with large product lists
- Check that search filters don't cause lag
- Verify images load progressively without blocking UI
- Check that category expansion animations are smooth

## Accessibility Testing
- Verify all interactive elements have proper tooltips
- Check that text is readable with sufficient contrast
- Verify that touch targets are adequately sized
- Test with screen readers if available
