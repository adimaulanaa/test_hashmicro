import 'package:flutter/material.dart';

class SlideActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onSlideComplete;
  final IconData thumbIcon;
  final bool isLoading;

  const SlideActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onSlideComplete,
    this.thumbIcon = Icons.arrow_forward,
    this.isLoading = false,
  });

  @override
  State<SlideActionButton> createState() => _SlideActionButtonState();
}

class _SlideActionButtonState extends State<SlideActionButton> {
  double _thumbPosition = 0;
  double _maxSlide = 0;
  bool _completed = false;

  final double _thumbSize = 56;
  final double _buttonHeight = 64;

  @override
  void didUpdateWidget(SlideActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // reset posisi ketika loading selesai
    if (oldWidget.isLoading && !widget.isLoading) {
      setState(() {
        _thumbPosition = 0;
        _completed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxSlide = constraints.maxWidth - _thumbSize - 8;

        return Container(
          height: _buttonHeight,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: widget.color.withValues(alpha: 0.4)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // label
              AnimatedOpacity(
                opacity: widget.isLoading
                    ? 0
                    : _completed
                    ? 0
                    : (1 - (_thumbPosition / _maxSlide)),
                duration: const Duration(milliseconds: 100),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              // thumb
              AnimatedPositioned(
                duration: _completed
                    ? const Duration(milliseconds: 200)
                    : Duration.zero,
                left: _thumbPosition + 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_completed || widget.isLoading) return;
                    setState(() {
                      _thumbPosition += details.delta.dx;
                      _thumbPosition = _thumbPosition.clamp(0, _maxSlide);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_completed || widget.isLoading) return;
                    if (_thumbPosition >= _maxSlide * 0.85) {
                      setState(() {
                        _thumbPosition = _maxSlide;
                        _completed = true;
                      });
                      widget.onSlideComplete();
                    } else {
                      // balik ke awal kalau tidak sampai
                      setState(() => _thumbPosition = 0);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: widget.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Icon(
                            _completed ? Icons.check : widget.thumbIcon,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
