# Frontend Implementation Summary: changed_by Parameter Support

## Overview
This implementation adds support for the `changed_by` parameter in the frontend to track which user made status changes to orders. This aligns the frontend with the backend changes that were made to properly track status history and automatically release drivers.

## Changes Made

### 1. ApiService Updates (`app_frontend/lib/api_service.dart`)

#### a. `confirmarPago` Method
**Before**:
```dart
Future<bool> confirmarPago(int orderId, double efectivo) async {
  final url = Uri.parse('$baseUrl/pedidos/$orderId/pago');
  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"efectivo": efectivo}),
  );
  // ...
}
```

**After**:
```dart
Future<bool> confirmarPago(int orderId, double efectivo, {int? changedBy}) async {
  final url = Uri.parse('$baseUrl/pedidos/$orderId/pago');
  final body = {
    "efectivo": efectivo,
    if (changedBy != null) "changed_by": changedBy,
  };
  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );
  // ...
}
```

**Key Changes**:
- Added optional `changedBy` parameter of type `int?`
- Conditionally includes `changed_by` in request body only if provided
- Maintains backward compatibility (parameter is optional)

#### b. `marcarListoCocina` Method
**Before**:
```dart
Future<bool> marcarListoCocina(int orderId, {String changedBy = "cocinero"}) async {
  final url = Uri.parse('$baseUrl/pedidos/$orderId/listo');
  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"changed_by": changedBy}),
  );
  // ...
}
```

**After**:
```dart
Future<bool> marcarListoCocina(int orderId, {int? changedBy}) async {
  final url = Uri.parse('$baseUrl/pedidos/$orderId/listo');
  final body = <String, dynamic>{};
  if (changedBy != null) {
    body["changed_by"] = changedBy;
  }
  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );
  // ...
}
```

**Key Changes**:
- Changed parameter type from `String` to `int?` (to match backend expectations)
- Removed default value (was `"cocinero"`)
- Conditionally includes `changed_by` only if provided
- Aligns with backend's `normalizeChangedBy` function which expects a number

### 2. Login Flow Updates (`app_frontend/lib/pages/login_admin_page.dart`)

**Before**:
```dart
if (result["success"] == true) {
  final role = result["role"] ?? "user";
  
  switch (role) {
    case "cajero":
      Navigator.pushReplacementNamed(
        context,
        '/cajero',
        arguments: {"role": "cajero"},
      );
      break;
    // ... other cases
  }
}
```

**After**:
```dart
if (result["success"] == true) {
  final role = result["role"] ?? "user";
  final userId = result["userId"] ?? 0;
  
  switch (role) {
    case "cajero":
      Navigator.pushReplacementNamed(
        context,
        '/cajero',
        arguments: {"role": "cajero", "userId": userId},
      );
      break;
    // ... other cases with userId
  }
}
```

**Key Changes**:
- Extracts `userId` from login response
- Passes `userId` through navigation arguments for all roles (admin, cajero, cocinero)
- Enables user tracking throughout the application

### 3. Cashier Page Updates (`app_frontend/lib/pages/pedidos_cajero_page.dart`)

**Added State Variable**:
```dart
class _PedidosCajeroPageState extends State<PedidosCajeroPage> {
  final ApiService api = ApiService();
  late Future<List<Map<String, dynamic>>> _pedidosPendientes;
  int? _userId; // ← New field
  
  // ...
}
```

**Added didChangeDependencies Method**:
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Get userId from navigation arguments
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  if (args != null && args.containsKey('userId')) {
    _userId = args['userId'] as int?;
  }
}
```

**Updated PagoPage Navigation**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PagoPage(
      pedidoId: pedido['order_id'],
      total: double.tryParse(pedido['total'].toString()) ?? 0.0,
      userId: _userId, // ← Pass userId
    ),
  ),
);
```

**Key Changes**:
- Retrieves `userId` from navigation arguments in `didChangeDependencies`
- Passes `userId` to `PagoPage` when navigating

### 4. Payment Page Updates (`app_frontend/lib/pages/pago_page.dart`)

**Updated Constructor**:
```dart
class PagoPage extends StatefulWidget {
  final int pedidoId;
  final double total;
  final int? userId; // ← New parameter
  
  const PagoPage({
    Key? key, 
    required this.pedidoId, 
    required this.total, 
    this.userId // ← Optional parameter
  }) : super(key: key);
  
  // ...
}
```

**Updated confirmarPago Call**:
```dart
Future<void> _confirmarPago() async {
  // ...
  bool success = await api.confirmarPago(
    widget.pedidoId, 
    efectivo, 
    changedBy: widget.userId, // ← Pass userId
  );
  // ...
}
```

**Key Changes**:
- Accepts optional `userId` parameter
- Passes `userId` to `api.confirmarPago` method

### 5. Cook Page Updates (`app_frontend/lib/pages/pedidos_cocinero_page.dart`)

**Added State Variable**:
```dart
class _PedidosCocineroPageState extends State<PedidosCocineroPage> {
  final ApiService api = ApiService();
  List<Map<String, dynamic>> pedidos = [];
  bool isLoading = true;
  Timer? _timer;
  int? _userId; // ← New field
  
  // ...
}
```

**Added didChangeDependencies Method**:
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Get userId from navigation arguments
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  if (args != null && args.containsKey('userId')) {
    _userId = args['userId'] as int?;
  }
}
```

**Updated marcarListoCocina Call**:
```dart
Future<void> _marcarComoListo(int orderId) async {
  try {
    bool success = await api.marcarListoCocina(
      orderId, 
      changedBy: _userId // ← Pass userId
    );
    // ...
  } catch (e) {
    // ...
  }
}
```

**Key Changes**:
- Retrieves `userId` from navigation arguments
- Passes `userId` to `api.marcarListoCocina` method

## Technical Details

### Data Flow
1. User logs in → Backend returns `userId` and `role`
2. LoginAdminPage extracts `userId` from login response
3. Navigation passes `userId` as argument to role-specific pages
4. Role pages (Cajero, Cocinero) retrieve `userId` from navigation arguments
5. Status change operations pass `userId` as `changed_by` to API methods
6. API methods send `changed_by` to backend endpoints
7. Backend stores `changed_by` in `status_history` table

### Backend Compatibility
The frontend changes align with the backend's `normalizeChangedBy` helper function:
```javascript
const normalizeChangedBy = (val) => {
  if (val === undefined || val === null) return null;
  const n = Number(val);
  return Number.isFinite(n) ? Math.trunc(n) : null;
};
```

- Frontend sends `int` (user ID) or `null`
- Backend accepts numeric values or `null`
- Non-numeric values are converted to `null` by backend

### Backward Compatibility
All changes maintain backward compatibility:
- `changedBy` parameters are optional in API methods
- If not provided, backend stores `null` in `status_history`
- Existing functionality continues to work without user tracking

## Benefits

1. **User Accountability**: Tracks which user made status changes to orders
2. **Audit Trail**: Complete history of who changed order statuses and when
3. **Consistency**: Aligns frontend behavior with backend expectations
4. **Minimal Changes**: Surgical updates to only necessary components
5. **Backward Compatible**: Optional parameters ensure existing code continues to work

## Files Modified

- `app_frontend/lib/api_service.dart`: Updated `confirmarPago` and `marcarListoCocina` methods
- `app_frontend/lib/pages/login_admin_page.dart`: Pass `userId` through navigation
- `app_frontend/lib/pages/pedidos_cajero_page.dart`: Receive and pass `userId` to payment page
- `app_frontend/lib/pages/pago_page.dart`: Accept and use `userId` for payment confirmation
- `app_frontend/lib/pages/pedidos_cocinero_page.dart`: Receive and use `userId` for marking orders ready

## Testing Recommendations

1. **Login Flow**: Verify that `userId` is correctly retrieved from login response
2. **Cashier Flow**: 
   - Login as cashier
   - Process a payment
   - Verify backend receives `changed_by` parameter
3. **Cook Flow**:
   - Login as cook
   - Mark order as ready
   - Verify backend receives `changed_by` parameter
4. **Database Verification**:
   - Check `status_history` table for correct `changed_by` values
   - Verify user IDs match logged-in users
5. **Null Cases**:
   - Test with users who don't pass userId (should still work)
   - Verify backend handles null `changed_by` gracefully

## Alignment with Backend Changes

This frontend implementation complements the backend changes documented in:
- `ATOMIC_DRIVER_ASSIGNMENT_README.md`
- `IMPLEMENTATION_SUMMARY.md`
- `SQL_CHANGES.md`

Together, these changes provide:
- Atomic driver assignment and automatic release (backend)
- User tracking for status changes (frontend + backend)
- Complete audit trail of order state changes
