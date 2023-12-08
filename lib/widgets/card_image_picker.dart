import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_file.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/animation/fade_through_transition_switcher.dart';

class CardImagePicker extends StatefulWidget {
  const CardImagePicker({
    Key? key,
    this.imageRef,
    required this.size,
    required this.enabled,
  }) : super(key: key);

  final double size;
  final bool enabled;
  final Reference? imageRef;

  @override
  State<CardImagePicker> createState() => _CardImagePickerState();
}

class _CardImagePickerState extends State<CardImagePicker> with MixinFile {
  File? _file;
  XFile? _xFile;
  Reference? _imageRef;
  bool _uploading = false;
  bool _deleting = false;

  final _picker = ImagePicker();
  late Logger _logger;
  late FireStorageProvider _fireStorage;

  void setUploading(bool value) {
    setState(() {
      _uploading = value;
    });
  }

  void setDeleting(bool value) {
    setState(() {
      _deleting = value;
    });
  }

  Future<void> _setSpotlightPhoto() async {
    await context.read<UserProvider>().setPhotoUrl(
          _imageRef!.fullPath,
          localOnly: false,
          silent: false,
        );

    // Async write to app doc directory as no dependency
    _imageRef!
        .writeToFile(await createFileObject(_imageRef?.fullPath as String));
  }

  Future<bool> _isSpotlightPhoto() async {
    return await (context.read<UserProvider>().getPhotoUrl()) ==
        _imageRef!.fullPath;
  }

  Future<void> _delete() async {
    final isPrimary = await _isSpotlightPhoto();

    setDeleting(true);

    await _imageRef!.delete();
    await _file?.delete();

    // Ensure to delete cache version in application document directory
    final file = await createFileObject(_imageRef?.fullPath as String);

    if (file.existsSync()) {
      await file.delete();
    }

    _file = null;
    _xFile = null;
    _imageRef = null;

    if (isPrimary) {
      // ignore: use_build_context_synchronously
      await context.read<UserProvider>().setPhotoUrl(
            '',
            localOnly: false,
            silent: false,
          );
    }

    setDeleting(false);
  }

  Future<void> _download() async {
    if (widget.imageRef == null) {
      return;
    }

    _imageRef = widget.imageRef;
    _file = await createFileObject(_imageRef?.fullPath as String);

    final downloadTask = widget.imageRef!.writeToFile(_file!);
    downloadTask.snapshotEvents.listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          // TODO: Handle this case.
          break;
        case TaskState.paused:
          // TODO: Handle this case.
          break;
        case TaskState.success:
          _xFile = XFile(_file!.path);
          setState(() {});

          break;
        case TaskState.canceled:
          // TODO: Handle this case.
          break;
        case TaskState.error:
          // TODO: Handle this case.

          break;
      }
    });
  }

  Future<void> _crop() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (_xFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _xFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l10n!.cardImagePickerCropTitle,
            lockAspectRatio: false,
            hideBottomControls: true,
            toolbarColor: theme.colorScheme.primary,
            statusBarColor: theme.colorScheme.primary,
            toolbarWidgetColor: theme.colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.original,
          ),
          IOSUiSettings(
            title: l10n.cardImagePickerCropTitle,
            rotateButtonsHidden: true,
            rotateClockwiseButtonHidden: true,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null) {
        _file = File(croppedFile.path);
        _imageRef ??= _fireStorage.newImgStorageRef;

        setUploading(true);

        try {
          await _imageRef!.putFile(_file as File);

          // Set as default spotlight photo when not existed
          // ignore: use_build_context_synchronously
          if (context.read<UserProvider>().getPhotoUrlCache().isEmpty) {
            await _setSpotlightPhoto();
          }
        } on FirebaseException catch (e) {
          _logger.e(e, time: DateTime.now());
        }

        setUploading(false);
      } else {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    _logger = context.read<LoggerProvider>().logger;
    _download();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    _fireStorage = Provider.of<FireStorageProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDisabled = !widget.enabled || _uploading || _deleting;

    return GestureDetector(
      onLongPress: () async {
        if (isDisabled) {
          return;
        }

        if (_imageRef != null) {
          HapticFeedback.heavyImpact();

          await _setSpotlightPhoto();
        }
      },
      onTap: () {
        if (isDisabled) {
          return;
        }

        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Wrap(
                runSpacing: 20,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n!.cardImagePickerSheetTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                      const Spacer(),
                      _xFile != null
                          ? Row(
                              children: [
                                IconButton.outlined(
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    await _crop();
                                  },
                                  icon: const Icon(Icons.crop),
                                ),
                                const SizedBox(width: 8),
                                IconButton.outlined(
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          icon: Icon(
                                            size: 40,
                                            Icons.warning_amber_rounded,
                                            color: theme.colorScheme.error,
                                          ),
                                          title: Text(
                                            l10n.dialogDeletePrimaryPhotoTitle,
                                          ),
                                          content: Text(
                                            l10n.dialogDeletePrimaryPhotoBody,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(l10n.cancel),
                                            ),
                                            FilledButton(
                                              onPressed: () {
                                                _delete();
                                                Navigator.pop(context);
                                              },
                                              child: Text(l10n.delete),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            )
                          : const Spacer()
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          IconButton.filled(
                            padding: const EdgeInsets.all(16),
                            onPressed: () async {
                              Navigator.pop(context);

                              _xFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );

                              await _crop();
                            },
                            icon: const Icon(Icons.image),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              l10n.gallery,
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 30),
                      Column(
                        children: [
                          IconButton.filled(
                            padding: const EdgeInsets.all(16),
                            onPressed: () async {
                              Navigator.pop(context);

                              _xFile = await _picker.pickImage(
                                source: ImageSource.camera,
                                preferredCameraDevice: CameraDevice.front,
                              );

                              await _crop();
                            },
                            icon: const Icon(Icons.photo_camera),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              l10n.camera,
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Builder(
        builder: (context) {
          return FadeThroughTransitionSwitcher(
            duration: const Duration(milliseconds: 800),
            child: _file == null
                ? DottedBorder(
                    dashPattern: const [10, 5],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    color: theme.colorScheme.outlineVariant,
                    child: SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        size: (widget.size / 4),
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  )
                : isDisabled
                    ? Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            //** Workaround of Image.file cache issue */
                            //** https://github.com/flutter/flutter/issues/24858 */
                            image: MemoryImage(
                              (_file as File).readAsBytesSync(),
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(40),
                        child: !_deleting
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                              )
                            : const SizedBox.shrink(),
                      )
                    : Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            //** Workaround of Image.file cache issue */
                            //** https://github.com/flutter/flutter/issues/24858 */
                            child: Image.memory(
                              (_file as File).readAsBytesSync(),
                              width: widget.size,
                              height: widget.size,
                              fit: BoxFit.cover,
                            ),
                          ),
                          ListenableBuilder(
                            listenable: userProvider,
                            builder: (context, _) {
                              final photoUrl = _imageRef?.fullPath ?? "";
                              final spotlight = userProvider.getPhotoUrlCache();
                              final isSpotlight = spotlight.isNotEmpty &&
                                  photoUrl.isNotEmpty &&
                                  photoUrl.contains(spotlight);

                              if (isSpotlight) {
                                return Positioned(
                                  top: -8,
                                  left: -8,
                                  child: Badge(
                                    largeSize: 32,
                                    label: Icon(
                                      Icons.star,
                                      color: theme.colorScheme.onTertiary,
                                    ),
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }
}
