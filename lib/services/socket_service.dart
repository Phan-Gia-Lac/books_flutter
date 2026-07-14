import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';
import '../models/data_model.dart';
import '../viewmodel/productsVM.dart';
import '../viewmodel/adminVM.dart';
import '../viewmodel/authVM.dart';

class SocketService {
  IO.Socket? socket;
  final ProductsVM productsVM;
  final AdminVM adminVM;
  final AuthVM authVM;

  // SocketService(this.productsVM, this.adminVM);

  SocketService(this.productsVM, this.adminVM, this.authVM);

  void connect() {
    // Get the same base URL as ApiService but for websockets
    String baseUrl = ApiService.baseUrl.replaceAll('/api', '');
    
    socket = IO.io(baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    socket!.connect();

    socket!.onConnect((_) {
      print('Connected to Socket.IO backend');
    });

    socket!.on('COMIC_CREATED', (data) {
      final book = Book.fromJson(data);
      productsVM.onComicCreated(book);
      adminVM.onComicCreated(book);
    });

    socket!.on('COMIC_UPDATED', (data) {
      final book = Book.fromJson(data);
      productsVM.onComicUpdated(book);
      adminVM.onComicUpdated(book);
    });

    socket!.on('COMIC_DELETED', (id) {
      productsVM.onComicDeleted(id);
      adminVM.onComicDeleted(id);
    });

    socket!.on('ORDER_CREATED', (data) {
      adminVM.onOrderCreated(data);
      authVM.onOrderCreated(data);
    });

    socket!.on('ORDER_STATUS_UPDATED', (data) {
      adminVM.onOrderStatusUpdated(data);
      authVM.onOrderStatusUpdated(data);
    });

    socket!.onDisconnect((_) => print('Disconnected from Socket.IO backend'));
  }

  void dispose() {
    socket?.dispose();
  }
}
