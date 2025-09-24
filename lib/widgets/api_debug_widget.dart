import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/motivation_service.dart';
import '../utils/constants.dart';

/// Widget untuk debugging API connectivity
/// Tambahkan ini ke settings page atau sebagai floating action button
class ApiDebugWidget extends StatefulWidget {
  const ApiDebugWidget({super.key});

  @override
  State<ApiDebugWidget> createState() => _ApiDebugWidgetState();
}

class _ApiDebugWidgetState extends State<ApiDebugWidget> {
  Map<String, bool>? _testResults;
  bool _testing = false;

  Future<void> _testApis() async {
    setState(() {
      _testing = true;
      _testResults = null;
    });

    try {
      final motivationService = Get.find<MotivationService>();
      final results = await motivationService.testApiConnectivity();
      
      setState(() {
        _testResults = results;
      });
    } catch (e) {
      print("Error testing APIs: $e");
      setState(() {
        _testResults = {'error': false};
      });
    } finally {
      setState(() {
        _testing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'API Configuration Debug',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // API Keys Status
            _buildApiKeyStatus('OpenRouter', ApiConstants.openRouterApiKey),
            _buildApiKeyStatus('ElevenLabs', ApiConstants.elevenLabsApiKey),
            
            const SizedBox(height: 16),
            
            // Test Button
            ElevatedButton(
              onPressed: _testing ? null : _testApis,
              child: _testing 
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Testing...'),
                      ],
                    )
                  : const Text('Test API Connectivity'),
            ),
            
            const SizedBox(height: 16),
            
            // Test Results
            if (_testResults != null) _buildTestResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyStatus(String name, String key) {
    final isValid = key != "YOUR_${name.toUpperCase()}_API_KEY" && key.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text('$name API Key: '),
          Text(
            isValid ? 'Configured' : 'Not Set',
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Test Results:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        if (_testResults!.containsKey('openrouter'))
          _buildTestResult('OpenRouter', _testResults!['openrouter']!),
        
        if (_testResults!.containsKey('elevenlabs'))
          _buildTestResult('ElevenLabs', _testResults!['elevenlabs']!),
          
        if (_testResults!.containsKey('error'))
          _buildTestResult('Test Error', false),
      ],
    );
  }

  Widget _buildTestResult(String service, bool success) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text('$service: '),
          Text(
            success ? 'Connected' : 'Failed',
            style: TextStyle(
              color: success ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function untuk menampilkan debug dialog
void showApiDebugDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ApiDebugWidget(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}