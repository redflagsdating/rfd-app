import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/widgets/image_placeholder.dart';

/// A wrapper of CachedNetworkImage with ImagePlaceholder
class CachedImage extends StatefulWidget {
  const CachedImage({
    super.key,
    this.photoUrl,
    this.width,
    this.height,
  });
  final String? photoUrl;
  final double? width;
  final double? height;

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  bool? _loading = false;
  String? _imageUrl;

  Future<void> _cacheImage() async {
    final photoUrl = widget.photoUrl;
    final storageProvider = context.read<FireStorageProvider>();

    if (photoUrl != null) {
      setState(() {
        _loading = true;
      });

      final imageUrl = await storageProvider.cacheImage(photoUrl);

      setState(() {
        _imageUrl = imageUrl;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    _cacheImage();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CachedImage oldWidget) {
    if (oldWidget.photoUrl != widget.photoUrl) {
      _cacheImage();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _imageUrl != null
        ? CachedNetworkImage(
            imageUrl: _imageUrl!,
            width: widget.width ?? double.infinity,
            height: widget.height ?? double.infinity,
            errorWidget: (context, url, error) {
              return ImagePlaceholder(error: error);
            },
            imageBuilder: (context, imageProvider) {
              return Image(
                image: imageProvider,
                fit: BoxFit.cover,
              );
            },
          )
        : ImagePlaceholder(
            loading: _loading,
            width: widget.width ?? double.infinity,
            height: widget.height ?? double.infinity,
          );
  }
}
