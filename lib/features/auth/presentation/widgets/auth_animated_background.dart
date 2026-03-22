import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AuthAnimatedBackground extends StatefulWidget {
  final Widget child;
  final String imageUrl;

  const AuthAnimatedBackground({
    super.key, 
    required this.child, 
    this.imageUrl = 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=2040',
  });

  @override
  State<AuthAnimatedBackground> createState() => _AuthAnimatedBackgroundState();
}

class _AuthAnimatedBackgroundState extends State<AuthAnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _mousePosition = Offset.zero;
  final List<_Particle> _particles = List.generate(40, (index) => _Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent event) {
    setState(() {
      _mousePosition = event.localPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Parallax calculation
    final dx = (_mousePosition.dx - center.dx) / center.dx;
    final dy = (_mousePosition.dy - center.dy) / center.dy;

    return MouseRegion(
      onHover: (event) => _onPointerMove(event),
      child: Stack(
        children: [
          // 1. Dynamic Background Image
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            left: -40 + (dx * -30),
            top: -40 + (dy * -30),
            right: -40 + (dx * 30),
            bottom: -40 + (dy * 30),
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.25),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          
          // 2. Interactive Particles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              for (var p in _particles) {
                p.update(_controller.value, _mousePosition, size);
              }
              return CustomPaint(
                painter: _ParticlePainter(_particles),
                size: Size.infinite,
              );
            },
          ),
          
          // 3. Subtle Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          
          // 4. Content
          widget.child,
        ],
      ),
    );
  }
}

class _Particle {
  late double x, y;
  late double vx, vy;
  late double size;
  late double opacity;

  _Particle() {
    _reset();
  }

  void _reset() {
    final rand = Random();
    x = rand.nextDouble();
    y = rand.nextDouble();
    vx = (rand.nextDouble() - 0.5) * 0.001;
    vy = (rand.nextDouble() - 0.5) * 0.001;
    size = rand.nextDouble() * 4 + 1;
    opacity = rand.nextDouble() * 0.6 + 0.2;
  }

  void update(double progress, Offset mouse, Size screenSize) {
    x += vx;
    y += vy;
    
    // Subtle mouse attraction
    if (mouse != Offset.zero) {
      final mx = mouse.dx / screenSize.width;
      final my = mouse.dy / screenSize.height;
      final dist = sqrt(pow(mx - x, 2) + pow(my - y, 2));
      if (dist < 0.25) {
        x += (mx - x) * 0.015;
        y += (my - y) * 0.015;
      }
    }

    if (x < 0 || x > 1 || y < 0 || y > 1) _reset();
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var p in particles) {
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
