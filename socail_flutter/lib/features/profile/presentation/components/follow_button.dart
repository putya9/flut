import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;
  const FollowButton(
      {super.key, required this.onPressed, required this.isFollowing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: MaterialButton(
          padding: const EdgeInsets.all(20),
          onPressed: onPressed,
          color:
              isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,
          child: Text(
            isFollowing ? 'Отписаться' : 'Подписаться',
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
