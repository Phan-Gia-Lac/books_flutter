# Real-time Synchronization for Product Management

Ensure that when an admin adds or deletes a product, the changes are reflected in real-time for users and updated in the database immediately.

## User Review Required

- **Socket.IO Integration**: To achieve real-time updates across different devices, I propose adding Socket.IO to both the backend and the Flutter app. This will allow the server to "push" updates to users instantly.
- **Soft Delete vs Hard Delete**: Currently, the system uses "soft delete" (marking a product as deleted in the DB instead of removing the row). This is necessary to maintain order history. I will ensure that soft-deleted items are completely hidden from all user views and search results, effectively achieving "deletion" from the user's perspective.
- **Order Synchronization**: I will extend the real-time sync to cover:
    - **User places order**: Admin sees the new order in their "Pending Orders" list instantly.
    - **Admin approves order**: User sees the status change in their "Order History" instantly.
- **Code Retention**: As requested, any code being replaced will be **commented out** instead of deleted, so you can easily track the changes.

## Proposed Changes

### [Backend] Real-time Updates

Establish a WebSocket connection using Socket.IO to notify clients of product and order changes.

#### [package.json](file:///D:/books_flutter/books-backend/package.json)
- Add `socket.io` to dependencies.

#### [NEW] [socket.js](file:///D:/books_flutter/books-backend/socket.js)
- Create a helper to initialize and access the Socket.IO instance.

#### [server.js](file:///D:/books_flutter/books-backend/server.js)
- Initialize Socket.IO with the HTTP server.

#### [controllers/comic.controller.js](file:///D:/books_flutter/books-backend/controllers/comic.controller.js)
- Emit `COMIC_CREATED`, `COMIC_UPDATED`, and `COMIC_DELETED` events.
- Ensure only active and non-deleted items are returned in standard list views.

#### [controllers/order.controller.js](file:///D:/books_flutter/books-backend/controllers/order.controller.js)
- Emit `ORDER_CREATED` when a user places a new order.
- Emit `ORDER_STATUS_UPDATED` when an admin updates an order status.

---

### [Flutter] Real-time UI Updates

Listen to WebSocket events and update the app's state immediately.

#### [pubspec.yaml](file:///D:/books_flutter/pubspec.yaml)
- Add `socket_io_client` to dependencies.

#### [NEW] [services/socket_service.dart](file:///D:/books_flutter/lib/services/socket_service.dart)
- Implement a service to connect to the backend and handle incoming events for comics and orders.

#### [viewmodel/productsVM.dart](file:///D:/books_flutter/lib/viewmodel/productsVM.dart)
- Add methods to handle real-time product updates.

#### [viewmodel/adminVM.dart](file:///D:/books_flutter/lib/viewmodel/adminVM.dart)
- Add methods to handle real-time product updates for admins.
- Add `onOrderCreated(dynamic order)` to update the pending orders list.

#### [viewmodel/authVM.dart](file:///D:/books_flutter/lib/viewmodel/authVM.dart)
- Add `onOrderStatusUpdated(dynamic order)` to potentially notify the user or update their local view if the order history is open (or I might create a separate OrderVM if needed, but for now I'll integrate with existing ones).

#### [app.dart](file:///D:/books_flutter/lib/app.dart)
- Initialize `SocketService` and connect it to all relevant ViewModels.

---

### [Flutter] Real-time UI Updates

Listen to WebSocket events and update the app's state immediately without requiring a manual refresh.

#### [pubspec.yaml](file:///D:/books_flutter/pubspec.yaml)
- Add `socket_io_client` to dependencies.

#### [NEW] [services/socket_service.dart](file:///D:/books_flutter/lib/services/socket_service.dart)
- Implement a service to connect to the backend and handle incoming events.

#### [viewmodel/productsVM.dart](file:///D:/books_flutter/lib/viewmodel/productsVM.dart)
- Add methods to handle real-time updates:
    - `onComicCreated(Book book)`: Add to featured/popular lists if applicable.
    - `onComicDeleted(int id)`: Remove from all lists and cart.
    - `onComicUpdated(Book book)`: Update item in lists.

#### [app.dart](file:///D:/books_flutter/lib/app.dart)
- Initialize `SocketService` and connect it to `ProductsVM`.

## Verification Plan

### Automated Tests
- I will verify the backend by simulating product creation/deletion and checking if socket events are emitted (using a test script).
- `npm start` to ensure the backend still runs with Socket.IO.

### Manual Verification
1. **Add Product**:
    - Open the app as a User on one device/simulator and as an Admin on another.
    - Admin adds a product.
    - Verify the product appears on the User's Home and Search screens instantly.
2. **Delete Product**:
    - Admin deletes a product.
    - Verify the product disappears from the User's screen instantly.
3. **Search Verification**:
    - Admin deletes a product.
    - User searches for that product.
    - Verify it no longer appears in standard search results.
4. **Database Verification**:
    - Check the DB directly after an admin action to ensure `is_deleted` is set to `true` (for deletion) or the new row exists (for creation).
