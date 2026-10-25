import 'package:flutter/material.dart';

class EngineeringCalculatorScreen extends StatefulWidget {
  const EngineeringCalculatorScreen({super.key});

  @override
  State<EngineeringCalculatorScreen> createState() => _EngineeringCalculatorScreenState();
}

class _EngineeringCalculatorScreenState extends State<EngineeringCalculatorScreen> {
  String _selectedFormula = 'Carnot Efficiency';

  // Controllers for Carnot
  final _tHighCtrl = TextEditingController(text: '500');
  final _tLowCtrl = TextEditingController(text: '300');
  double? _carnotResult;

  // Controllers for Stress
  final _forceCtrl = TextEditingController(text: '10000');
  final _areaCtrl = TextEditingController(text: '0.005');
  double? _stressResult;

  // Controllers for Viscosity
  final _muCtrl = TextEditingController(text: '0.01');
  final _duCtrl = TextEditingController(text: '2.0');
  final _dyCtrl = TextEditingController(text: '0.001');
  double? _viscosityResult;

  void _calculateCarnot() {
    final th = double.tryParse(_tHighCtrl.text);
    final tl = double.tryParse(_tLowCtrl.text);
    if (th != null && tl != null && th > tl && th > 0) {
      setState(() {
        _carnotResult = (1 - (tl / th)) * 100;
      });
    }
  }

  void _calculateStress() {
    final p = double.tryParse(_forceCtrl.text);
    final a = double.tryParse(_areaCtrl.text);
    if (p != null && a != null && a > 0) {
      setState(() {
        _stressResult = (p / a) / 1e6; // Convert to MPa
      });
    }
  }

  void _calculateViscosity() {
    final mu = double.tryParse(_muCtrl.text);
    final du = double.tryParse(_duCtrl.text);
    final dy = double.tryParse(_dyCtrl.text);
    if (mu != null && du != null && dy != null && dy > 0) {
      setState(() {
        _viscosityResult = mu * (du / dy); // N/m²
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Mechanical Formula Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedFormula,
              decoration: InputDecoration(
                labelText: 'Select Formula Engine',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'Carnot Efficiency', child: Text('Carnot Cycle Efficiency η = (1 - T_L/T_H)')),
                DropdownMenuItem(value: 'Direct Stress', child: Text('Direct Stress σ = P / A (MPa)')),
                DropdownMenuItem(value: 'Newton Viscosity', child: Text('Viscosity Shear Stress τ = μ·(du/dy)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedFormula = val);
              },
            ),
            const SizedBox(height: 20),
            if (_selectedFormula == 'Carnot Efficiency') _buildCarnotCalculator(),
            if (_selectedFormula == 'Direct Stress') _buildStressCalculator(),
            if (_selectedFormula == 'Newton Viscosity') _buildViscosityCalculator(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarnotCalculator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔥 Carnot Efficiency Calculator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _tHighCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'T_H (Source Temp in Kelvin K)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tLowCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'T_L (Sink Temp in Kelvin K)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _calculateCarnot,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Efficiency η'),
            ),
            if (_carnotResult != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  'Result: Carnot Efficiency η = ${_carnotResult!.toStringAsFixed(2)}%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStressCalculator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚙️ Direct Stress Calculator (σ = P / A)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _forceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Applied Force P (N)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _areaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cross-sectional Area A (m²)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _calculateStress,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Stress σ'),
            ),
            if (_stressResult != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  'Result: Direct Stress σ = ${_stressResult!.toStringAsFixed(3)} MPa',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildViscosityCalculator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌊 Newton\'s Law of Viscosity (τ = μ·du/dy)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _muCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Dynamic Viscosity μ (Pa·s or N·s/m²)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _duCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Velocity Change du (m/s)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Distance dy (m)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _calculateViscosity,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Shear Stress τ'),
            ),
            if (_viscosityResult != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  'Result: Shear Stress τ = ${_viscosityResult!.toStringAsFixed(2)} N/m²',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900, fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
