# Location Screen Testing Guide

## 🧪 Testing Overview
This guide provides step-by-step instructions for testing all new features and improvements made to the location screen.

---

## 📱 Prerequisites

### Required Setup
1. **Backend Server**: Running on `http://192.168.101.6:3000`
2. **Flutter App**: Built and running on test device/emulator
3. **Permissions**: Location permissions granted (for mobile/desktop)
4. **Internet**: Active internet connection for geocoding

### Test Platforms
- ✅ Android Mobile
- ✅ iOS Mobile  
- ✅ Desktop (Windows/macOS/Linux)
- ✅ Web Browser

---

## 🎯 Test Scenarios

### Scenario 1: Initial Screen Load
**Objective**: Verify the screen loads correctly with all UI elements

**Steps:**
1. Launch the app
2. Navigate to login → Select "Ingresar como Usuario"
3. Observe the location screen loads

**Expected Results:**
- ✅ AppBar displays "Captura tu ubicación" with gradient background
- ✅ Status card shows "Sin ubicación" with orange icon
- ✅ Text reads "Selecciona un método para capturar tu ubicación"
- ✅ Section title "Selecciona un método de captura:" is visible
- ✅ On mobile/desktop: GPS and Map cards are visible
- ✅ On all platforms: Search and Manual cards are visible
- ✅ No recent addresses section (first time)
- ✅ Continue button is disabled (grey)

---

### Scenario 2: GPS Location Capture (Mobile/Desktop Only)
**Objective**: Test automatic GPS location capture

**Steps:**
1. On location screen, tap "Ubicación GPS" card
2. Grant location permission if prompted
3. Wait for location capture (shows loading indicator)
4. Observe the result

**Expected Results:**
- ✅ Loading indicator appears during capture
- ✅ Status card updates to show green check icon
- ✅ Status text changes to "Ubicación capturada"
- ✅ Full address is displayed (e.g., "Calle 100, Bogotá, Cundinamarca")
- ✅ Blue accuracy badge appears showing precision (e.g., "Precisión: 15m")
- ✅ Method shows "Método: GPS"
- ✅ Address is added to recent addresses section
- ✅ Continue button becomes enabled (purple with shadow)

**Edge Cases:**
- **Permission denied**: Error message "Permiso de ubicación denegado"
- **GPS disabled**: Message "Servicios de ubicación deshabilitados"
- **Timeout**: Check after 30 seconds for timeout handling
- **Low accuracy**: Accuracy badge should show actual precision

---

### Scenario 3: Map Selection (Mobile/Desktop Only)
**Objective**: Test interactive map location picker

**Steps:**
1. On location screen, tap "Seleccionar en mapa" card
2. Map dialog opens
3. Observe the map interface
4. Tap any location on the map
5. Dialog closes automatically

**Expected Results:**
- ✅ Full-screen map dialog opens (500px height)
- ✅ Map is centered on Bogotá (4.710989, -74.072090)
- ✅ Zoom level is 15
- ✅ Instruction overlay shows "📍 Toca en el mapa para seleccionar tu ubicación"
- ✅ "My Location" button is visible and functional
- ✅ Tapping on map closes dialog and selects location
- ✅ Status card updates with address from selected coordinates
- ✅ Method shows "Método: Mapa"
- ✅ Address is added to recent addresses
- ✅ Continue button becomes enabled

**Edge Cases:**
- **On web**: Shows error "El mapa no está disponible en versión Web"
- **No internet**: Map may not load properly
- **Tap outside dialog**: Dialog closes without selection

---

### Scenario 4: Address Search
**Objective**: Test geocoding-based address search

**Steps:**
1. Scroll to "Buscar dirección" card
2. Tap on the search text field
3. Type: "Calle 100 Bogotá"
4. Tap "Buscar" button
5. Wait for geocoding result

**Expected Results:**
- ✅ Text field accepts input
- ✅ "Buscar" button is enabled
- ✅ Loading indicator appears after tapping search
- ✅ Status card updates with resolved address
- ✅ Method shows "Método: Búsqueda"
- ✅ Address is added to recent addresses
- ✅ Continue button becomes enabled

**Edge Cases:**

**Test Case 4.1: Empty Search**
- Input: (empty field)
- Tap: "Buscar"
- Expected: SnackBar "Por favor ingresa una dirección para buscar"

**Test Case 4.2: Too Short**
- Input: "AB"
- Tap: "Buscar"
- Expected: SnackBar "La dirección debe tener al menos 3 caracteres"

**Test Case 4.3: Invalid Address**
- Input: "asdfghjkl123456"
- Tap: "Buscar"
- Expected: 
  - Status shows "No se encontró la dirección"
  - SnackBar "No se encontró la dirección. Intenta con más detalles."
  - Method resets to "none"
  - Continue button remains disabled

**Test Case 4.4: Network Error**
- Disable internet, then search
- Expected: SnackBar "No se pudo buscar la dirección. Verifica tu conexión."

**Test Case 4.5: Valid Search**
- Input: "Parque de la 93, Bogotá"
- Expected: Precise address with coordinates

---

### Scenario 5: Manual Address Entry
**Objective**: Test direct text input for address

**Steps:**
1. Scroll to "Escribir dirección" card
2. Tap on the manual address text field
3. Type: "Carrera 7 #100-20, Bogotá"
4. Tap "Usar esta dirección" button

**Expected Results:**
- ✅ Text field accepts multi-line input (up to 2 lines)
- ✅ Status card updates with entered text
- ✅ Method shows "Método: Manual"
- ✅ Address is added to recent addresses
- ✅ Continue button becomes enabled
- ✅ No GPS coordinates (location is null)

**Edge Cases:**

**Test Case 5.1: Empty Manual Entry**
- Input: (empty field)
- Tap: "Usar esta dirección"
- Expected: SnackBar "Por favor ingresa una dirección"

**Test Case 5.2: Very Long Address**
- Input: 200+ characters
- Expected: Field should handle gracefully, may wrap to multiple lines

**Test Case 5.3: Special Characters**
- Input: "Calle 123 #45-67 Apto. 89B Torre 2 Edificio XYZ"
- Expected: Accepts all characters correctly

---

### Scenario 6: Recent Addresses
**Objective**: Test recent address quick selection

**Precondition**: Complete any of scenarios 2-5 at least once

**Steps:**
1. After capturing a location, navigate away (tap back)
2. Return to location screen
3. Scroll down to see "Direcciones recientes:" section
4. Observe the list of recent addresses
5. Tap on a recent address

**Expected Results:**
- ✅ Recent addresses section appears after first address capture
- ✅ Shows up to 3 most recent addresses
- ✅ Each item has teal history icon
- ✅ Each item shows full address text
- ✅ Each item has arrow indicator on right
- ✅ Tapping an item immediately sets it as current address
- ✅ Status card updates
- ✅ Method shows "Método: Reciente"
- ✅ Continue button becomes enabled
- ✅ No loading state (instant)

**Test Multiple Addresses:**
1. Capture GPS location → Address A added
2. Search for address → Address B added (A moves down)
3. Enter manual address → Address C added (A, B move down)
4. Enter 4th address → Address A is removed (only last 3 kept)

---

### Scenario 7: Continue Button Functionality
**Objective**: Test navigation to products page

**Steps:**
1. Capture any location using any method
2. Ensure status shows "Ubicación capturada"
3. Tap "Continuar" button
4. Wait for API call to complete

**Expected Results:**
- ✅ Button shows loading spinner during API call
- ✅ Successfully navigates to products page
- ✅ Products page receives address in arguments
- ✅ Role is passed correctly ("user" for normal flow)

**Edge Cases:**

**Test Case 7.1: API Error**
- Disconnect backend server
- Tap Continue
- Expected: Error message appears in status card

**Test Case 7.2: Network Timeout**
- Simulate slow network
- Expected: Loading indicator shows, eventually times out with error

**Test Case 7.3: Disabled State**
- Without capturing location, try tapping Continue
- Expected: Button is disabled and nothing happens

---

### Scenario 8: Platform-Specific Behavior
**Objective**: Verify correct features shown per platform

**Test 8.1: Web Platform**
**Steps:**
1. Open app in web browser
2. Navigate to location screen

**Expected Results:**
- ✅ GPS card is NOT visible
- ✅ Map card is NOT visible
- ✅ Search card IS visible
- ✅ Manual card IS visible
- ✅ Tapping GPS/Map (if somehow accessible) shows error

**Test 8.2: Mobile Platform**
**Expected Results:**
- ✅ All 4 method cards visible (GPS, Map, Search, Manual)
- ✅ GPS capture works with device sensor
- ✅ Map uses native Google Maps

**Test 8.3: Desktop Platform**
**Expected Results:**
- ✅ All 4 method cards visible
- ✅ GPS may require additional permissions
- ✅ Map renders correctly in desktop window

---

### Scenario 9: UI Responsiveness
**Objective**: Test UI on different screen sizes

**Test 9.1: Small Phone (e.g., iPhone SE)**
- All cards should be visible
- No horizontal scrolling
- Text should not overflow
- Buttons should be tappable
- Status card should not be truncated

**Test 9.2: Large Tablet**
- Cards should maintain readable width
- Content should be centered
- No awkward stretching
- All spacing proportional

**Test 9.3: Landscape Orientation**
- Content should scroll vertically
- Cards should adapt to width
- Map dialog should expand properly

---

### Scenario 10: Loading States
**Objective**: Verify all loading indicators work

**Check loading appears for:**
- ✅ GPS capture (during location fetch)
- ✅ Map selection (during reverse geocoding)
- ✅ Address search (during geocoding API call)
- ✅ Continue button (during products API call)

**Loading indicators should:**
- ✅ Be visible and animated (spinner)
- ✅ Disable user interaction during load
- ✅ Disappear on success or error
- ✅ Show appropriate duration (not too fast or slow)

---

### Scenario 11: Error Handling
**Objective**: Test all error scenarios

**Error Messages to Test:**

1. **GPS Errors:**
   - Location services disabled
   - Permission denied
   - Permission denied forever
   - GPS timeout
   - Geocoding failure

2. **Map Errors:**
   - Map not available on web
   - Failed to get address from coordinates
   - No internet during reverse geocoding

3. **Search Errors:**
   - Empty search
   - Too short (< 3 chars)
   - No results found
   - Network error
   - Geocoding API error

4. **Manual Errors:**
   - Empty field

5. **Continue Errors:**
   - API server down
   - Network error
   - Invalid response

**All errors should:**
- ✅ Show clear, user-friendly message
- ✅ Not crash the app
- ✅ Allow user to retry
- ✅ Reset to appropriate state

---

### Scenario 12: State Persistence
**Objective**: Test state behavior during session

**Steps:**
1. Capture GPS location
2. Navigate to products page
3. Press back button
4. Return to location screen

**Expected Results:**
- ✅ Previous address is still shown in status
- ✅ Recent addresses list persists
- ✅ Can capture new location
- ✅ Can select from recents

**Note:** State is session-only, not persisted between app restarts.

---

## 🎨 Visual Regression Tests

### Check These Visual Elements:

1. **AppBar:**
   - ✅ Gradient (deep purple to purple accent)
   - ✅ Rounded bottom corners (20px)
   - ✅ Shadow effect
   - ✅ White text, centered
   - ✅ Back button (white icon)

2. **Status Card:**
   - ✅ Gradient background (purple shade 100 to white)
   - ✅ Rounded corners (15px)
   - ✅ Correct icon based on state
   - ✅ Icon color matches state (orange/green)
   - ✅ Accuracy badge (blue, rounded)
   - ✅ Method text (grey, italic)

3. **Method Cards:**
   - ✅ Consistent elevation (3px)
   - ✅ Rounded corners (12px)
   - ✅ Icon containers with correct colors
   - ✅ Icons sized correctly (28px for methods)
   - ✅ Title bold, subtitle grey
   - ✅ Arrow indicator on right

4. **Input Cards:**
   - ✅ Search card (purple theme)
   - ✅ Manual card (orange theme)
   - ✅ Text fields with rounded borders
   - ✅ Prefix icons
   - ✅ Action buttons with correct colors

5. **Recent Addresses:**
   - ✅ Teal theme for history
   - ✅ List tiles with proper spacing
   - ✅ Icons sized correctly (20px)

6. **Continue Button:**
   - ✅ Large size (56px height)
   - ✅ Purple when enabled, grey when disabled
   - ✅ Shadow on enabled
   - ✅ Arrow icon
   - ✅ Spinner when loading

---

## 📊 Performance Tests

### Test Performance Metrics:

1. **Initial Load Time:**
   - Screen should appear within 500ms

2. **GPS Capture:**
   - Should complete within 5-10 seconds (normal conditions)

3. **Geocoding Search:**
   - Should return results within 2-3 seconds

4. **Map Interaction:**
   - Map should be responsive to tap immediately
   - Reverse geocoding after tap should complete within 2 seconds

5. **UI Responsiveness:**
   - No lag when scrolling
   - Buttons respond immediately to tap
   - No frozen UI during operations

---

## ✅ Acceptance Criteria

### Must Pass All:

- [ ] All 12 test scenarios pass
- [ ] No crashes or freezes
- [ ] All error cases handled gracefully
- [ ] UI matches design specifications
- [ ] Works on all target platforms
- [ ] Performance is acceptable
- [ ] Loading states are visible
- [ ] Error messages are clear
- [ ] Recent addresses work correctly
- [ ] Continue button navigates correctly
- [ ] Backwards compatibility maintained

---

## 🐛 Bug Reporting Template

If you find issues during testing, report using this format:

```markdown
**Issue Title:** [Brief description]

**Severity:** [Critical/High/Medium/Low]

**Platform:** [Web/Android/iOS/Desktop]

**Steps to Reproduce:**
1. 
2. 
3. 

**Expected Result:**
[What should happen]

**Actual Result:**
[What actually happened]

**Screenshots/Logs:**
[Attach if available]

**Environment:**
- Device: [e.g., iPhone 12]
- OS: [e.g., iOS 15.0]
- App Version: [e.g., 1.0.0]
```

---

## 📝 Test Results Checklist

Use this checklist to track your testing progress:

### Functional Tests
- [ ] Initial screen load
- [ ] GPS capture (mobile/desktop)
- [ ] Map selection (mobile/desktop)
- [ ] Address search
- [ ] Manual entry
- [ ] Recent addresses
- [ ] Continue navigation
- [ ] Platform-specific behavior
- [ ] Error handling

### UI Tests
- [ ] AppBar styling
- [ ] Status card
- [ ] Method cards
- [ ] Input forms
- [ ] Recent list
- [ ] Continue button
- [ ] Loading states

### Edge Cases
- [ ] Empty inputs
- [ ] Invalid data
- [ ] Network errors
- [ ] Permission issues
- [ ] Long text
- [ ] Multiple rapid taps

### Cross-Platform
- [ ] Android mobile
- [ ] iOS mobile
- [ ] Web browser
- [ ] Desktop app

### Performance
- [ ] Load time < 500ms
- [ ] GPS < 10s
- [ ] Search < 3s
- [ ] No UI lag

---

## 🎯 Success Metrics

The feature is ready for production when:
- ✅ 100% of scenarios pass
- ✅ 0 critical bugs
- ✅ 0 high-priority bugs
- ✅ < 3 medium bugs
- ✅ UI matches design on all platforms
- ✅ Performance meets targets
- ✅ User experience is smooth and intuitive

---

This comprehensive testing guide ensures the location screen improvements are thoroughly validated before deployment.
