import 'dart:io';

void main() async {
  // إنشاء السيرفر
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 3000);
  final List<WebSocket> clients = [];

  print('✅ WebSocket server running on ws://${server.address.address}:3000');

  await for (HttpRequest request in server) {
    // التحقق إن كان الطلب من نوع WebSocket
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      handleWebSocket(socket, clients);
    } else {
      // في حال لم يكن الطلب WebSocket
      request.response
        ..statusCode = HttpStatus.forbidden
        ..write('❌ WebSocket connections only.')
        ..close();
    }
  }
}

void handleWebSocket(WebSocket socket, List<WebSocket> clients) {
  print('💬 Client connected');
  clients.add(socket);

  // عند استقبال رسالة من هذا المستخدم
  socket.listen(
        (message) {
      print('📩 Received: $message');
      // إرسال الرسالة لجميع المستخدمين المتصلين
      for (var client in clients) {
        if (client != socket) {
          client.add(message);
        }
      }
    },
    onDone: () {
      print('🚪 Client disconnected');
      clients.remove(socket);
    },
    onError: (error) {
      print('⚠️ Error: $error');
      clients.remove(socket);
    },
  );
}
