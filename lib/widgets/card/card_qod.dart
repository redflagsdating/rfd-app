import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_qod.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/qod_answer.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/circle_avatar_user.dart';

class CardQod extends StatefulWidget {
  const CardQod({
    super.key,
    required this.userModel,
    required this.qodSnapshot,
    this.onTap,
  });

  final UserModel userModel;
  final QueryDocumentSnapshot<QodModel> qodSnapshot;
  final void Function()? onTap;

  @override
  State<CardQod> createState() => _CardQodState();
}

class _CardQodState extends State<CardQod> with MixinQod {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final qodModel = widget.qodSnapshot.data();
    final userProvider = Provider.of<UserProvider>(context);
    final myUid = userProvider.getIdCache();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 2,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      qodModel.question,
                      maxLines: 2,
                      semanticsLabel: qodModel.question,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder(
                    stream:
                        qodAnswerRef(widget.qodSnapshot.reference).snapshots(),
                    builder: (context, snapshot) {
                      final qodStatus = getQodStatus(snapshot.data);

                      return qodStatus != QodStatus.unanswered
                          ? Row(
                              children: [
                                const Spacer(),
                                if (!isAwaitingByThem(snapshot.data, myUid))
                                  CircleAvatarUser(
                                    photoUrl: userProvider.getPhotoUrlCache(),
                                    size: 40,
                                  ),
                                if (qodStatus == QodStatus.answered)
                                  const SizedBox(width: 6),
                                if (!isAwaitingByYou(snapshot.data, myUid))
                                  CircleAvatarUser(
                                    photoUrl: widget.userModel.photoUrl,
                                    size: 40,
                                  ),
                              ],
                            )
                          : const SizedBox(height: 40);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 18,
          right: 20,
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        if (isQodNew(qodModel))
          Positioned(
            top: -20,
            left: 20,
            child: Chip(
              padding: const EdgeInsets.all(0),
              label: Text(l10n!.labelNew),
              labelStyle: theme.textTheme
                  .apply(bodyColor: theme.colorScheme.onSecondary)
                  .labelSmall,
              visualDensity: VisualDensity.compact,
              side: MaterialStateBorderSide.resolveWith((states) {
                return const BorderSide(color: Colors.transparent);
              }),
              color: MaterialStateProperty.resolveWith(
                (states) {
                  return theme.colorScheme.secondary;
                },
              ),
            ),
          ),
      ],
    );
  }
}
