import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/client/client_ratings_controller.dart';
import 'package:flutter_application_2/common/models/models/client_models/clients_details_model.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/client_details_screen.dart/widgets/full_screen_image.dart';
import 'package:provider/provider.dart';

class ClientDetailsScreen extends StatefulWidget {
  final OrderService booking;

  const ClientDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  ClientModel get client => widget.booking.client!;

    @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientRatingsController>().fetchClientRatings(
        widget.booking.client!.clientProfile!.id!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    title: const Text(
      "Client Details",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
  ),
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Kolors.kPrimary,
          Color(0xFF1A1A1A),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [

            Center(
  child: GestureDetector(
    onTap: client.profileImageUrl == null
        ? null
        : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImage(
                  imageUrl: client.profileImageUrl!,
                  heroTag: "client_pp_${client.clientProfile?.id}",
                ),
              ),
            );
          },
    child: Hero(
      tag: "client_pp_${client.clientProfile?.id}",
      child: CircleAvatar(
        radius: 48,
        backgroundColor: Colors.white24,
        backgroundImage: client.profileImageUrl != null
            ? NetworkImage(client.profileImageUrl!)
            : null,
        child: client.profileImageUrl == null
            ? Text(
                _initials(),
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    ),
  ),
),

            const SizedBox(height: 24),

            _infoCard(
              icon: Icons.person_outline,
              title: "Name",
              value: client.fullName,
            ),

            



            _infoCard(
              icon: Icons.cake_outlined,
              title: "Date of Birth",
              value: client.dateOfBirth?.toString().split(" ").first ?? "-",
            ),

            _infoCard(
  icon: Icons.location_on_outlined,
  title: "Service Address",
  value: widget.booking.deliveryAddress?.formattedAddress ?? "-",
),

Consumer<ClientRatingsController>(
  builder: (_, controller, __) {
    return Card(
      color: Colors.white.withValues(alpha: .08),
      margin: const EdgeInsets.only(bottom: 14),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: const Icon(
            Icons.star,
            color: Colors.amber,
            size: 32,
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white70,
          title: Text(
            client.rating != null
                ? "${client.rating} / 5.0"
                : "New",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            "${controller.ratings.length} Reviews",
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          children: [
            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.ratings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "No reviews yet.",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              ...controller.ratings.map(
                (rating) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber,
                    child: Text(
                      "${rating.score ?? "-"}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    rating.review?.isNotEmpty == true
                        ? rating.review!
                        : "No written review",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    rating.createdAt
                            ?.toString()
                            .split(" ")
                            .first ??
                        "",
                    style: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  },
),

          ],
        ),
      ),
    ));
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      color: Colors.white.withValues(alpha: .08),
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _initials() {
    final first = client.firstName ?? "";
    final last = client.lastName ?? "";

    return "${first.isNotEmpty ? first[0] : ""}"
        "${last.isNotEmpty ? last[0] : ""}";
  }
}