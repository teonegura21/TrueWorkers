import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';
import 'firebase_service.dart';

/// Real-time WebSocket Service for messaging
/// 
/// Features:
/// - Real-time messaging with Socket.IO
/// - Auto-reconnection
/// - Authentication with Firebase token
/// - Typing indicators
/// - Read receipts
class WebSocketService extends ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _currentProjectId;
  
  // Event callbacks
  final Map<String, List<Function(dynamic)>> _eventListeners = {};
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get currentProjectId => _currentProjectId;
  
  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      debugPrint('🔌 Already connected or connecting');
      return;
    }
    
    _isConnecting = true;
    notifyListeners();
    
    try {
      // Get Firebase auth token
      final token = await firebaseService.getIdToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }
      
      // Create socket connection
      final wsUrl = AppConfig.apiBaseUrl.replaceAll('http', 'ws');
      
      _socket = IO.io(
        '$wsUrl/messages',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(10)
            .setAuth({'token': token})
            .setExtraHeaders({'authorization': 'Bearer $token'})
            .build(),
      );
      
      _setupSocketListeners();
      
      debugPrint('🔌 Connecting to WebSocket...');
    } catch (e) {
      _isConnecting = false;
      debugPrint('❌ WebSocket connection failed: $e');
      notifyListeners();
      rethrow;
    }
  }
  
  /// Setup socket event listeners
  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      debugPrint('✅ WebSocket connected');
      notifyListeners();
    });
    
    _socket?.onDisconnect((_) {
      _isConnected = false;
      debugPrint('🔌 WebSocket disconnected');
      notifyListeners();
    });
    
    _socket?.onConnectError((error) {
      _isConnecting = false;
      debugPrint('❌ WebSocket connection error: $error');
      notifyListeners();
    });
    
    _socket?.onError((error) {
      debugPrint('❌ WebSocket error: $error');
    });
    
    _socket?.onReconnect((attempt) {
      debugPrint('🔄 WebSocket reconnecting (attempt $attempt)...');
    });
    
    _socket?.onReconnectAttempt((attempt) {
      debugPrint('🔄 WebSocket reconnect attempt $attempt');
    });
    
    // Setup custom message listeners
    _socket?.on('new-message', (data) {
      debugPrint('💬 New message received: $data');
      _emitToListeners('new-message', data);
    });
    
    _socket?.on('message-sent', (data) {
      debugPrint('✅ Message sent confirmation: $data');
      _emitToListeners('message-sent', data);
    });
    
    _socket?.on('user-typing', (data) {
      debugPrint('⌨️ User typing: $data');
      _emitToListeners('user-typing', data);
    });
    
    _socket?.on('messages-read', (data) {
      debugPrint('👁️ Messages read: $data');
      _emitToListeners('messages-read', data);
    });
    
    _socket?.on('joined-project', (data) {
      debugPrint('✅ Joined project: $data');
      _emitToListeners('joined-project', data);
    });
    
    _socket?.on('error', (data) {
      debugPrint('❌ Socket error event: $data');
      _emitToListeners('error', data);
    });
  }
  
  /// Join a project room for real-time messaging
  Future<void> joinProject(String projectId) async {
    if (!_isConnected) {
      await connect();
    }
    
    _currentProjectId = projectId;
    _socket?.emit('join-project', {'projectId': projectId});
    debugPrint('🚪 Joining project room: $projectId');
  }
  
  /// Leave current project room
  void leaveProject() {
    if (_currentProjectId != null) {
      _socket?.emit('leave-project');
      debugPrint('🚪 Left project room: $_currentProjectId');
      _currentProjectId = null;
    }
  }
  
  /// Send a message
  void sendMessage({
    required String projectId,
    required String receiverId,
    required String content,
    String? messageType,
    List<dynamic>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isConnected) {
      debugPrint('❌ Cannot send message: Not connected');
      return;
    }
    
    final messageData = {
      'projectId': projectId,
      'receiverId': receiverId,
      'content': content,
      if (messageType != null) 'messageType': messageType,
      if (attachments != null) 'attachments': attachments,
      if (metadata != null) 'metadata': metadata,
    };
    
    _socket?.emit('send-message', messageData);
    debugPrint('📤 Sending message: $content');
  }
  
  /// Send typing indicator
  void sendTypingStart(String projectId) {
    if (!_isConnected) return;
    _socket?.emit('typing-start', {'projectId': projectId});
  }
  
  /// Stop typing indicator
  void sendTypingStop() {
    if (!_isConnected) return;
    _socket?.emit('typing-stop');
  }
  
  /// Mark messages as read
  void markAsRead(String projectId) {
    if (!_isConnected) return;
    _socket?.emit('mark-as-read', {'projectId': projectId});
    debugPrint('👁️ Marking messages as read for project: $projectId');
  }
  
  /// Add event listener
  void addEventListener(String event, Function(dynamic) callback) {
    if (!_eventListeners.containsKey(event)) {
      _eventListeners[event] = [];
    }
    _eventListeners[event]!.add(callback);
    debugPrint('➕ Added listener for event: $event');
  }
  
  /// Remove event listener
  void removeEventListener(String event, Function(dynamic) callback) {
    _eventListeners[event]?.remove(callback);
    debugPrint('➖ Removed listener for event: $event');
  }
  
  /// Emit to all registered listeners
  void _emitToListeners(String event, dynamic data) {
    final listeners = _eventListeners[event];
    if (listeners != null) {
      for (var callback in listeners) {
        try {
          callback(data);
        } catch (e) {
          debugPrint('❌ Error in event listener for $event: $e');
        }
      }
    }
  }
  
  /// Disconnect from WebSocket
  void disconnect() {
    leaveProject();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _isConnecting = false;
    debugPrint('🔌 WebSocket disconnected');
    notifyListeners();
  }
  
  @override
  void dispose() {
    disconnect();
    _eventListeners.clear();
    super.dispose();
  }
}

/// Global WebSocket service instance
final webSocketService = WebSocketService();
