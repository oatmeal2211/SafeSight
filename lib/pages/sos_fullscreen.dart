import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/case_service.dart';
import '../constants/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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
        
        // Add haptic feedback for urgency in last 3 seconds
        if (_countdown <= 3 && _countdown > 0) {
          HapticFeedback.mediumImpact();
        }
        
        if (_countdown == 0) {
          // Auto-activate SOS when countdown reaches 0
          _activateSOS(isAutoActivated: true);
        } else {
          _startCountdown();
        }
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
                _countdown > 0 
                  ? 'Auto-activating in $_countdown seconds'
                  : 'ACTIVATING EMERGENCY ALERT...',
                style: TextStyle(
                  color: _countdown <= 3 ? const Color(0xFFFF1A1A) : const Color(0xFF6E6E6E),
                  fontSize: _countdown <= 3 ? 18 : 16,
                  fontWeight: _countdown <= 3 ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
            ],
            GestureDetector(
              onTap: () => _activateSOS(),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF1A1A),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1A1A).withOpacity(_countdown <= 3 ? 0.8 : 0.6),
                      blurRadius: _countdown <= 3 ? 40 : 30,
                      spreadRadius: _countdown <= 3 ? 20 : 15,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF1A1A).withOpacity(_countdown <= 3 ? 1.0 : 0.8),
                      blurRadius: _countdown <= 3 ? 80 : 60,
                      spreadRadius: _countdown <= 3 ? 10 : 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3.0,
                        ),
                      ),
                      if (!_isActivated && _countdown <= 3 && _countdown > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '$_countdown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
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
                'SOS ALERT CREATED',
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
                'Location marked on map\nReturning to map view...',
                textAlign: TextAlign.center,
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
                child: Text(
                  _countdown <= 3 ? 'TAP TO CANCEL' : 'CANCEL',
                  style: TextStyle(
                    color: _countdown <= 3 ? const Color(0xFFFF1A1A) : const Color(0xFF6E6E6E),
                    fontSize: _countdown <= 3 ? 18 : 16,
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

  void _activateSOS({bool isAutoActivated = false}) async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isActivated = true;
    });

    try {
      // Create SOS report with current location and time
      final caseId = await CaseService.createSOSCase();
      final now = DateTime.now();
      final timeString = DateFormat('HH:mm:ss').format(now);
      
      // Show success toast with details, different message for auto vs manual activation
      final activationType = isAutoActivated ? "Auto-activated" : "Manually activated";
      Fluttertoast.showToast(
        msg: "$activationType SOS Alert at $timeString\nCase ID: $caseId",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: AppColors.neonRed,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Navigate back to map after a delay to show the SOS marker
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context); // Go back to main app with map tab
        }
      });
    } catch (e) {
      // Show error if location/report creation fails
      Fluttertoast.showToast(
        msg: "Failed to create SOS alert: $e",
        backgroundColor: AppColors.neonRed,
        textColor: Colors.white,
      );
    }
  }
}
