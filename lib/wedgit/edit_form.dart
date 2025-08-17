import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/addCatgory_controller.dart';
import '../models/Category.dart';

class CategoryForm extends StatefulWidget {
  final Category? category; // null => إضافة، غير null => تعديل
  const CategoryForm({this.category, Key? key}) : super(key: key);

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late TextEditingController nameController;
  late TextEditingController descController;
  Color? selectedColor;

  final categoryController = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.category?.name ?? '');
    descController = TextEditingController(text: widget.category?.description ?? '');
    selectedColor = widget.category?.color ?? Colors.grey;
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    if (name.isEmpty || desc.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
      return;
    }
    if (selectedColor == null) {
      Get.snackbar("Error", "select color");
      return;
    }
    if (widget.category == null) {
      await categoryController.addCategoryDirect(name, desc, selectedColor!);
      Get.snackbar("scusses", "Added Done");
    } else {
      await categoryController.editCategoryDirect(widget.category!.id, name, desc, selectedColor!);
      Get.snackbar("scusses", "Edite Done");
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left:16, right:16, top:24, bottom: MediaQuery.of(context).viewInsets.bottom+16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(hintText: 'Category Name', filled:true, fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            SizedBox(height:12),
            TextField(controller: descController, decoration: InputDecoration(hintText: 'Category Description', filled:true, fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            SizedBox(height:12),
            Align(alignment: Alignment.centerLeft, child: Text('Select Color', style: Theme.of(context).textTheme.bodyLarge)),
            SizedBox(height:8),
            Wrap(
              spacing: 8,
              children: [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.teal].map((color) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: selectedColor == color ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height:20),
            ElevatedButton(
              onPressed: save,
              child: Text(widget.category == null ? 'Add' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48), // ياخذ كامل العرض وارتفاع 48
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
