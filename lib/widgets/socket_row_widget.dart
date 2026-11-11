import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../models/gem.dart';

class SocketRowWidget extends StatelessWidget {
  final Equipment item;
  final Function(int socketIndex, Gem? gem)? onTapSocket;

  const SocketRowWidget({
    super.key,
    required this.item,
    this.onTapSocket,
  });

  @override
  Widget build(BuildContext context) {
    if (item.maxSockets <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Khảm: ', style: TextStyle(fontSize: 10, color: Colors.white54)),
          const SizedBox(width: 4),
          ...List.generate(item.maxSockets, (index) {
            final isOccupied = index < item.insertedGems.length;
            final gem = isOccupied ? item.insertedGems[index] : null;

            return GestureDetector(
              onTap: () => onTapSocket?.call(index, gem),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOccupied ? gem!.type.color.withOpacity(0.2) : Colors.black38,
                  border: Border.all(
                    color: isOccupied ? gem!.type.color : Colors.white24,
                    width: isOccupied ? 1.5 : 1.0,
                  ),
                  boxShadow: isOccupied
                      ? [
                          BoxShadow(
                            color: gem!.type.color.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isOccupied
                      ? Text(
                          gem!.type.emoji,
                          style: const TextStyle(fontSize: 12),
                        )
                      : const Icon(
                          Icons.add,
                          size: 14,
                          color: Colors.white30,
                        ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
