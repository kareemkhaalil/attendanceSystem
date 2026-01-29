// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class BranchManagerHomeScreen extends StatefulWidget {
//   const BranchManagerHomeScreen({super.key});

//   @override
//   State<BranchManagerHomeScreen> createState() =>
//       _BranchManagerHomeScreenState();
// }

// class _BranchManagerHomeScreenState extends State<BranchManagerHomeScreen>
//     with SingleTickerProviderStateMixin {
//   int _selectedIndex = 0;
//   late AnimationController _controller;

//   final List<String> _titles = [
//     "لوحة التحكم",
//     "الحضور",
//     "QR Code",
//     "التقارير",
//     "الموظفين"
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     )..forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }

//   Widget _buildQuickAction({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 32, color: Theme.of(context).primaryColor),
//             const SizedBox(height: 12),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDashboard() {
//     return FadeTransition(
//       opacity: _controller,
//       child: ListView(
//         padding: const EdgeInsets.all(24),
//         children: [
//           const SizedBox(height: 16),

//           // Header
//           Text(
//             "مرحبًا بك 👋",
//             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             "أنت الآن في لوحة تحكم مدير الفرع",
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Colors.grey[600],
//                 ),
//           ),
//           const SizedBox(height: 32),

//           // Quick Actions Grid
//           GridView.count(
//             shrinkWrap: true,
//             crossAxisCount: 2,
//             mainAxisSpacing: 20,
//             crossAxisSpacing: 20,
//             physics: const NeverScrollableScrollPhysics(),
//             children: [
//               _buildQuickAction(
//                 icon: LucideIcons.users,
//                 label: "متابعة الحضور",
//                 onTap: () {
//                   context.push("/branch/attendance");
//                 },
//               ),
//               _buildQuickAction(
//                 icon: LucideIcons.qrCode,
//                 label: "إنشاء QR Code",
//                 onTap: () {
//                   context.push("/branch/qr");
//                 },
//               ),
//               _buildQuickAction(
//                 icon: LucideIcons.barChart3,
//                 label: "التقارير",
//                 onTap: () {
//                   context.push("/branch/reports");
//                 },
//               ),
//               _buildQuickAction(
//                 icon: LucideIcons.settings,
//                 label: "إدارة الموظفين",
//                 onTap: () {
//                   context.push("/branch/employees");
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildDashboard();
//       case 1:
//         return const Center(child: Text("شاشة متابعة الحضور"));
//       case 2:
//         return const Center(child: Text("شاشة QR Code"));
//       case 3:
//         return const Center(child: Text("شاشة التقارير"));
//       case 4:
//         return const Center(child: Text("شاشة إدارة الموظفين"));
//       default:
//         return _buildDashboard();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_titles[_selectedIndex]),
//         backgroundColor: Theme.of(context).primaryColor,
//         elevation: 0,
//       ),
//       body: _buildBody(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: Theme.of(context).primaryColor,
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(LucideIcons.home), label: "الرئيسية"),
//           BottomNavigationBarItem(
//               icon: Icon(LucideIcons.users), label: "الحضور"),
//           BottomNavigationBarItem(icon: Icon(LucideIcons.qrCode), label: "QR"),
//           BottomNavigationBarItem(
//               icon: Icon(LucideIcons.barChart3), label: "التقارير"),
//           BottomNavigationBarItem(
//               icon: Icon(LucideIcons.settings), label: "الموظفين"),
//         ],
//       ),
//     );
//   }
// }
