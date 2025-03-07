// import 'package:flutter/material.dart';
// import 'package:watertracker/screens/onboarding/custom-button.dart';
// import 'package:watertracker/screens/onboarding/weather-selection-screen.dart';
// import 'package:watertracker/utils/app_colors.dart';

// class HeightSelectionScreen extends StatefulWidget {
//   const HeightSelectionScreen({Key? key}) : super(key: key);

//   @override
//   _HeightSelectionScreenState createState() => _HeightSelectionScreenState();
// }

// class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
//   bool _isCm = true;
//   double _height = 170.0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('Assessment'),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(4.0),
//           child: LinearProgressIndicator(
//             value: 5 / 17, // Fifth step of 17
//             backgroundColor: Colors.grey[300],
//             valueColor: const AlwaysStoppedAnimation<Color>(
//               AppColors.lightBlue,
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               "What's your Height?",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textHeadline,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildUnitButton('cm', _isCm),
//                 const SizedBox(width: 16),
//                 _buildUnitButton('ft', !_isCm),
//               ],
//             ),
//             const SizedBox(height: 32),
//             Text(
//               '${_height.toStringAsFixed(0)}${_isCm ? 'cm' : 'ft'}',
//               style: const TextStyle(
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textHeadline,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             SliderTheme(
//               data: SliderThemeData(
//                 activeTrackColor: AppColors.lightBlue,
//                 inactiveTrackColor: Colors.grey.shade300,
//                 thumbColor: AppColors.lightBlue,
//                 overlayColor: AppColors.lightBlue.withOpacity(0.2),
//               ),
//               child: Slider(
//                 value: _height,
//                 min: 100,
//                 max: 220,
//                 divisions: 120,
//                 label: _height.toStringAsFixed(0),
//                 onChanged: (double value) {
//                   setState(() {
//                     _height = value;
//                   });
//                 },
//               ),
//             ),
//             // Custom scale marks
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('100', style: TextStyle(color: Colors.grey.shade600)),
//                 Text('220', style: TextStyle(color: Colors.grey.shade600)),
//               ],
//             ),
//             const Spacer(),
//             CustomButton(
//               text: 'Continue',
//               backgroundColor: AppColors.lightBlue,
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const WeatherSelectionScreen(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUnitButton(String unit, bool isSelected) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _isCm = unit == 'cm';
//           // Convert height when switching units
//           if (_isCm) {
//             // ft to cm conversion (1 ft = 30.48 cm)
//             _height = _height * 30.48;
//           } else {
//             // cm to ft conversion
//             _height = _height / 30.48;
//           }
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.lightBlue : Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           unit,
//           style: TextStyle(
//             color: isSelected ? Colors.white : Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }
