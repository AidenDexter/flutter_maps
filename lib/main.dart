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
    return const MaterialApp(
      title: 'Flutter Google Maps for Dartapp',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final _controller = Completer<GoogleMapController>();
  late BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  Marker? myPositionMarker;

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(0.1, 0.1)), 'assets/icon.png').then((value) {
      setState(() {
        customIcon = value;
        myPositionMarker = Marker(
            markerId: const MarkerId('myPosition'), position: const LatLng(43.026885, 44.690811), icon: customIcon);
      });
    });
    _getCurrent();
  }

  // final Marker firstMarker = const Marker(
  //     markerId: MarkerId('first'),
  //     position: LatLng(43.02115, 44.68196),
  //     infoWindow: InfoWindow(title: 'first', snippet: 'wow'));
  // final Marker secondMarker = const Marker(
  //     markerId: MarkerId('second'),
  //     position: LatLng(43.026885, 44.690811),
  //     infoWindow: InfoWindow(title: 'second', snippet: 'wow'));

  static const CameraPosition _vladikavkaz = CameraPosition(
    target: LatLng(43.02115, 44.68196),
    zoom: 10.4746,
  );

  // final Polyline polyline = const Polyline(polylineId: PolylineId('id'), points: [
  //   LatLng(43.02115, 44.68196),
  //   LatLng(43.026885, 44.690811),
  // ]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        // polylines: {polyline},
        markers: {
          if (myPositionMarker != null) myPositionMarker!,
        },
        initialCameraPosition: _vladikavkaz,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (controller) => _controller.complete(controller),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getCurrent,
        label: const Text('Curreent position'),
      ),
    );
  }

  Future<void> _getCurrent() async {
    _determinePosition().then((myPosition) async {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(myPosition.latitude, myPosition.longitude), zoom: 14)));
      setState(() {
        myPositionMarker = Marker(
            markerId: const MarkerId('myPosition'),
            position: LatLng(myPosition.latitude, myPosition.longitude),
            icon: customIcon);
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
