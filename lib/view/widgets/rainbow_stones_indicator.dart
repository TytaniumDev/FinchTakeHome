import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class RainbowStonesIndicator extends StatelessWidget {
  const RainbowStonesIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RainbowStonesManager>(
      builder: (context, rainbowStonesManager, child) {
        final currentAmount = rainbowStonesManager.currentBalance;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'lib/assets/icons/rainbow-stones.svg',
                height: 16,
                width: 16,
                placeholderBuilder:
                    (BuildContext context) => Icon(
                      Icons.stars,
                      size: 16,
                      color: Colors.purple.shade700,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                currentAmount.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
