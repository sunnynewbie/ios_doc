import 'package:flutter/material.dart';

class BottomDoc extends StatefulWidget {
  const BottomDoc({super.key});

  @override
  State<BottomDoc> createState() => _BottomDocState();
}

class _BottomDocState extends State<BottomDoc> {
  List<Items> itemList = List.generate(4, (index) => Items(Offset.zero, index));
  bool isLeftDrag = false;
  int? draggingIndex; // Index of the item being dragged.
  Offset? dragPosition; // Track the drag position.
  int? targetIndex; // The new potential target index during drag.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black12,
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: itemList.indexed
                .map(
                  (e) {

                    return  GestureDetector(
                      child: Transform.translate(
                        offset: e.$2.offset,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 48,
                          height: 48,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.all(5),
                          color: Colors.primaries[e.$1 % Colors.primaries.length],
                          child: Text('${e.$2.index}',textAlign: TextAlign.center,),
                        ),
                      ),
                      onHorizontalDragStart: (details) {
                        setState(() {
                          draggingIndex = e.$1;
                          e.$2.offset=details.localPosition;
                          // dragPosition = details.localPosition;
                        });
                      },
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          dragPosition = details.localPosition;
                          e.$2.offset=details.localPosition;
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        setState(() {
                          final newIndex = _calculateNewIndex(
                              dragPosition!, context);

                          _reorderItem(draggingIndex!, newIndex); // Reorder the list.
                          // draggingIndex = null;
                          // dragPosition = null;
                        });
                      },
                    );
                  },
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void swapItems(int oldIndex, int newIndex) {
    setState(() {
      // final oldIndex = items.indexOf(data);
      // items.removeAt(oldIndex);
      // items.insert(index, data);

      final temp = itemList[oldIndex];
      temp.offset = Offset.zero;

      itemList[newIndex].offset = Offset.zero;
      itemList.insert(newIndex, temp);
      // itemList[oldIndex] = itemList[newIndex];
      // itemList[newIndex] = temp;
    });
  }
  int _calculateNewIndex(Offset dragEndPosition, BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(dragEndPosition);
    final itemWidth = 55.0;
    return (localPosition.dx ~/ itemWidth).clamp(0, itemList.length - 1);
  }

  void _reorderItem(int oldIndex, int newIndex) {
    if (newIndex >= 0 && newIndex < itemList.length ) {
      setState(() {
        final item = itemList.removeAt(oldIndex);
         itemList.insert(newIndex, item);
        for (var value in itemList) {
          value.offset=Offset.zero;
        }
      });
    }
  }

}

class Items {
  Offset offset;
  int index;

  Items(this.offset, this.index);
}

class ReorderableListWithGesture extends StatefulWidget {
  @override
  _ReorderableListWithGestureState createState() =>
      _ReorderableListWithGestureState();
}

class _ReorderableListWithGestureState
    extends State<ReorderableListWithGesture> {
  List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
  int? draggingIndex; // Index of the item being dragged.
  Offset? dragPosition; // Track the drag position.

  // Function to reorder items when dragging ends.
  void _reorderItem(int oldIndex, int newIndex) {
    if (newIndex >= 0 && newIndex < items.length && oldIndex != newIndex) {
      setState(() {
        final item = items.removeAt(oldIndex);
        items.insert(newIndex, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reorder List with Gestures')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onPanStart: (details) {
              setState(() {
                draggingIndex = index;
                dragPosition = details.localPosition;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                dragPosition = details.localPosition;
              });
            },
            onPanEnd: (details) {
              setState(() {
                final oldIndex = draggingIndex!;
                final newIndex = (dragPosition!.dy ~/ 60)
                    .clamp(0, items.length - 1); // Calculate new position.
                _reorderItem(oldIndex, newIndex); // Reorder the list.
                draggingIndex = null;
                dragPosition = null;
              });
            },
            child: Container(
              height: 60,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: draggingIndex == index ? Colors.blueGrey : Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                items[index],
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }
}
