import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/app_logger.dart';
import '../../../services/s3_upload_service.dart';
import '../../../services/ticket_service.dart';

class TicketSupportSheet extends StatefulWidget {
  final String token;
  const TicketSupportSheet({super.key, required this.token});

  @override
  State<TicketSupportSheet> createState() => _TicketSupportSheetState();
}

class _TicketSupportSheetState extends State<TicketSupportSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _picker = ImagePicker();

  String _category = 'general';
  bool _loading = false;
  bool _uploading = false;
  bool _showForm = false;
  bool _loadingTickets = true;
  String? _errorMessage;
  List<String> _attachments = [];
  List<XFile> _selectedFiles = [];
  List<dynamic> _tickets = [];

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatTimeForUsers(String raw) {
    if (raw.trim().isEmpty) return 'Time not available';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'Time not available';

    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(local.year, local.month, local.day);

    final hour24 = local.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final ampm = hour24 >= 12 ? 'PM' : 'AM';
    final time = '$hour12:${_twoDigits(local.minute)} $ampm';

    if (dateOnly == today) {
      return 'Today, $time';
    }
    if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $time';
    }

    return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year}, $time';
  }

  String _timeAgo(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} day ago';
    final weeks = (diff.inDays / 7).floor();
    return '$weeks week ago';
  }

  int _ticketAttachmentCount(Map<String, dynamic> ticket) {
    final keys = ['attachments', 'attachmentUrls', 'images', 'files'];
    for (final key in keys) {
      final value = ticket[key];
      if (value is List) {
        final count = value.where((e) => e != null).length;
        if (count > 0) return count;
      }
    }
    return 0;
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase().trim();
    if (normalized == 'resolved' || normalized == 'closed') {
      return const Color(0xFF059669);
    }
    if (normalized == 'in_progress' || normalized == 'in progress') {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF2563EB);
  }

  String _statusLabel(String status) {
    if (status.trim().isEmpty) return 'Open';
    final s = status.replaceAll('_', ' ').trim();
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  String _resolveTicketStatus(Map<String, dynamic> ticket) {
    final candidates = [
      ticket['status'],
      ticket['ticketStatus'],
      ticket['currentStatus'],
      ticket['adminStatus'],
      (ticket['admin'] is Map<String, dynamic>)
          ? (ticket['admin'] as Map<String, dynamic>)['status']
          : null,
    ];

    for (final value in candidates) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty) return text;
    }
    return 'open';
  }

  String? _resolveAdminResponse(Map<String, dynamic> ticket) {
    final admin = ticket['admin'];
    final candidates = [
      ticket['latestAdminNote'],
      ticket['adminNote'],
      ticket['adminResponse'],
      ticket['adminReply'],
      ticket['response'],
      ticket['reply'],
      ticket['resolutionNote'],
      ticket['supportReply'],
      ticket['note'],
      admin is Map<String, dynamic> ? admin['response'] : null,
      admin is Map<String, dynamic> ? admin['reply'] : null,
      admin is Map<String, dynamic> ? admin['latestAdminNote'] : null,
      admin is Map<String, dynamic> ? admin['adminNote'] : null,
      admin is Map<String, dynamic> ? admin['comment'] : null,
      admin is Map<String, dynamic> ? admin['message'] : null,
    ];

    for (final value in candidates) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
  }

  String _resolveDisplayTime(Map<String, dynamic> ticket) {
    final candidates = [
      ticket['updatedAt'],
      ticket['resolvedAt'],
      ticket['lastUpdatedAt'],
      ticket['createdAt'],
    ];
    for (final value in candidates) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _mimeTypeFromFilename(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'heic':
      case 'heif':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _loadingTickets = true;
      _errorMessage = null;
    });

    final result = await TicketService.fetchMyTickets(widget.token);
    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      final list = data is List
          ? data
          : (data is Map<String, dynamic>
                ? (data['tickets'] ?? data['data'] ?? [])
                : (result['tickets'] ?? []));
      setState(() {
        _tickets = list is List ? list : [];
        _loadingTickets = false;
      });
      return;
    }

    setState(() {
      _errorMessage = result['message']?.toString();
      _loadingTickets = false;
    });
  }

  Future<void> _pickImages() async {
    if (_selectedFiles.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can add up to 2 attachments only.')),
      );
      return;
    }

    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    setState(() {
      _selectedFiles.addAll(picked.take(2 - _selectedFiles.length));
    });
  }

  Future<void> _uploadSelectedFiles() async {
    if (_selectedFiles.isEmpty) return;
    setState(() => _uploading = true);
    final uploadedUrls = <String>[];

    for (final file in _selectedFiles) {
      final bytes = await file.readAsBytes();
      final fileName = file.name;
      final mimeType = file.mimeType ?? _mimeTypeFromFilename(fileName);
      final uploadedUrl = await S3UploadService.upload(
        bytes: bytes,
        filename: fileName,
        contentType: mimeType,
      );

      if (uploadedUrl != null) {
        uploadedUrls.add(uploadedUrl);
      }
    }

    setState(() {
      _attachments = uploadedUrls;
      _uploading = false;
    });
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFiles.isNotEmpty && _attachments.isEmpty) {
      await _uploadSelectedFiles();
      if (!mounted) return;
      if (_attachments.isEmpty && _selectedFiles.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attachment upload failed. Please try again.'),
          ),
        );
        return;
      }
    }

    setState(() => _loading = true);
    final payload = {
      'subject': _subjectController.text.trim(),
      'message': _messageController.text.trim(),
      'category': _category,
      'attachments': _attachments,
      'selectedFileNames': _selectedFiles.map((f) => f.name).toList(),
    };
    await AppLogger.instance.info(
      'ticket_create_payload',
      message: 'Submitting support ticket',
      data: {
        'subject': payload['subject'],
        'category': payload['category'],
        'attachmentCount': (_attachments).length,
        'selectedFileNames': payload['selectedFileNames'],
      },
    );
    final result = await TicketService.createTicket(
      token: widget.token,
      subject: payload['subject']! as String,
      message: payload['message']! as String,
      category: _category,
      attachments: _attachments,
    );

    setState(() => _loading = false);

    if (!mounted) return;
    if (result['success'] == true) {
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _showForm = false;
        _selectedFiles = [];
        _attachments = [];
      });
      await _loadTickets();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket created successfully.')),
      );
    } else {
      await AppLogger.instance.error(
        'ticket_create_failed',
        message: 'Ticket create failed in UI layer',
        data: {
          'subject': payload['subject'],
          'category': payload['category'],
          'attachmentCount': _attachments.length,
          'selectedFileNames': payload['selectedFileNames'],
          'serverMessage': result['message']?.toString(),
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Failed to create ticket',
          ),
        ),
      );
    }
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final subject = (ticket['subject'] ?? ticket['title'] ?? 'Support request')
        .toString();
    final message = (ticket['message'] ?? ticket['description'] ?? '')
        .toString();
    final category = (ticket['category'] ?? 'general').toString();
    final status = _resolveTicketStatus(ticket);
    final adminResponse = _resolveAdminResponse(ticket);
    final createdAt = _resolveDisplayTime(ticket);
    final statusColor = _statusColor(status);
    final prettyStatus = _statusLabel(status);
    final attachmentCount = _ticketAttachmentCount(ticket);
    final formattedTime = _formatTimeForUsers(createdAt);
    final ago = _timeAgo(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  prettyStatus,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.category_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                category,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const Spacer(),
              Icon(
                attachmentCount > 0
                    ? Icons.attach_file_rounded
                    : Icons.link_off,
                size: 16,
                color: attachmentCount > 0
                    ? const Color(0xFF2563EB)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                attachmentCount > 0
                    ? '$attachmentCount attachment${attachmentCount > 1 ? 's' : ''}'
                    : 'No attachment',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: attachmentCount > 0
                      ? const Color(0xFF1D4ED8)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, height: 1.3),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: adminResponse == null
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.12)
                  : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: adminResponse == null
                    ? Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2)
                    : const Color(0xFFBBF7D0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  adminResponse == null
                      ? Icons.hourglass_bottom_rounded
                      : Icons.support_agent_rounded,
                  size: 16,
                  color: adminResponse == null
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : const Color(0xFF047857),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Response',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: adminResponse == null
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : const Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adminResponse ?? 'Not updated yet',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: adminResponse == null
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (ago.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  '($ago)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: _showForm
            ? Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => setState(() => _showForm = false),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Expanded(
                          child: Text(
                            'Create Ticket',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      validator: (value) =>
                          (value ?? '').trim().isEmpty ? 'Enter subject' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(
                          value: 'general',
                          child: Text('General'),
                        ),
                        DropdownMenuItem(
                          value: 'payment',
                          child: Text('Payment'),
                        ),
                        DropdownMenuItem(
                          value: 'account',
                          child: Text('Account'),
                        ),
                        DropdownMenuItem(
                          value: 'technical',
                          child: Text('Technical'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _category = value ?? 'general'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Describe your issue',
                      ),
                      validator: (value) =>
                          (value ?? '').trim().isEmpty ? 'Enter message' : null,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _uploading ? null : _pickImages,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Add attachment (max 2)'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedFiles.isEmpty
                          ? 'No attachment selected'
                          : '${_selectedFiles.length} attachment selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: _selectedFiles.isEmpty
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : const Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_selectedFiles.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedFiles
                            .map((file) => Chip(label: Text(file.name)))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading || _uploading
                            ? null
                            : _submitTicket,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Ticket'),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Support',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your recent support requests',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _showForm = true),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Create new ticket'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _loadingTickets
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _errorMessage != null
                        ? SingleChildScrollView(child: Text(_errorMessage!))
                        : _tickets.isEmpty
                        ? const Text(
                            'No tickets yet. Create one to get started.',
                          )
                        : ListView.builder(
                            itemCount: _tickets.length,
                            itemBuilder: (context, index) {
                              final ticket = _tickets[index];
                              if (ticket is! Map<String, dynamic>) {
                                return const SizedBox.shrink();
                              }
                              return _buildTicketCard(ticket);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
