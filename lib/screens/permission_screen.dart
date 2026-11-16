import 'package:flutter/material.dart';
import 'package:behaviormind/services/health_service.dart';
import 'package:behaviormind/routes.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/providers/user_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform; // Import Platform

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  PermissionScreenState createState() => PermissionScreenState();
}

class PermissionScreenState extends State<PermissionScreen> {
  bool _isProcessing = true; // Combined flag for checking and navigating
  String _statusMessage = 'Initializing...';
  bool _allPermissionsGrantedState = false; // Tracks if all essential permissions are granted

  @override
  void initState() {
    super.initState();
    _handlePermissionsAndNavigate();
  }

  Future<void> _handlePermissionsAndNavigate() async {
    final healthService = HealthService(); // Consider providing this via Provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Step 0: Load user data (can happen concurrently or first)
    if (mounted) setState(() { _statusMessage = 'Loading user data...'; });
    if (!userProvider.isUserLoaded) {
      await userProvider.loadUser();
    }

    // Step 1: Request Activity Recognition permission
    if (mounted) {
      setState(() { _statusMessage = 'Requesting Activity Recognition permission...'; });
    }
    PermissionStatus activityStatus = await Permission.activityRecognition.request();

    // Step 1.5: Request Location and Bluetooth permissions (Android only for specific BT)
    PermissionStatus? locationStatus;
    PermissionStatus? bluetoothScanStatus;
    PermissionStatus? bluetoothConnectStatus;

    bool localPermissionsAllGood = activityStatus.isGranted;

    if (Platform.isAndroid) {
        if (mounted) {
            setState(() { _statusMessage = 'Requesting Location permission...'; });
        }
        locationStatus = await Permission.location.request();
        if (!locationStatus.isGranted) localPermissionsAllGood = false;

        if (mounted) {
            setState(() { _statusMessage = 'Requesting Bluetooth Scan permission...'; });
        }
        bluetoothScanStatus = await Permission.bluetoothScan.request();
        if (!bluetoothScanStatus.isGranted) localPermissionsAllGood = false;

        if (mounted) {
            setState(() { _statusMessage = 'Requesting Bluetooth Connect permission...'; });
        }
        bluetoothConnectStatus = await Permission.bluetoothConnect.request();
        if (!bluetoothConnectStatus.isGranted) localPermissionsAllGood = false;
    } else if (Platform.isIOS) {
        // Handle iOS specific critical permissions if any and update localPermissionsAllGood
        if (mounted) {
            setState(() { _statusMessage = 'Checking iOS permissions...'; });
        }
    }
    // print("Initial Permission Statuses Log: Activity: ${activityStatus.name}, Location: ${locationStatus?.name}, BTScan: ${bluetoothScanStatus?.name}, BTConnect: ${bluetoothConnectStatus?.name}");

    // Step 2: Handle Health Connect permissions
    if (mounted) {
      if (activityStatus.isGranted) { // Or other conditions if health init is independent
        setState(() { _statusMessage = 'Activity Recognition granted. Requesting Health permissions...'; });
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          setState(() { _statusMessage = 'Requesting health data permissions...\\nPlease grant access when prompted by Health Connect.'; });
        }
        await healthService.initialize();
      } else {
        setState(() { 
          _statusMessage = 'Activity Recognition permission denied. Health data access will be limited.'; 
        });
         await healthService.initialize(); // Still attempt Health Connect init
      }
    }

    // After healthService.initialize() attempt, check its status
    if (!healthService.isInitialized) {
      localPermissionsAllGood = false; // Health permissions are essential
    }

    // Step 3: Construct final status message and Navigate if all good
    String finalStatusMessageText = '';
    if (Platform.isAndroid) {
      if (locationStatus != null) finalStatusMessageText += locationStatus.isGranted ? 'Location granted. ' : 'Location denied. ';
      if (bluetoothScanStatus != null) finalStatusMessageText += bluetoothScanStatus.isGranted ? 'Bluetooth Scan granted. ' : 'Bluetooth Scan denied. ';
      if (bluetoothConnectStatus != null) finalStatusMessageText += bluetoothConnectStatus.isGranted ? 'Bluetooth Connect granted. ' : 'Bluetooth Connect denied. ';
    }
    finalStatusMessageText += activityStatus.isGranted ? 'Activity Recognition granted. ' : 'Activity Recognition denied. ';

    if (healthService.isInitialized) {
      finalStatusMessageText += 'Health permissions process complete. ';
    } else {
      finalStatusMessageText += 'Health permissions not fully granted or Health Connect service unavailable. Some features may be limited. ';
    }
      
    if (localPermissionsAllGood) {
      finalStatusMessageText += 'All essential permissions granted. Proceeding to app...';
    } else {
      finalStatusMessageText += 'Some essential permissions were not granted. Please grant all permissions via App Settings for full functionality.';
    }
        
    if (mounted) {
      setState(() {
        _statusMessage = finalStatusMessageText;
        _isProcessing = false;
        _allPermissionsGrantedState = localPermissionsAllGood;
      });

      if (localPermissionsAllGood) {
        await Future.delayed(const Duration(milliseconds: 3000)); // Longer delay to read detailed status
        if (mounted) {
          final String nextRoute = userProvider.user != null ? AppRoutes.home : AppRoutes.login;
          Navigator.pushReplacementNamed(context, nextRoute);
        }
      }
      // If !localPermissionsAllGood, we stay on this screen, and the build method will show the button.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace with your actual logo widget or remove
              Image.asset('assets/logo/logo.png', height: 100, errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.shield_outlined, size: 100, color: Colors.grey); // Fallback icon
              }), 
              const SizedBox(height: 30),
              if (_isProcessing)
                const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (!_isProcessing && !_allPermissionsGrantedState)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      openAppSettings();
                    },
                    child: const Text('Open App Settings'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 