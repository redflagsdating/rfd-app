import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/fade_through_transition_switcher.dart';

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

class _CardImagePickerState extends State<CardImagePicker> {
  File? _file;
  XFile? _xFile;
  Reference? _imageRef;
  bool _uploading = false;

  final _picker = ImagePicker();
  late Logger _logger;
  late FireStorageProvider _fireStorage;

  void setUploading(bool value) {
    setState(() {
      _uploading = value;
    });
  }

  Future<void> _delete() async {
    await _imageRef!.delete();
    await _file?.delete();

    _file = null;
    _xFile = null;
    _imageRef = null;

    setState(() {});
  }

  Future<void> _download() async {
    if (widget.imageRef == null) {
      return;
    }

    _imageRef = widget.imageRef;

    final appDocDir = await getApplicationDocumentsDirectory();
    final dir = await Directory(
      '${appDocDir.path}/${widget.imageRef?.parent?.fullPath}',
    ).create(recursive: true);

    _file = File("${dir.path}/${widget.imageRef?.name}");

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

  Future<void> _upload() async {
    _imageRef ??= _fireStorage.newImgStorageRef;
    final userProvider = context.read<UserProvider>();

    setUploading(true);

    try {
      await _imageRef!.putFile(_file as File);

      // Set as default spotlight photo when not existed
      if (userProvider.getPhotoUrlCache()!.isEmpty) {
        await userProvider.setPhotoUrl(
          _imageRef!.fullPath,
          localOnly: false,
          silent: false,
        );
      }
    } on FirebaseException catch (e) {
      // TODO
      _logger.e(e, time: DateTime.now());
    }

    setUploading(false);
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
      } else {
        _file = File(_xFile!.path);
      }

      setState(() {});
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
    final isDisabled = _uploading || !widget.enabled;

    return GestureDetector(
      onLongPress: () async {
        if (isDisabled) {
          return;
        }

        if (_imageRef != null) {
          HapticFeedback.vibrate();

          await userProvider.setPhotoUrl(
            _imageRef!.fullPath,
            localOnly: false,
            silent: false,
          );
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
                                    await _upload();
                                  },
                                  icon: const Icon(Icons.crop),
                                ),
                                const SizedBox(width: 8),
                                IconButton.outlined(
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    await _delete();
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
                              await _upload();
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
                              await _upload();
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
              duration: const Duration(milliseconds: 300),
              child: _file == null
                  ? SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child: Card(
                        margin: const EdgeInsets.all(0),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          size: (widget.size / 4),
                          color: theme.colorScheme.outline.withOpacity(0.5),
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
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
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
                                final spotlight =
                                    userProvider.getPhotoUrlCache();
                                final isSpotlight =
                                    _imageRef?.fullPath.contains(spotlight!) ??
                                        false;

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
                        ));
        },
      ),
    );
  }
}
