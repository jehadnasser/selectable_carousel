/// Copyright (c) 2019, Jehad Nasser. All rights reserved.
/// Use of this source code is governed by a MIT License that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'card.dart';
import 'selectable_carousal_controller.dart';

typedef void IntCallback(int val);

class SelectableCarousal extends StatefulWidget {
  final SelectableCarousalController controller;
  final IntCallback onChanged;
  final List<Map<String, dynamic>> children;
  final double carousalWidth;
  final int visibleElements;
  final int selectedId;
  final bool isLoadingDemo;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double selectBorderRadius;
  final double cardBorderRadius;
  final String fontFamily;
  final bool fullScreen;
  final IconData leftIcon;
  final IconData rightIcon;

  SelectableCarousal({
    @required this.onChanged,
    this.controller,
    this.children,
    this.selectedId,
    this.carousalWidth,
    this.visibleElements = 3,
    this.isLoadingDemo = false,
    this.color = Colors.black,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 2,
    this.selectBorderRadius = 8.0,
    this.cardBorderRadius = 8.0,
    this.fontFamily,
    this.fullScreen,
    this.leftIcon,
    this.rightIcon,
  });

  @override
  _SelectableCarousalState createState() => _SelectableCarousalState();
}

class _SelectableCarousalState extends State<SelectableCarousal> {
  List<Map<String, dynamic>> _carousalChildren;
  ScrollController _scrollController;
  double _fontSize,
      _carousalWidth,
      _carousalCardsWidth,
      _cardWidth,
      _cardHeight,
      _controlWidth;
  bool rightBtnState = true,
      leftBtnState = true,
      _withInitMove = false,
      _withInitJump = false;
  int _itemsPerPage,
      _selectedCardId,
      _indexOfFirstSelectedCard,
      _initMoveAnimationTime = -1;

  StreamSubscription selectedIdSubscription;
  StreamSubscription carousalAnimationSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Stream selectByIdStream = widget.controller?.selectByIdStream;
    selectedIdSubscription?.cancel();
    selectedIdSubscription = selectByIdStream.listen((value) {
      _selectedCardId = value;
    });

    Stream animationStream = widget.controller?.animationStream;
    carousalAnimationSubscription?.cancel();
    carousalAnimationSubscription = animationStream.listen((value) {
      setState(() {
        _initMoveAnimationTime = value;
        if (_initMoveAnimationTime > 0) {
          _withInitMove = true;
        } else if (_initMoveAnimationTime == 0) {
          _withInitJump = true;
        } else {
          _withInitMove = false;
          _withInitJump = false;
        }
        _initMove();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _carousalChildren = widget.children;
    _itemsPerPage = widget.visibleElements;
    _carousalWidth = widget.carousalWidth;
    _carousalCardsWidth = _carousalWidth * 0.70;
    _cardWidth = _carousalCardsWidth / _itemsPerPage;
    _cardHeight = (_carousalChildren[0]['title'] != null)
        ? 1.66 * _cardWidth
        : 1.3 * _cardWidth;
    _controlWidth = (_carousalWidth - _carousalCardsWidth) / 2.0;
    _fontSize = (_carousalWidth * 0.28189) * 0.20;

    _indexOfFirstSelectedCard = 1 +
            _carousalChildren
                ?.indexWhere((card) => card['id'] == _selectedCardId) ??
        1;

    return buildCarousal(_carousalChildren);
  } // build

  _scrollListener() {
    // Detect the right end of the scrollable.
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        rightBtnState = false;
        leftBtnState = true;
      });
    }
    // Detect if not at the right end so both are true,
    // unless the next condition detect the left end.
    if (_scrollController.offset < _scrollController.position.maxScrollExtent) {
      setState(() {
        rightBtnState = true;
        leftBtnState = true;
      });
    }
    // Detect the left end of the scrollable.
    if (_scrollController.offset <=
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        rightBtnState = true;
        leftBtnState = false;
      });
    }
  }

  initState() {
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);

    super.initState();
    // Widget build's callback
    WidgetsBinding.instance.addPostFrameCallback((_) => _initMove());
    // Just another Widget build's callback
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollListener());
  }

  void _move(position, {duration = 600}) => _scrollController.animateTo(
        position,
        curve: Curves.linear,
        duration: Duration(milliseconds: duration),
      );

  void _initMove() {
    _indexOfFirstSelectedCard = 1 +
            _carousalChildren
                ?.indexWhere((card) => card['id'] == _selectedCardId) ??
        1;

    double newPosition =
        ((_indexOfFirstSelectedCard - _itemsPerPage) * _cardWidth).toDouble();
    newPosition = (newPosition < 0) ? 0 : newPosition;

    if (_withInitMove) {
      _move(newPosition, duration: _initMoveAnimationTime);
    } else if (_withInitJump) {
      _scrollController.jumpTo(newPosition);
    }
  }

  void _moveLeft() => _move(_scrollController.offset - _carousalCardsWidth);

  void _moveRight() => _move(_scrollController.offset + _carousalCardsWidth);

  Widget buildCarousalControl(
      {Widget child, Color color, VoidCallback onPressed}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(
            bottom: (0.16 * _cardHeight),
          ),
          width: _controlWidth,
          child: FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            textColor: color,
            child: child,
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }

  List<Widget> buildCarousalCards(List<Map<String, dynamic>> items) {
    return items
        .map(
          (card) => SelectableCard(
                controller:
                    widget.controller ?? new SelectableCarousalController(),
                onChanged: (val) {
                  widget.onChanged(val);
                  setState(() {
                    _selectedCardId = val;
                  });
                },
                id: card['id'],
                selectedId: _selectedCardId,
                borderColor: widget.borderColor,
                title: (card['title'] != null)
                    ? Text(
                        card['title'],
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: widget.color,
                          fontFamily: widget.fontFamily ??
                              Theme.of(context).textTheme.body1.fontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : null,
                body: card['body'],
                width: _cardWidth,
                displaySelectionBorder: 'body',
              ),
        )
        .toList();
  }

  Widget buildCarousal(items) {
    List<Widget> cards = buildCarousalCards(items);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Container(
            height: _cardHeight,
            width: _carousalWidth,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Back button
                (widget.leftIcon != null)
                    ? buildCarousalControl(
                        color: widget.color,
                        child: Icon(
                          widget.leftIcon,
                          textDirection: TextDirection.rtl,
                          size: 0.4 * _cardWidth,
                        ),
                        onPressed: (leftBtnState) ? _moveLeft : null,
                      )
                    : Container(),
                // Carousal
                Container(
                  height: 1.66 * _cardWidth,
                  width: _carousalCardsWidth,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: items.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => cards[index],
                  ),
                ),

                // Next button
                (widget.rightIcon != null)
                    ? buildCarousalControl(
                        color: widget.color,
                        child: Icon(
                          widget.rightIcon,
                          textDirection: TextDirection.ltr,
                          size: 0.4 * _cardWidth,
                        ),
                        onPressed: (rightBtnState) ? _moveRight : null,
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
