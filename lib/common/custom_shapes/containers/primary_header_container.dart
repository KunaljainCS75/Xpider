import 'package:flutter/material.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import '../../../../utils/constants/colors.dart';
import 'circular_container.dart';
import '../curved_edges/curved_edges_widget.dart';

class PrimaryHeaderContainer extends StatelessWidget {
  const PrimaryHeaderContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CurvedEdgesWidget(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TColors.primary,
              Colors.blue.shade900
            ],
          )
        ),
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          child: Stack(
            children: [
              const Positioned(top: 0, right: -100,
                  child: CircularImage(
                    isNetworkImage: false,
                    height: 300,
                    width: 300,
                    overLayColor: Colors.white24,
                    backgroundColor: Colors.transparent,
                    image: "assets/images/network/spiweb_flip.png",
                  )),
              const Positioned(top: 20, right: 220,
                  child: CircularImage(
                    isNetworkImage: false,
                    height: 90,
                    width: 90,
                    overLayColor: Colors.white70,
                    backgroundColor: Colors.transparent,
                    image: "assets/images/network/spiweb.png",
                  )),
              Positioned(top: 100, right: -300,
                  child: CircularContainer(
                      backgroundColor: TColors.textWhite.withOpacity(0.1))),
              child
            ],
          ),
        ),
      ),
    );
  }
}