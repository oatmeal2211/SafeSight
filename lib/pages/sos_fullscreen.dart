import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SOSFullscreenPage extends StatefulWidget {
  const SOSFullscreenPage({super.key});

  @override
  State<SOSFullscreenPage> createState() => _SOSFullscreenPageState();
}

class _SOSFullscreenPageState extends State<SOSFullscreenPage> {
  int _countdown = 10;
  bool _isActivated = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0 && !_isActivated) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Color(0xFFFF1A1A),
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'EMERGENCY',
              style: TextStyle(
                color: Color(0xFFFF1A1A),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 20),
            if (!_isActivated) ...[
              Text(
                'Auto-activating in $_countdown seconds',
                style: const TextStyle(
                  color: Color(0xFF6E6E6E),
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
            ],
            GestureDetector(
              onTap: _activateSOS,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF1A1A),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1A1A).withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 15,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF1A1A).withOpacity(0.8),
                      blurRadius: 60,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_isActivated) ...[
              const Icon(
                Icons.check_circle,
                color: Color(0xFF39FF14),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'EMERGENCY ALERT SENT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF39FF14),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Help is on the way',
                style: TextStyle(
                  color: Color(0xFF6E6E6E),
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ] else ...[
              const Text(
                'TAP TO ACTIVATE\nEMERGENCY ALERT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6E6E6E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
            const SizedBox(height: 60),
            if (!_isActivated)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _activateSOS() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isActivated = true;
    });

    // Simulate sending emergency alert
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Emergency contacts notified',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF39FF14),
          ),
        );
      }
    });
  }
}
