import 'package:flutter/material.dart';

class NotificationButton extends StatefulWidget {
  final int notificationCount;
  final List<String> notifications;

  NotificationButton({
    required this.notificationCount,
    required this.notifications,
  });

  @override
  NotificationButtonState createState() => NotificationButtonState();
}

class NotificationButtonState extends State<NotificationButton> {
  OverlayEntry? _overlayEntry;

  void _toggleNotificationList() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context)?.insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    setState(() {});
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        right: 8,
        top: offset.dy + size.height + 8,
        width: 300,
        child: Material(
          elevation: 4,
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: _toggleNotificationList,
                    ),
                  ],
                ),
                Divider(),
                if (widget.notifications.isNotEmpty)
                  ...widget.notifications.map(
                    (notification) => ListTile(
                      title: Text(notification),
                    ),
                  ),
                if (widget.notifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('No notifications'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.notification_important),
            color: Color.fromARGB(255, 82, 138, 84),
            tooltip: 'Open notifications',
            onPressed: _toggleNotificationList,
          ),
        ),
        if (widget.notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 82, 138, 84),
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${widget.notificationCount}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
