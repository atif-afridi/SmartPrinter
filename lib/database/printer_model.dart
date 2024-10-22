// ignore_for_file: equal_keys_in_map

import 'printer_connect_model.dart';

class PrintModel {
  // final int? id;
  int? id;
  // final int? number;
  final String title;
  // final String content;
  final bool isConnected;
  final DateTime? createdTime;

  PrintModel({
    this.id,
    // this.number,
    required this.title,
    required this.isConnected,
    // required this.content,
    this.createdTime,
  });

  Map<String, Object?> toJson() => {
        SmartPrinterFields.id: id,
        // NoteFields.number: number,
        SmartPrinterFields.title: title,
        // NoteFields.content: content,
        SmartPrinterFields.isConnected: isConnected ? 1 : 0,
        SmartPrinterFields.createdTime: createdTime?.toIso8601String(),
      };

  factory PrintModel.fromJson(Map<String, Object?> json) => PrintModel(
        id: json[SmartPrinterFields.id] as int?,
        // number: json[SmartPrinterFields.number] as int?,
        title: json[SmartPrinterFields.title] as String,
        // content: json[SmartPrinterFields.content] as String,
        isConnected: json[SmartPrinterFields.isConnected] == 1,
        createdTime: DateTime.tryParse(
            json[SmartPrinterFields.createdTime] as String? ?? ''),
      );

  PrintModel copy({
    int? id,
    // int? number,
    String? title,
    // String? content,
    bool? isConnected,
    DateTime? createdTime,
  }) =>
      PrintModel(
        id: id ?? this.id,
        // number: number ?? this.number,
        title: title ?? this.title,
        // content: content ?? this.content,
        isConnected: isConnected ?? this.isConnected,
        createdTime: createdTime ?? this.createdTime,
      );
}
