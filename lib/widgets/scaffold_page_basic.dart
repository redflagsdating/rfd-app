import 'package:flutter/material.dart';

class ScaffoldPageBasic extends Scaffold {
  ScaffoldPageBasic({
    super.key,
    super.floatingActionButton,
    required this.content,
    this.leadingIcon,
    this.title,
    this.actions,
    this.padding,
    this.onBackPressed,
  }) : super(
          appBar: AppBar(
            centerTitle: true,
            leading: Semantics(
              button: true,
              child: IconButton(
                onPressed: onBackPressed,
                icon: Icon(leadingIcon ?? Icons.arrow_back_ios_new_rounded),
              ),
            ),
            title: title,
            actions: actions,
          ),
          body: Builder(
            builder: (context) {
              return SingleChildScrollView(
                padding: padding ??
                    const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 36,
                    ),
                child: content,
              );
            },
          ),
        );

  final Widget content;
  final IconData? leadingIcon;
  final Widget? title;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final void Function()? onBackPressed;
}
