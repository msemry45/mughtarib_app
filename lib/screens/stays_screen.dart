import 'package:flutter/material.dart';

class StaysScreen extends StatefulWidget {
  @override
  _StaysScreenState createState() => _StaysScreenState();
}

class _StaysScreenState extends State<StaysScreen> {
  final TextEditingController _destinationController = TextEditingController();
  String _housingType = 'Host family';
  DateTimeRange? _dateRange;
  int _rooms = 1;
  int _adults = 2;
  int _children = 0;
  bool _showOptions = false;
  int _selectedOption = -1;

  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _pickRoomGuests() async {
    int tempRooms = _rooms;
    int tempAdults = _adults;
    int tempChildren = _children;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Select rooms and guests'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rooms'),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (tempRooms > 1) setStateDialog(() => tempRooms--);
                            },
                          ),
                          Text('$tempRooms'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setStateDialog(() => tempRooms++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Adults'),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (tempAdults > 1) setStateDialog(() => tempAdults--);
                            },
                          ),
                          Text('$tempAdults'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setStateDialog(() => tempAdults++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Children'),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (tempChildren > 0) setStateDialog(() => tempChildren--);
                            },
                          ),
                          Text('$tempChildren'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setStateDialog(() => tempChildren++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _rooms = tempRooms;
                      _adults = tempAdults;
                      _children = tempChildren;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMainBox(BuildContext context, ColorScheme colorScheme, Color textColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Destination
          ListTile(
            leading: Icon(Icons.search, color: Colors.purple),
            title: TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'Enter destination',
                border: InputBorder.none,
              ),
            ),
          ),
          Divider(color: Colors.purple),
          // Housing type
          ListTile(
            leading: Icon(Icons.bed, color: Colors.purple),
            title: Text('Type housing'),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: 'Host family',
                        groupValue: _housingType,
                        onChanged: (val) => setState(() => _housingType = val!),
                        activeColor: Colors.purple,
                      ),
                      Text('Host family'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: 'Private housing',
                        groupValue: _housingType,
                        onChanged: (val) => setState(() => _housingType = val!),
                        activeColor: Colors.purple,
                      ),
                      Text('Private housing'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: 'Hotel',
                        groupValue: _housingType,
                        onChanged: (val) => setState(() => _housingType = val!),
                        activeColor: Colors.purple,
                      ),
                      Text('Hotel'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.purple),
          // Date picker
          ListTile(
            leading: Icon(Icons.work, color: Colors.purple),
            title: Text(_dateRange == null
                ? 'Select dates'
                : '${_dateRange!.start.day}, ${_dateRange!.start.month} ${_dateRange!.start.year} - ${_dateRange!.end.day}, ${_dateRange!.end.month} ${_dateRange!.end.year}'),
            onTap: _pickDateRange,
          ),
          Divider(color: Colors.purple),
          // Room/guests
          ListTile(
            leading: Icon(Icons.person, color: Colors.purple),
            title: Text(
                '$_rooms room . $_adults adults . ${_children == 0 ? 'No children' : '$_children children'}'),
            onTap: _pickRoomGuests,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsBox(BuildContext context, ColorScheme colorScheme, Color textColor) {
    final options = [
      'Housing pictures',
      'Details (location, price, services ,rental period , ☆☆☆☆☆ )',
      'Family or roommate information',
      'Contact real estate office or the owner of the house',
    ];
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(options.length, (i) {
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  _selectedOption == i ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: Colors.purple,
                ),
                title: Text(options[i]),
                onTap: () => setState(() => _selectedOption = i),
              ),
              if (i != options.length - 1) Divider(color: Colors.purple),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onBackground;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: colorScheme.onPrimary),
        title: Text("Stays", style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildMainBox(context, colorScheme, textColor),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _showOptions = true;
                      });
                    },
                    child: Text('Search', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
                  ),
                ),
                if (_showOptions) ...[
                  SizedBox(height: 8),
                  Icon(Icons.arrow_downward, color: colorScheme.primary),
                  _buildOptionsBox(context, colorScheme, textColor),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      onPressed: _selectedOption != -1 ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Request sent!')),
                        );
                      } : null,
                      child: Text('Sent a request', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
