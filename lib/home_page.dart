import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_histroy_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(12.9048805, 77.5067799), zoom: 14.47);

  final List<Marker> _maker = <Marker>[];
  void initState() {
    super.initState();
  }

  Future<Position> getUserLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error");
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Map Application',
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 600,
            child: GoogleMap(
              markers: Set<Marker>.of(_maker),
              zoomControlsEnabled: false,
              myLocationEnabled: false,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () async {
                  getUserLocation().then((value) async {
                    print('.................');
                    print(value.latitude.toString());
                    print(value.longitude.toString());
                    _maker.add(
                      Marker(
                        markerId: MarkerId('1'),
                        position: LatLng(value.latitude, value.longitude),
                        infoWindow: InfoWindow(title: 'My location'),
                      ),
                    );
                    CameraPosition cameraPosition = CameraPosition(
                        zoom: 14,
                        target: LatLng(value.latitude, value.longitude));
                    final GoogleMapController controller =
                        await _controller.future;
                    controller.animateCamera(
                        CameraUpdate.newCameraPosition(cameraPosition));

                    setState(() {});
                    addMyLocation(value.latitude, value.longitude);
                  });
                },
                child: Text('Add My Location'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(LocationHistroyPage());
                },
                child: Text('My Location Histroy'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

void addMyLocation(lat, long) async {
  await FirebaseFirestore.instance.collection('myLocation').doc().set({
    'Lat': lat,
    'Long': long,
  });
  Fluttertoast.showToast(
      msg: "Your Location Added",
      backgroundColor: Colors.green,
      textColor: Colors.black);
}
