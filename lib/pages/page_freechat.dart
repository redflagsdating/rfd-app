import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:red_flags/models/message.dart';
import 'package:red_flags/models/user.dart';
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

  Timer? _throttle;
  DocumentReference<MessageModel>? _textingDocRef;

  void _cancelThrottle() {
    if (_throttle != null) {
      _throttle?.cancel();
      _throttle = null;
    }
  }

  @override
  void dispose() async {
    super.dispose();
    _controller.dispose();
    _cancelThrottle();
    await _textingDocRef?.delete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final messageCollectionRef = messageRef(widget.connectionId);
    final displayName = widget.userModel.displayName ?? l10n!.unknown;

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
        actions: [
          Semantics(
            button: true,
            label: l10n!.pgFreeChatActionMoreLabel(displayName),
            child: IconButton(
              icon: const Icon(Icons.more_vert_outlined),
              onPressed: () {
                // TODO: More actions such as remove connection
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
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
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final snapshot = docs.elementAtOrNull(index);

                      return snapshot != null
                          ? CardFreechatMessage(
                              message: snapshot.data(),
                            )
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

                      if (isMine && message.content == null) {
                        return const SizedBox.shrink();
                      }

                      if (isCrossedDays) {
                        final label = distance == 0
                            ? l10n.today
                            : distance == 1
                                ? l10n.yesterday
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
                        // TODO: Dynamic type
                        "type": 'text',
                        "createdAt": DateTime.now(),
                      },
                    );

                    _textingDocRef = null;
                  } else {
                    await messageCollectionRef.add(
                      MessageModel(
                        uid: userProvider.getIdCache(),
                        createdAt: DateTime.now(),
                        // TODO: Dynamic type
                        type: MessageType.text,
                        content: _controller.text,
                      ),
                    );
                  }

                  _controller.clear();
                },
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  hintText: l10n.message,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  suffixIcon: InkWell(
                    onTap: () {
                      // TODO: Support image insertion
                    },
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
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
