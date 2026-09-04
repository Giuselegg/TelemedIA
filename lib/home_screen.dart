import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06152B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _topButton(Icons.menu),
                  _topButton(Icons.notifications_none, notification: true),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const Icon(Icons.smart_toy, size: 100, color: Color(0xFFF44336)),

            const SizedBox(height: 10),

            const Text(
              'TelemedIA',
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Container(width: 95, height: 3, color: const Color(0xFFF44336)),

            const SizedBox(height: 22),

            const Text(
              'L’INTELLIGENZA ARTIFICIALE\n'
              'AL SERVIZIO DELLE PERSONE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),

            const Spacer(),

            const Text(
              'Come posso aiutarti oggi?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Scrivi qui la tua richiesta...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 17),
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.send, color: Color(0xFF06152B)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 5),
              ),
              child: const Icon(Icons.mic_none, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 20),

            const Text(
              'Inizia una conversazione.',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'La nostra Intelligenza Artificiale è pronta ad aiutarti.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const Spacer(),

            Container(
              margin: const EdgeInsets.all(18),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    active: true,
                  ),
                  _BottomItem(
                    icon: Icons.lightbulb_outline,
                    label: 'I miei progetti',
                  ),
                  _BottomItem(
                    icon: Icons.smart_toy_outlined,
                    label: 'Assistente AI',
                  ),
                  _BottomItem(
                    icon: Icons.business_center_outlined,
                    label: 'Servizi',
                  ),
                  _BottomItem(icon: Icons.person_outline, label: 'Profilo'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _topButton(IconData icon, {bool notification = false}) {
    return Stack(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        if (notification)
          Positioned(
            right: 3,
            top: 3,
            child: Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? Colors.red : Colors.white, size: 28),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.red : Colors.white,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
