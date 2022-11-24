import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps for Dartapp',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Geolocator _geolocator = Geolocator()..forceAndroidLocationManager;
  Completer<GoogleMapController> _controller = Completer();
  @override
  void initState() {
    super.initState();
    _getCurrent();
  }

  static final CameraPosition _vladikavkaz = CameraPosition(
    target: LatLng(43.02115, 44.68196),
    zoom: 10.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
          initialCameraPosition: _vladikavkaz,
          myLocationButtonEnabled: true,
          mapType: MapType.hybrid,
          onMapCreated: (GoogleMapController controller) {
            {
              _controller.complete(controller);
            }
          }),
    );
  }

  Future<void> _getCurrent() async {
    _geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position position) async {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 14)));
    }).catchError((e) {
      print(e);
    });
  }
}
