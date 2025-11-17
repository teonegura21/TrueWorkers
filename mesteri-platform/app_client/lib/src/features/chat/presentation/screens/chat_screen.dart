import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';
import 'package:app_client/src/features/jobs/presentation/screens/jobs_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _attachmentDisclaimerAccepted = false;
  // Anti-parasire
  final bool _escrowActive = false; // TODO: wire real status
  bool _policyViolation = false; // Local rate limit
  int _sentCount = 0;
  DateTime _windowStart = DateTime.now();
  final Duration _rateWindow = const Duration(seconds: 10);
  final int _rateMax = 5;
  bool _cooldownActive = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  // Mock messages data
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text':
          'Bună ziua! Sunt interesat de lucrarea dumneavoastră de reparații sanitare.',
      'sender': 'other',
      'timestamp': '14:30',
      'isRead': true,
    },
    {
      'id': '2',
      'text':
          'Bine ați venit! Da, pot ajuta cu această lucrare. Aveți deja un buget estimat?',
      'sender': 'me',
      'timestamp': '14:32',
      'isRead': true,
    },
    {
      'id': '3',
      'text':
          'Da, bugetul este între 800-1200 RON. Lucrarea trebuie făcută urgent.',
      'sender': 'other',
      'timestamp': '14:35',
      'isRead': true,
    },
    {
      'id': '4',
      'text':
          'Perfect! Pot veni mâine dimineața pentru o inspecție. Aveți nevoie și de materiale?',
      'sender': 'me',
      'timestamp': '14:37',
      'isRead': true,
    },
    {
      'id': '5',
      'text':
          'Da, materialele sunt incluse în buget. Aștept cu interes oferta dumneavoastră!',
      'sender': 'other',
      'timestamp': '14:40',
      'isRead': true,
    },
    {
      'id': '6',
      'text': 'Am înțeles. Vă trimit oferta mea în câteva minute.',
      'sender': 'me',
      'timestamp': '14:42',
      'isRead': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    _messageController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleInputChanged);
    _cooldownTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    final v = _detectPolicyViolation(_messageController.text);
    if (v != null && !_escrowActive) {
      _policyViolation = true;
    } else {
      _policyViolation = false;
    }
    setState(() {});
  }

  String? _detectPolicyViolation(String text) {
    final lower = text.toLowerCase();
    final keywordHit = [
      'whatsapp',
      'telefon',
      'cash',
      'revolut',
      'telegram',
      'numar',
      'număr',
      'email',
      'mail',
      'link',
    ].any((k) => lower.contains(k));
    final phoneRe = RegExp(r"(?:\+?4?0)?(?:(?:7\d{8})|(?:\d[\s\-\.]?){9,})");
    final emailRe = RegExp(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}");
    final urlRe = RegExp(
      r"(?:https?:\/\/|www\.)[\w\-]+(\.[\w\-]+)+[\w\-.,@?^=%&:/~+#]*",
    );
    if (keywordHit ||
        phoneRe.hasMatch(text) ||
        emailRe.hasMatch(text) ||
        urlRe.hasMatch(text)) {
      return 'Evită datele de contact până la escrow. Comunicarea rămâne în platformă pentru protecție.';
    }
    return null;
  }

  bool _canSend(String text) {
    if (!_escrowActive) {
      final v = _detectPolicyViolation(text);
      if (v != null) {
        _policyViolation = true;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v)));
        setState(() {});
        return false;
      }
    }
    final now = DateTime.now();
    if (now.difference(_windowStart) > _rateWindow) {
      _windowStart = now;
      _sentCount = 0;
    }
    if (_sentCount >= _rateMax) {
      _startCooldown(8);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ai trimis prea multe mesaje. Încearcă din nou în câteva secunde.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  void _startCooldown(int seconds) {
    _cooldownActive = true;
    _cooldownSeconds = seconds;
    setState(() {});
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      _cooldownSeconds--;
      if (_cooldownSeconds <= 0) {
        _cooldownActive = false;
        t.cancel();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryLowOpacity,
              child: Icon(Icons.person, size: 20, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ion Popescu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Online acum',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.successColor),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showChatOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat header with job info
          _buildChatHeader(),

          // Messages list
          Expanded(child: _buildMessagesList()),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryVeryLowOpacity,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLowOpacity,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.work,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reparații instalații sanitare',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ofertă trimisă • 15 Dec 2024',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const JobsScreen()));
            },
            child: const Text('Vezi Detalii'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message['sender'] == 'me';
        final isLast = index == _messages.length - 1;

        return Column(
          children: [
            _buildMessageBubble(message, isMe),
            if (isLast &&
                message['sender'] == 'me' &&
                !(message['isRead'] as bool))
              _buildMessageStatus(message),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.68;
    return Container(
      margin: EdgeInsets.only(
        top: 8,
        bottom: 4,
        left: isMe ? 60 : 0,
        right: isMe ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryLowOpacity,
              child: Icon(Icons.person, size: 16, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.primaryColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  message['text'] as String,
                  softWrap: true,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 48,
            child: Text(
              message['timestamp'] as String,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(top: 4, left: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Livrat',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.onSurfaceSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.check, size: 12, color: AppTheme.onSurfaceSecondary),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double safeInset = (bottomInset).clamp(0.0, 32.0);
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + safeInset),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: Row(
          children: [
            // Attachment button
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () async {
                if (!_attachmentDisclaimerAccepted) {
                  final accepted = await _showAttachmentDisclaimer();
                  if (accepted != true) return;
                  setState(() => _attachmentDisclaimerAccepted = true);
                }
                _showAttachmentOptions();
              },
            ),

            // Message input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Scrie un mesaj...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    final t = value.trim();
                    if (t.isEmpty) return;
                    if (_canSend(t)) _sendMessage(t);
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  if (_isSending ||
                      _cooldownActive ||
                      (_policyViolation && !_escrowActive)) {
                    return;
                  }
                  final text = _messageController.text.trim();
                  if (text.isEmpty) return;
                  if (_canSend(text)) _sendMessage(text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) async {
    setState(() {
      _isSending = true;
    });

    // Simulate sending message
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _sentCount += 1;
        _messages.add({
          'id': DateTime.now().toString(),
          'text': text,
          'sender': 'me',
          'timestamp':
              '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          'isRead': false,
        });
        _isSending = false;
        _messageController.clear();
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Opțiuni Chat',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildChatOption(
                icon: Icons.block,
                title: 'Blochează utilizator',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Utilizator blocat')),
                  );
                },
              ),
              _buildChatOption(
                icon: Icons.report,
                title: 'Raportează',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conversație raportată')),
                  );
                },
              ),
              _buildChatOption(
                icon: Icons.delete,
                title: 'Șterge conversația',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conversație ștearsă')),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Anulează'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryLowOpacity,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      onTap: onTap,
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Atașamente',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.image,
                    label: 'Galerie',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selectare imagine din galerie'),
                        ),
                      );
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.camera_alt,
                    label: 'Cameră',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Captură foto')),
                      );
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.document_scanner,
                    label: 'Document',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selectare document')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Anulează'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showAttachmentDisclaimer() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atenție atașamente'),
        content: const Text(
          'Trimite doar conținut relevant proiectului. Evită datele de contact (telefon, email, linkuri). Toate tranzacțiile și comunicarea trebuie să rămână în platformă pentru protecția escrow și soluționarea disputelor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sunt de acord'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryLowOpacity,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
