import 'package:flutter/material.dart';

/// An expandable list of passwords with descriptions.
class PasswordsList extends StatefulWidget {
  @override
  _PasswordsListState createState() => _PasswordsListState();
}

class _PasswordsListState extends State<PasswordsList> {
  List<Item> _data = generateItems(18);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 25,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            color: Color(0xFFE1DFF8),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Theme(
              data: ThemeData().copyWith(cardColor: const Color(0xFFE1DFF8)),
              child: ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _data[index].isExpanded = !isExpanded;
                  });
                },
                children: _data.map<ExpansionPanel>((Item item) {
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(item.headerValue),
                        subtitle: Text(item.headerValue),
                      );
                    },
                    body: ListTile(
                        title: Text(item.expandedValue),
                        subtitle: const Text('To delete this panel, tap the trash can icon'),
                        trailing: const Icon(Icons.delete),
                        onTap: () {
                          setState(() {
                            _data.removeWhere((Item currentItem) => item == currentItem);
                          });
                        }),
                    isExpanded: item.isExpanded,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

List<Item> generateItems(int numberOfItems) {
  return List.generate(numberOfItems, (int index) {
    return Item(
      headerValue: 'Panel $index',
      expandedValue: 'This is item number $index',
    );
  });
}

class Item {
  Item({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}
