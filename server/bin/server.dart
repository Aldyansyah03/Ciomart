import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import '../lib/repositories/user_repository.dart';
import '../lib/repositories/product_repository.dart';
import '../lib/repositories/category_repository.dart';
import '../lib/repositories/sale_repository.dart';
import '../lib/db_connection.dart';

final userRepository = UserRepository();
final productRepository = ProductRepository();
final categoryRepository = CategoryRepository();
final saleRepository = SaleRepository();

// Middleware for CORS
Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders());
      }
      final response = await innerHandler(request);
      return response.change(headers: _corsHeaders());
    };
  };
}

Map<String, String> _corsHeaders() => {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
    };

Response _jsonResponse(dynamic data, {int status = 200}) {
  return Response(status,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'});
}

void main(List<String> args) async {
  final app = Router();

  // ----- Auth Routes -----
  app.post('/api/auth/login', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final user = await userRepository.login(payload['username'], payload['password']);
    if (user != null) {
      return _jsonResponse({'success': true, 'user': user});
    }
    return _jsonResponse({'success': false, 'message': 'Username atau password salah'}, status: 401);
  });

  app.post('/api/auth/register', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    try {
      final id = await userRepository.save(payload);
      return _jsonResponse({'success': true, 'id': id, 'message': 'User registered successfully'});
    } catch (e) {
      return _jsonResponse({'success': false, 'message': e.toString()}, status: 400);
    }
  });

  // ----- Product Routes -----
  app.get('/api/products', (Request request) async {
    final products = await productRepository.findAll();
    return _jsonResponse(products);
  });

  app.post('/api/products', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final id = await productRepository.save(payload);
    return _jsonResponse({'id': id, 'message': 'Product created'});
  });

  app.put('/api/products/<id>', (Request request, String id) async {
    final payload = jsonDecode(await request.readAsString());
    await productRepository.update(int.parse(id), payload);
    return _jsonResponse({'message': 'Product updated'});
  });

  app.delete('/api/products/<id>', (Request request, String id) async {
    await productRepository.deleteById(int.parse(id));
    return _jsonResponse({'message': 'Product deleted'});
  });

  // ----- Category Routes -----
  app.get('/api/categories', (Request request) async {
    final categories = await categoryRepository.findAll();
    return _jsonResponse(categories);
  });

  app.post('/api/categories', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final id = await categoryRepository.save(payload);
    return _jsonResponse({'id': id, 'message': 'Category created'});
  });

  app.put('/api/categories/<id>', (Request request, String id) async {
    final payload = jsonDecode(await request.readAsString());
    await categoryRepository.update(int.parse(id), payload);
    return _jsonResponse({'message': 'Category updated'});
  });

  app.delete('/api/categories/<id>', (Request request, String id) async {
    await categoryRepository.deleteById(int.parse(id));
    return _jsonResponse({'message': 'Category deleted'});
  });

  // ----- User Routes -----
  app.get('/api/users', (Request request) async {
    final users = await userRepository.findAll();
    return _jsonResponse(users);
  });

  app.post('/api/users', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final id = await userRepository.save(payload);
    return _jsonResponse({'id': id, 'message': 'User created'});
  });

  app.put('/api/users/<id>', (Request request, String id) async {
    final payload = jsonDecode(await request.readAsString());
    await userRepository.update(int.parse(id), payload);
    return _jsonResponse({'message': 'User updated'});
  });

  app.delete('/api/users/<id>', (Request request, String id) async {
    await userRepository.deleteById(int.parse(id));
    return _jsonResponse({'message': 'User deleted'});
  });

  // ----- Sale Routes -----
  app.get('/api/sales', (Request request) async {
    final sales = await saleRepository.findAll();
    return _jsonResponse(sales);
  });

  app.get('/api/sales/<id>', (Request request, String id) async {
    final sale = await saleRepository.findById(int.parse(id));
    if (sale == null) return Response.notFound('Sale not found');
    return _jsonResponse(sale);
  });

  app.post('/api/sales/checkout', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final saleData = payload['sale'] as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(payload['items']);
    
    final id = await saleRepository.saveSale(saleData, items);
    return _jsonResponse({'id': id, 'message': 'Checkout successful'});
  });

  // ----- Dashboard Stats -----
  app.get('/api/dashboard/stats', (Request request) async {
    final stats = await saleRepository.getDashboardStats();
    return _jsonResponse(stats);
  });

  // Setup pipeline with logging and cors
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(app.call);

  // Use port 8082 to avoid conflict with Tomcat on 8081, but support environment variable PORT
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8082;
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Dart API Server listening on port ${server.port}');

  // Shutdown hook
  ProcessSignal.sigint.watch().listen((ProcessSignal signal) async {
    print('Shutting down server...');
    await server.close(force: true);
    await DBConnection.close();
    exit(0);
  });
}
