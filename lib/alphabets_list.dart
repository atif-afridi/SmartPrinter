import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:flutter/material.dart';

class AlphabetsList extends StatefulWidget {
  List<String> list;
  // VoidCallback onPressed;

  final void Function(int) onPrinterSelection;

  int selectedIndex = 0;

  AlphabetsList({
    super.key,
    required this.list,
    required this.onPrinterSelection,
    required this.selectedIndex,
  });

  @override
  State<AlphabetsList> createState() => _AlphabetsListState();
}

class _AlphabetsListState extends State<AlphabetsList> {
  @override
  Widget build(BuildContext context) {
    return AlphabetScrollView(
      list: widget.list.map((e) => AlphaModel(e)).toList(),
      isAlphabetsFiltered: false,
      alignment: LetterAlignment.right,
      itemExtent: 50,
      unselectedTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      selectedTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      overlayWidget: (value) => Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.star,
            size: 50,
            color: Colors.red,
          ),
          Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              // color: Theme.of(context).primaryColor,
            ),
            alignment: Alignment.center,
            child: Text(
              value.toUpperCase(),
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      itemBuilder: (_, k, id) {
        return Padding(
          padding: const EdgeInsets.only(right: 20),
          child: ListTile(
            // title: Text(id),
            // title: Text("Printer name :  $id"),
            subtitle: InkWell(
                onTap: () {
                  setState(() {
                    widget.selectedIndex = k;
                    widget.onPrinterSelection(k);
                  });
                },
                child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(id))),
            // leading: const Icon(Icons.person),
            // trailing: Radio<bool>(
            //   value: false,
            //   groupValue: widget.selectedIndex != k,
            //   onChanged: (value) {
            //     setState(() {
            //       widget.selectedIndex = k;
            //     });
            //   },
            // ),
          ),
        );
      },
    );
  }
}
