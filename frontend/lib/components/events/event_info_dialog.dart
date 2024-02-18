
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPopup extends StatelessWidget {
  final TicketmasterEvent event;
  const EventPopup(this.event,{super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(event.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Starts ${event.startTime.localDate} ${event.startTime.localTime}'),
          // Text('Ends ${event.endTime.localDate} ${event.endTime.localTime}'),
          Text('At ${event.venues.firstOrNull?.name}'),
          if(event.ticketLimit != null && event.ticketLimit! > 0)
            ...[
              Container(height: 30),
              Text("Ticket Limit: ${event.ticketLimit}"),
            ],
          if(event.info.infoStr != null && event.info.infoStr!.isNotEmpty)
            ...[
              Container(height: 30),
              Text("INFO:"+(event.info.infoStr ?? '')),
            ],
          if(event.prices.isNotEmpty)
            ...[
              Container(height: 30),
              Text("Prices:"),
              ...event.prices.map((e) => Text("${e.type}: \$${e.min} - \$${e.max}")),
            ],
          // seatmap image
          if(event.seatmapUrl != null)
            ...[
              Container(height: 30),
              Image.network(event.seatmapUrl!, height: 300),
              Container(height: 30)
            ],
          ElevatedButton(
            onPressed: () {
              if(event.url == null) return;
              Uri uri = Uri.parse(event.url!);
              launchUrl(uri);
            },
            child: const Text('View Event on Ticketmaster'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}