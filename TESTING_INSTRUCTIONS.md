# Testing Instructions for Login Unification

## Prerequisites
- Flutter SDK installed
- App_pedidos backend running on port 3000
- Database with user_admin table and roles table
- Test users in database with different roles

## Database Setup

### Required Tables:
1. **roles** table with entries:
   - admin
   - cajero
   - cocinero
   - domiciliario

2. **user_admin** table with test users:
   ```sql
   -- Example test users
   INSERT INTO user_admin (username, password, name, role_id) VALUES
   ('admin1', 'admin123', 'Administrator', 1),
   ('cajero1', 'cajero123', 'Cashier User', 2),
   ('cocinero1', 'cocinero123', 'Chef User', 3),
   ('domiciliario1', 'dom123', 'Delivery Driver', 4);
   ```

## Test Scenarios

### Test 1: Normal User Flow
**Objective**: Verify that normal users can access the app and order products.

**Steps**:
1. Launch the app
2. Verify you see the `LoginChoicePage` with 2 buttons
3. Click "Ingresar como Usuario" button
4. Verify you are redirected to `LocationScreen`
5. Enter or select a location
6. Click "Continuar"
7. Verify you reach the products page

**Expected Results**:
- ✅ LoginChoicePage displays with modern UI
- ✅ User button is purple with white text
- ✅ Navigation to LocationScreen works
- ✅ Can proceed to products page

### Test 2: Admin Login Flow
**Objective**: Verify that admin users can log in and access admin features.

**Steps**:
1. Launch the app
2. Click "Ingresar como Administrador" button
3. Verify you see the `LoginAdminPage` with enhanced UI
4. Enter credentials: username=`admin1`, password=`admin123`
5. Click "Ingresar" button
6. Verify you are redirected to `LocationScreen` with admin role

**Expected Results**:
- ✅ LoginAdminPage displays with card layout and gradient
- ✅ Form fields have icons (person and lock)
- ✅ Login succeeds with valid credentials
- ✅ Navigation to admin location screen works

### Test 3: Cajero (Cashier) Login Flow
**Objective**: Verify cajero role routing.

**Steps**:
1. Launch the app
2. Click "Ingresar como Administrador"
3. Enter credentials: username=`cajero1`, password=`cajero123`
4. Click "Ingresar"
5. Verify you are redirected to `PedidosCajeroPage`

**Expected Results**:
- ✅ Login succeeds
- ✅ Redirected to cashier orders page
- ✅ Can view pending orders
- ✅ Can process payments

### Test 4: Cocinero (Chef) Login Flow
**Objective**: Verify cocinero role routing.

**Steps**:
1. Launch the app
2. Click "Ingresar como Administrador"
3. Enter credentials: username=`cocinero1`, password=`cocinero123`
4. Click "Ingresar"
5. Verify you are redirected to `PedidosCocineroPage`

**Expected Results**:
- ✅ Login succeeds
- ✅ Redirected to kitchen orders page
- ✅ Can view orders in preparation
- ✅ Can mark orders as ready

### Test 5: Domiciliario (Delivery Driver) Login Flow ⭐ NEW
**Objective**: Verify domiciliario role routing (main new feature).

**Steps**:
1. Launch the app
2. Click "Ingresar como Administrador"
3. Enter credentials: username=`domiciliario1`, password=`dom123`
4. Click "Ingresar"
5. Verify you are redirected to `DomiciliarioPage`

**Expected Results**:
- ✅ Login succeeds
- ✅ Redirected to delivery driver page
- ✅ Can view assigned orders
- ✅ Can update location
- ✅ Can update order status (picked up, on route, delivered)

### Test 6: Invalid Credentials
**Objective**: Verify error handling for incorrect credentials.

**Steps**:
1. Launch the app
2. Click "Ingresar como Administrador"
3. Enter invalid credentials: username=`wrong`, password=`wrong`
4. Click "Ingresar"
5. Verify error message appears

**Expected Results**:
- ✅ Error message displayed in red container
- ✅ Error icon shown
- ✅ Message: "Usuario o contraseña incorrectos"
- ✅ User remains on login page
- ✅ Can retry with correct credentials

### Test 7: Backend Connection Error
**Objective**: Verify error handling when backend is unavailable.

**Steps**:
1. Stop the backend server
2. Launch the app
3. Click "Ingresar como Administrador"
4. Enter any credentials
5. Click "Ingresar"
6. Verify error message appears

**Expected Results**:
- ✅ Error message displayed
- ✅ Message includes "Error al conectar con el servidor"
- ✅ Loading indicator disappears
- ✅ User can retry when backend is back online

### Test 8: Form Validation
**Objective**: Verify form validation works correctly.

**Steps**:
1. Launch the app
2. Click "Ingresar como Administrador"
3. Leave username empty and click "Ingresar"
4. Verify validation message appears
5. Enter username
6. Leave password empty and click "Ingresar"
7. Verify validation message appears

**Expected Results**:
- ✅ "Ingrese usuario" message for empty username
- ✅ "Ingrese contraseña" message for empty password
- ✅ Submit button disabled until valid
- ✅ Validation prevents API call

### Test 9: Unknown Role Handling
**Objective**: Verify handling of unknown roles from database.

**Steps**:
1. Manually add a user with an undefined role in database
2. Login with that user
3. Verify error message appears

**Expected Results**:
- ✅ Error message displayed
- ✅ Message includes "Rol desconocido"
- ✅ User remains on login page

### Test 10: Navigation and Back Button
**Objective**: Verify navigation flow and back button behavior.

**Steps**:
1. Launch app (LoginChoicePage)
2. Click "Ingresar como Administrador"
3. Verify back button appears in AppBar
4. Click back button
5. Verify you return to LoginChoicePage
6. Try navigation again

**Expected Results**:
- ✅ Back button visible on LoginAdminPage
- ✅ Back navigation works correctly
- ✅ Can navigate forward again
- ✅ No memory leaks or state issues

## UI Visual Testing

### LoginChoicePage Visual Checks:
- [ ] Gradient AppBar with rounded bottom corners
- [ ] Restaurant icon in circular white container with shadow
- [ ] "Selecciona tu tipo de ingreso" text visible
- [ ] Two full-width buttons with proper styling
- [ ] User button: purple background, white text
- [ ] Admin button: white background, purple border and text
- [ ] Proper spacing between elements
- [ ] Icons visible in buttons (person and admin_panel_settings)
- [ ] Text is bold and properly sized

### LoginAdminPage Visual Checks:
- [ ] Gradient background (purple to white)
- [ ] Elevated card with rounded corners
- [ ] Admin icon in circular purple background
- [ ] "Iniciar Sesión" title in purple
- [ ] "Ingrese sus credenciales" subtitle in grey
- [ ] Username field with person icon
- [ ] Password field with lock icon
- [ ] Fields have proper focus styling (purple border)
- [ ] Error message in red container with icon (when applicable)
- [ ] Submit button full width with purple background
- [ ] Loading indicator during login

## Performance Testing

### Areas to Test:
1. **App startup time**: Should be fast
2. **Navigation speed**: Transitions should be smooth
3. **API response**: Should handle delays gracefully with loading indicator
4. **Memory usage**: No leaks when navigating back and forth
5. **Form responsiveness**: Input should be immediate

## Device Testing

Test on multiple devices/sizes:
- [ ] Android phone (various screen sizes)
- [ ] iOS phone (various models)
- [ ] Tablet (Android and iOS)
- [ ] Web browser (Chrome, Firefox, Safari)

## Regression Testing

Verify existing functionality still works:
- [ ] Products page loads correctly
- [ ] Orders can be created
- [ ] Payment processing works
- [ ] Kitchen operations function
- [ ] Delivery operations function
- [ ] Location selection works

## Bug Reporting Template

If you find issues, report using this format:

```
**Issue Title**: [Brief description]

**Steps to Reproduce**:
1. Step 1
2. Step 2
3. ...

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happened]

**Screenshots**:
[If applicable]

**Environment**:
- Device: [phone/tablet/web]
- OS: [Android/iOS/Browser]
- App Version: [version]

**Additional Notes**:
[Any other relevant information]
```

## Success Criteria

All tests should pass with the following results:
- ✅ All 10 test scenarios complete successfully
- ✅ All UI visual checks pass
- ✅ No console errors or warnings
- ✅ Smooth performance on all tested devices
- ✅ No regressions in existing functionality

## Notes

- The domiciliario role is the main new feature - pay special attention to this flow
- The UI improvements should be consistent across all screens
- Error handling should be clear and user-friendly
- Navigation flow should be intuitive

## Troubleshooting

### Common Issues:

**Issue**: Backend connection errors
**Solution**: Ensure backend is running on correct port (3000) and accessible

**Issue**: Role not found
**Solution**: Verify database has all 4 roles defined

**Issue**: Login always fails
**Solution**: Check database user credentials match test values

**Issue**: Navigation doesn't work
**Solution**: Clear app data/cache and restart

**Issue**: UI looks different
**Solution**: Ensure you're using the latest code from the branch
