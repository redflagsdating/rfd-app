import 'package:flutter/material.dart';

class ScaffoldPageBasic extends Scaffold {
  ScaffoldPageBasic({
    super.key,
    super.floatingActionButton,
    required this.content,
    this.title,
    this.actions,
    this.onBackPressed,
  }) : super(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
                onPressed: onBackPressed,
                icon: const Icon(Icons.arrow_back_ios_new_rounded)),
            title: title,
            actions: actions,
          ),
          body: Builder(
            builder: (context) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                child: content,
              );
            },
          ),
        );

  final Widget content;
  final Widget? title;
  final List<Widget>? actions;
  final void Function()? onBackPressed;
}
