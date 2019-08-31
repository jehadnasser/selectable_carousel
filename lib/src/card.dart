/// Copyright (c) 2019, Jehad Nasser. All rights reserved.
/// Use of this source code is governed by a MIT License that can be found in the LICENSE file.

import 'package:flutter/material.dart';

typedef void IntCallback(int val);

class SelectableCard extends StatefulWidget {
  final IntCallback onChanged;
  final int id;
  final int selectedId;
  final Widget title;
  final Widget body;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double selectBorderRadius;
  final double cardBorderRadius;
  final double width;
  final bool fullScreen;
  final String displaySelectionBorder;

  SelectableCard({
    @required this.onChanged,
    @required this.id,
    this.selectedId,
    this.title,
    this.body,
    this.color,
    this.backgroundColor,
    this.borderColor = Colors.grey,
    this.borderWidth = 2.0,
    this.cardBorderRadius = 10.0,
    this.selectBorderRadius = 10.0,
    this.width = 100,
    this.fullScreen = false,
    this.displaySelectionBorder = 'body',
  });

  @override
  _SelectableCardState createState() => _SelectableCardState();
}

class _SelectableCardState extends State<SelectableCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    _isSelected = widget.id == widget.selectedId;

    return buildCarousalCard(
      title: widget.title,
      body: widget.body,
      onTap: () {
        widget.onChanged(widget.id);
      },
      width: widget.width,
      isSelected: _isSelected,
      borderColor: widget.borderColor,
      cardBorderRadius: widget.cardBorderRadius,
      selectBorderRadius: widget.selectBorderRadius,
      borderWidth: widget.borderWidth,
      fullScreen: widget.fullScreen,
      displaySelectionBorder: widget.displaySelectionBorder,
    );
  }

  Widget buildCarousalCard({
    Widget title,
    Widget body,
    VoidCallback onTap,
    bool isSelected = false,
    double width = 100,
    double height,
    Color borderColor,
    double cardBorderRadius = 10.0,
    double selectBorderRadius = 10.0,
    double borderWidth = 2.0,
    bool fullScreen = false,
    String displaySelectionBorder = 'body',
  }) {

    double _width = width;
    double _height = (height == null) ? (1.66 * _width) : height;
    double _titleSize = 0.24 * width;
    double _titlePadding = (title != null)
        ? (0.05 * _height)
        : 0.0;

    double _titleBodySpace = (title != null)
        ? 8.0
        : 0.0;

    double _bodyPadding = isSelected
        ? (0.04 * _height)
        : (0.04 * _height + borderWidth);

    double _bodyBottomPadding = isSelected
        ? (0.02 * _height)
        : (0.02 * _height + borderWidth);

    return GestureDetector(
      onTap: onTap,
      child: Container(

        decoration: (isSelected && displaySelectionBorder == 'all')
            ? BoxDecoration(
          border: Border.all(
            width: borderWidth,
            color: borderColor,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(selectBorderRadius),
          ),
        )
            : null,

        height: _height,
        width: _width,
        child: Card(
          margin: EdgeInsets.all(0.025 * _width),
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(cardBorderRadius),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 0.0,
              horizontal: 0.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    top: _titlePadding,
                  ),
                  alignment: Alignment.center,
                  child: title,
                ),
                Flexible(
                  child: Container(
                    height: (title == null) ? (_height /1.45) : null,
                    margin: EdgeInsets.only(
                      top: _titleBodySpace,
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                      top: fullScreen ? 0.0 : _bodyPadding ,
                      bottom: fullScreen ? 0.0 : _bodyPadding,//_bodyBottomPadding,
                      left: fullScreen ? 0.0 : _bodyPadding,
                      right: fullScreen ? 0.0 : _bodyPadding,
                    ),
                    decoration: (isSelected && displaySelectionBorder == 'body')
                        ? BoxDecoration(
                      border: Border.all(
                        width: borderWidth,
                        color: borderColor,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(selectBorderRadius),
                      ),
                    )
                        : null,
                    child: body,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
