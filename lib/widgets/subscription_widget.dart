import 'package:flutter/material.dart';

import '../utils/colors.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selectedSubscription = "Weekly"; // Default selected option

  final Map<String, List<String>> subscriptionNotes = {
    "Weekly": [
      "You will be charged \$21 every week",
      "The subscription auto-renews and you can cancel it anytime.",
      "To manage pr cancel your subscription, go to your google play store account > Payments and subscription > Subscriptions.",
      "Limited usage of the app is available without a subscription.",
    ],
    "Monthly": [
      "Trails star on September 22,2024 and ends on September 28,2024.",
      "Due amount today : null 0.00.",
      "Google will notify you before trial ends.",
      "You can cancel anytime before trial ends to avoid being charged.",
      "After thr trial ends, you will be automatically charged null every month.",
      "The subscription auto-renews and you can cancel it anytime.",
      "To manage pr cancel your subscription, go to your google play store account > Payments and subscription > Subscriptions.",
      "Limited usage of the app is available without a subscription.",
    ],
    "Yearly": [
      "You will be charged null every year.",
      "The subscription auto-renews and you can cancel it anytime.",
      "To manage pr cancel your subscription, go to your google play store account > Payments and subscription > Subscriptions.",
      "Limited usage of the app is available without a subscription.",
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightBlueBg,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Text(
              "Connect Smart Printer\n& Scanner",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubscriptionOption(
                    "Basic", "Weekly", "\$2.99", "\$2.99/Day",
                    highlight: true),
                _buildSubscriptionOption(
                    "Most Value", "Monthly", "\$5.99", "\$12.99/Week"),
                _buildSubscriptionOption(
                    "Best Value", "Yearly", "\$12.99", "\$180.99/Month"),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Try 3 Days Free, then \$12.99/Month",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.transparent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(1, "- Easy Printer Connectivity"),
                  _buildFeatureItem(2, "- Print your Photos"),
                  _buildFeatureItem(3, "- Print your Saved Files"),
                  _buildFeatureItem(4, "- Scan Document & Photos"),
                  _buildFeatureItem(
                      5, "- Print Documents & Photos in any size"),
                ],
              ),
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                top: 15,
                bottom: 15,
              ),
              decoration: BoxDecoration(
                color: AppColor.lightBlueColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {}, // Call print function
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "No Commitment / Cancel Anytime",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Term of use",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                SizedBox(width: 8),
                Container(width: 2, height: 17, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Privacy Policy",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._buildNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOption(
      String packageTitle, String title, String price, String period,
      {bool highlight = false}) {
    bool isSelected = selectedSubscription == title;

    // Define heights for selected and unselected states
    double selectedHeight = 140; // Adjusted height to avoid overflow
    double unselectedHeight = 130;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSubscription = title;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: isSelected ? selectedHeight : unselectedHeight,
          margin:
              EdgeInsets.symmetric(horizontal: 8), // Adds space between options
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // if (highlight)
              Text(
                packageTitle,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    // color: isSelected ? Colors.teal : Colors.black),
                    color: Colors.black),
              ),
              SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
              Text(
                period,
                style: TextStyle(fontSize: 10, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(int count, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$count ",
            style: TextStyle(color: Colors.teal),
          ),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNotes() {
    // Use ?. operator to safely access the list of notes
    final notes = subscriptionNotes[selectedSubscription] ?? [];

    return notes.map((note) => _buildNoteItem(note)).toList();
  }

  Widget _buildNoteItem(String note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.teal),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
