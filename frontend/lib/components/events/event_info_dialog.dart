
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPopup extends StatelessWidget {
  final TicketmasterEvent event;
  const EventPopup(this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: ListBody(children: [
          Row(children: [
            SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'Date: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: event.startTime.getFormattedDate(),
                        ),
                        const TextSpan(
                          text: '\nTime: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: event.startTime.getFormattedTime(),
                        ),
                        const TextSpan(
                          text: '\nLocation: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: event.venues.firstOrNull?.name),
                      ],
                    ),
                  ),
                  if (event.ticketLimit != null && event.ticketLimit! > 0) ...[
                    Container(height: 30),
                    Text("Ticket Limit: ${event.ticketLimit}"),
                  ],
                  if (event.info.infoStr != null &&
                      event.info.infoStr!.isNotEmpty) ...[
                    Container(height: 30),
                    RichText(
                      text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'More Information:\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '${event.info.infoStr ?? ''}\n',
                            ),
                            if(event.info.infoStr != event.info.pleaseNote)
                              TextSpan(
                                text: '${event.info.pleaseNote ?? ''}\n',
                              ),
                            if(event.info.pleaseNote != event.info.ticketLimit)
                              TextSpan(
                                text: (event.info.ticketLimit ?? ''),
                              ),
                          ]),
                    )
                  ],
                  if (event.prices.isNotEmpty) ...[
                    Container(height: 30),
                    const Text("Prices:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...event.prices
                        .map((e) => Text("${e.type}: \$${e.min} - \$${e.max}")),
                  ]
                ],
              ),
            ),
            if (event.images.isNotEmpty) ...[
              const SizedBox(width: 100),
              SizedBox(
                  width: 400,
                  child: Image.network(event.images.first.url, height: 300))
            ]
          ]),
          // seatmap image
          if (event.seatmapUrl != null) ...[
            Image.network(event.seatmapUrl!, height: 300),
          ],
        ]),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (event.url == null) return;
            Uri uri = Uri.parse(event.url!);
            launchUrl(uri);
          },
          child: const Text('View Event on Ticketmaster'),
        ),
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
