import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/holiday_db.dart';
import 'package:presence_app/backend/models/utils/holiday.dart';
import 'package:presence_app/frontend/screens/attribute_holidays.dart';
import 'package:presence_app/frontend/widgets/holiday_card.dart';
import 'package:presence_app/utils.dart';

class HandleHolidays extends StatefulWidget {
  const HandleHolidays({Key? key}) : super(key: key);

  @override
  State<HandleHolidays> createState() => _HandleHolidaysState();
}

class _HandleHolidaysState extends State<HandleHolidays> {
  List<Holiday> holidays=[];
  bool inProgress=true;

  Future<void> retrieveHolidays() async {
    var x=await HolidayDB().getAllHolidays();
    setState(() {
      holidays=x;
      inProgress=false;
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveHolidays();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Liste des congés",
          style: TextStyle(
              fontSize: appBarTextFontSize
          ),),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueGrey,
              ),
              child: IconButton(
                tooltip: 'Attribuer ',
                onPressed: (){

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const AttributeHolidays();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.black, ),
              ),
            ),
          )
        ],
      ),

        body: FutureBuilder<void>(
        future: retrieveHolidays(),
    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {

    if (inProgress) {
    return const Center(
    child: CircularProgressIndicator(),
    );
    }
    else if (snapshot.hasError) {
    return const Center(
    child: Text('Error retrieving holidays data'),
    );
    }  else if(holidays.isEmpty){
    return const Center(child: Text('Aucun congé attribué'));
    }
    else {
    return
      CustomScrollView(
        slivers: [
          SliverList(
              delegate: SliverChildListDelegate(
                  List.generate(holidays.length, (int index) {
                    return Column(
                      children: [
                        HolidayDisplayCard(holiday: holidays[index]),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 0.0),
                          child: Divider(),
                        )
                      ],
                    );
                  }
                  )
              )
          ),
        ],
      );
    }
    }
    ),
    );
  }

}
