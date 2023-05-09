import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/screens/register_attendee.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return (Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemBuilder: (context, index) => Container(
            height: 100,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).canvasColor,
              boxShadow: const [BoxShadow()],
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: FloatingActionButton(
            backgroundColor: Constants.primaryColor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const RegisterAttendeeForm();
                },
              );
            },
            child: const Icon(Icons.person_add),
          ),
        )
      ],
    ));
  }
}
