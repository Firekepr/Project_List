import 'package:flutter/material.dart';
import 'package:project_l/database/list.database.dart';
import 'package:project_l/interface/List-interface.dart';
import 'package:project_l/utils/Styles/project-styles.dart';
import 'package:project_l/utils/Widgets/projectl-bottom-sheet.dart';
import 'package:project_l/utils/Widgets/projectl-app-bar.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../utils/Widgets/projectl-edit-modal.dart';
import 'components/list-form.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final textController = TextEditingController();
  final FormGroup _form = FormGroup({
    'id': FormControl<int>(),
    'title':  FormControl<String>(validators: [Validators.required]),
    'content': FormControl<String>(),
    'checkBox': FormControl<String>(),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProjectLAppBar(
        preferredSize: Size.fromHeight(60),
      ),
      backgroundColor: ProjectLStyles.scaffoldColor,
      body: FutureBuilder<List<ListInterface>>(
          future: ListDataBase.instance.getListValues(),
          builder: (BuildContext context, AsyncSnapshot<List<ListInterface>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text('Loading...'),
              );
            }

            return snapshot.data!.isNotEmpty
                ? ListView.builder(
                    itemCount: snapshot.data!.length,
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    itemBuilder: (BuildContext context, int index) {
                      return ListBlock(
                        item: snapshot.data![index],
                        updateCheckBox: (value) => _updateCheckBox(value, snapshot.data![index]),
                        viewInformation: () => _viewMoreInformation(snapshot.data![index]),
                        deleteItem: () => _deleteItem(snapshot.data![index]),
                      );
                    })
                : Container();
          }),

      bottomSheet: ProjectLBottomSheet(
        controller: textController,
        addItem: _addItem,
      ),
    );
  }

  _viewMoreInformation(ListInterface list) {
    setState(() {
      _form.patchValue(list.toMap(list.checkBox));
    });

    return showDialog(
        context: context,
        builder: (context) {
          return ItemInfo(
            editItem: () => _editItem(_form, context),
            form: _form,
          );
        });
  }

  Future<void> _addItem() async {
    if (textController.text.isNotEmpty) {
      await ListDataBase.instance.add(
        ListInterface(
          title: textController.text,
          content: '',
          checkBox: false,
          position: 1,
        ),
      );
    }

    setState(() {
      textController.clear();
      FocusManager.instance.primaryFocus?.unfocus(); // Dismiss Keyboard
    });
  }

  Future<void> _editItem(FormGroup form, BuildContext context) async {
    if (form.dirty) {
      await ListDataBase.instance.updateSQL(form);
      Navigator.pop(context);
      setState(() {});
    }
  }

  Future<void> _updateCheckBox(bool? value, ListInterface item) async {
    await ListDataBase.instance.updateCheckBox(item, value!);
    setState(() {});
  }

  Future<void> _deleteItem(ListInterface item) async {
    await ListDataBase.instance.onDelete(item.id);
    setState(() {});
  }
}
