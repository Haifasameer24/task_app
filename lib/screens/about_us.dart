import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Center(
              child: Icon(
                Icons.task_alt_rounded,
                size: 100,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Task Manager',
                style: theme.textTheme.headline5?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Task Manager is a modern productivity app designed to help you organize, track, and complete your tasks efficiently. Whether you have personal errands or work projects, our app keeps you on top of your schedule with ease.',
              style: theme.textTheme.bodyText1?.copyWith(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 25),
            Text(
              'Key Features:',
              style: theme.textTheme.subtitle1?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const FeatureItem(text: '• Create, edit, and delete tasks effortlessly.'),
            const FeatureItem(text: '• Organize tasks by categories and statuses.'),
            const FeatureItem(text: '• Set due dates and reminders to never miss a deadline.'),
            const FeatureItem(text: '• Intuitive user interface with dark mode support.'),
            const FeatureItem(text: '• Sync your tasks across multiple devices (coming soon).'),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Contact Us',
                style: theme.textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Email: support@taskmanagerapp.com\nWebsite: www.taskmanagerapp.com',
                style: theme.textTheme.bodyText2?.copyWith(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2025 Task Manager. All rights reserved.',
                style: theme.textTheme.caption?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String text;

  const FeatureItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 15),
      ),
    );
  }
}
