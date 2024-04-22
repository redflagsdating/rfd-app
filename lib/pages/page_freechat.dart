import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/message.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/card/card_freechat_message.dart';
import 'package:red_flags/widgets/circle_avatar_user.dart';

class PageFreeChat extends StatefulWidget {
  const PageFreeChat({
    super.key,
    required this.userModel,
    required this.connectionId,
  });

  final UserModel userModel;
  final String connectionId;

  @override
  State<PageFreeChat> createState() => _PageFreeChatState();
}

class _PageFreeChatState extends State<PageFreeChat> {
  final _form = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _imgPicker = ImagePicker();
  final List<XFile?> _imgFiles = [];

  bool _sending = false;
  Timer? _throttle;
  DocumentReference<MessageModel>? _textingDocRef;

  void _cancelThrottle() {
    if (_throttle != null) {
      _throttle?.cancel();
      _throttle = null;
    }
  }

  Future<void> _sendImage() async {
    if (_imgFiles.isNotEmpty) {
      final userProvider = context.read<UserProvider>();
      final logger = context.read<LoggerProvider>().logger;
      final newImgRef = context
          .read<FireStorageProvider>()
          .newImgStorageForRef(widget.connectionId);

      setState(() {
        _sending = true;
      });

      await Future.wait(
        _imgFiles.map(
          (file) async {
            if (file != null) {
              try {
                // Create new message document to show transition placeholder
                final newMsgDocRef = await messageRef(widget.connectionId).add(
                  MessageModel(
                    uid: userProvider.getIdCache(),
                    createdAt: DateTime.now(),
                    type: MessageType.image,
                  ),
                );

                // Upload image file
                await newImgRef.putFile(
                  File(file.path),
                  SettableMetadata(
                    contentType: file.mimeType ?? lookupMimeType(file.path),
                  ),
                );

                // Update image url into message content
                await newMsgDocRef.update({
                  "content": newImgRef.fullPath,
                });
              } catch (e) {
                logger.e(e, time: DateTime.now());

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              } finally {
                _scrollCtrl.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            }
          },
        ),
      );

      _imgFiles.clear();
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  void dispose() async {
    super.dispose();
    _controller.dispose();
    _cancelThrottle();
    _scrollCtrl.dispose();
    await _textingDocRef?.delete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final messageCollectionRef = messageRef(widget.connectionId);

    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          button: true,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatarUser(
              photoUrl: widget.userModel.photoUrl,
              size: 40,
            ),
            const SizedBox(width: 6),
            Text(
              widget.userModel.displayName ?? l10n!.unknown,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        // TODO: Add more actions later
        // actions: [
        //   Semantics(
        //     button: true,
        //     label: l10n!.pgFreeChatActionMoreLabel(displayName),
        //     child: IconButton(
        //       icon: const Icon(Icons.more_vert_outlined),
        //       onPressed: () {
        //         // TODO: More actions such as remove connection
        //       },
        //     ),
        //   )
        // ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: messageCollectionRef
                    .orderBy(MessageFields.createdAt.name, descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs;

                  if (docs == null || docs.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: docs.length + 1,
                    controller: _scrollCtrl,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final snapshot = docs.elementAtOrNull(index);

                      return snapshot != null
                          ? CardFreechatMessage(message: snapshot.data())
                          : null;
                    },
                    separatorBuilder: (context, index) {
                      final message = docs.elementAt(index).data();
                      final currentDay = DateTime.now().day;
                      final msgDay = message.createdAt.day;
                      final distance = currentDay - msgDay;

                      final nextSnapshot = docs.elementAtOrNull(index + 1);
                      final nextMsgDay = nextSnapshot != null
                          ? nextSnapshot.data().createdAt.day
                          : 0;
                      final isCrossedDays = msgDay - nextMsgDay >= 1;
                      final isMine = message.uid == userProvider.getIdCache();

                      if (isMine &&
                          message.content == null &&
                          message.type == MessageType.text) {
                        return const SizedBox.shrink();
                      }

                      if (isCrossedDays) {
                        final label = distance == 0
                            ? l10n!.today
                            : distance == 1
                                ? l10n!.yesterday
                                : distance <= 7
                                    ? DateFormat.EEEE(Platform.localeName)
                                        .format(message.createdAt)
                                    : DateFormat.yMMMMd(Platform.localeName)
                                        .format(message.createdAt);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    label,
                                    semanticsLabel: label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox(height: 4);
                    },
                  );
                },
              ),
            ),
            Form(
              key: _form,
              child: TextFormField(
                controller: _controller,
                style: const TextStyle(
                  fontFamily: '',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  if (value.isEmpty) {
                    return;
                  }

                  _cancelThrottle();

                  _throttle = Timer(
                    const Duration(milliseconds: 300),
                    () async {
                      // Initialize a new message to notify typing state
                      // (i.e. showing typing animation)
                      _textingDocRef ??= await messageCollectionRef.add(
                        MessageModel(
                          uid: userProvider.getIdCache(),
                          createdAt: DateTime.now(),
                          type: MessageType.text,
                        ),
                      );
                    },
                  );
                },
                onTapOutside: (event) async {
                  _cancelThrottle();

                  // Delete the message document if it is abandoned
                  if (_controller.text.isEmpty && _textingDocRef != null) {
                    await _textingDocRef!.delete();
                    _textingDocRef = null;
                  }
                },
                onFieldSubmitted: (value) async {
                  if (!_form.currentState!.validate() || value.isEmpty) {
                    return;
                  }

                  _cancelThrottle();

                  if (_textingDocRef != null) {
                    await _textingDocRef!.update(
                      {
                        "content": _controller.text,
                        "createdAt": DateTime.now(),
                      },
                    );

                    _textingDocRef = null;
                  } else {
                    await messageCollectionRef.add(
                      MessageModel(
                        uid: userProvider.getIdCache(),
                        createdAt: DateTime.now(),
                        type: MessageType.text,
                        content: value.trim(),
                      ),
                    );
                  }

                  _controller.clear();
                  _scrollCtrl.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  hintText: l10n!.message,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                      left: 2,
                      bottom: 2,
                      right: 6,
                    ),
                    child: IconButton.filled(
                      icon: Icon(
                        Icons.photo_camera,
                        size: 28,
                        color: theme.colorScheme.onPrimary,
                      ),
                      onPressed: _sending
                          ? null
                          : () async {
                              _imgFiles.add(
                                await _imgPicker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 20,
                                ),
                              );

                              await _sendImage();
                            },
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.image,
                      size: 28,
                      color: _sending ? null : theme.colorScheme.primary,
                    ),
                    onPressed: _sending
                        ? null
                        : () async {
                            _imgFiles.addAll(await _imgPicker.pickMultiImage(
                              imageQuality: 20,
                            ));

                            await _sendImage();
                          },
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
