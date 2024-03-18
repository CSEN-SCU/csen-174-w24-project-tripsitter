import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/airport.dart';
import 'package:tripsitter/classes/car.dart';
import 'package:tripsitter/classes/filterbutton.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/cars/car_info_dialog.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/data.dart';
import 'package:tripsitter/helpers/formatters.dart';
import 'package:tripsitter/helpers/locators.dart';
import 'package:tripsitter/popups/checkbox_popup.dart';

class CarOptions extends StatefulWidget {
  final Trip trip;
  final RentalCarGroup? currentGroup;
  final Function setState;
  const CarOptions(
      {required this.trip, required this.currentGroup, required this.setState, super.key});

  @override
  State<CarOptions> createState() => _CarOptionsState();
}

class _CarOptionsState extends State<CarOptions> {
  @override
  void initState() {
    super.initState();
    getCars();
  }

  bool _selectedSort = true;

  List<RentalCarOffer> cars = [];

  void getCars() async {

    String? airportCode = widget.trip.flights.firstOrNull?.arrivalAirport;
    var airports = await getAirports(context);
    Airport? airport;
    if (airportCode != null) {
      airport = airports.firstWhere((element) => element.iataCode == airportCode);
    }
    else {
      airport = await getNearestAirport(widget.trip.destination, context);
    }
    
    RentalCarQuery query = RentalCarQuery(
      name: "${widget.trip.destination.name}, ${widget.trip.destination.country}",
      lat: airport.lat,
      lon: airport.lon,
      pickUp: widget.trip.startDate,
      dropOff: widget.trip.endDate,
    );
    print(query.toJson());
    cars = await TripsitterApi.searchRentalCars(query);
    cars.sort((a, b) => a.price.compareTo(b.price));
    final Set<String> rentalCompanies = {};
    for (RentalCarOffer car in cars) {
      rentalCompanies.add(car.provider.providerName);
    }

    final rentals = rentalCompanies.toList();
    rentals.sort((a, b) => a.compareTo(b));
    _selectedCompanies = [...rentals];
    setState(() {});
  }

  bool _isCompanyOpen = false;
  bool _isSizeOpen = false;
  bool _isDriveOpen = false;
  bool _isFuelOpen = false;
  List<String> _selectedCompanies = [];
  final GlobalKey _companyKey = GlobalKey();
  final GlobalKey _sizeKey = GlobalKey();
  final GlobalKey _driveKey = GlobalKey();
  final GlobalKey _fuelKey = GlobalKey();
  final GlobalKey _sortKey = GlobalKey();

  void _showCompanyPopup() {
    if (cars.isEmpty) return;
    setState(() {
      _isCompanyOpen = true;
    });

    final Set<String> rentalCompanies = {};
    for (RentalCarOffer car in cars) {
      rentalCompanies.add(car.provider.providerName);
    }

    final rentals = rentalCompanies.toList();
    rentals.sort((a, b) => a.compareTo(b));

    final popup = CheckboxPopup(
      options: rentals,
      format: (String option) => option,
      selected: _selectedCompanies,
      onSelected: (List<String> newSelected) {
        setState(() {
          _selectedCompanies = newSelected;
          // getFlights(reset: false);
        });
      },
    );

    popup.showPopup(context, _companyKey).then((_) {
      setState(() {
        _isCompanyOpen = false;
      });
    });
  }

  Map<String, String> sizes = {
    "C": "Compact",
    "D": "Compact Elite",
    "E": "Economy",
    "H": "Economy Elite",
    "F": "Fullsize",
    "G": "Fullsize Elite",
    "I": "Intermediate",
    "J": "Intermediate Elite",
    "L": "Luxury",
    "M": "Mini",
    "N": "Mini Elite",
    "O": "Oversize",
    "P": "Premium",
    "R": "Standard Elite",
    "S": "Standard",
    "U": "Premium Elite",
    "W": "Luxury Elite",
    "X": "Special",
  };
  List<String> allSizes = ["C", "E", "F", "I", "L", "M", "O", "P", "S", "X"];
  Map<String, List<String>> sizeMap = {
    "C": ["C", "D"],
    "E": ["E", "H"],
    "F": ["F", "G"],
    "I": ["I", "J"],
    "L": ["L", "W"],
    "M": ["M", "N"],
    "O": ["O"],
    "P": ["P"],
    "S": ["S", "R"],
    "X": ["X"],
  };
  List<String> _selectedSizes = [
    "C",
    "E",
    "F",
    "I",
    "L",
    "M",
    "O",
    "P",
    "S",
    "X"
  ];

  void _showSizePopup() {
    if (cars.isEmpty) return;
    setState(() {
      _isSizeOpen = true;
    });

    final popup = CheckboxPopup(
      options: allSizes,
      format: (String option) => sizes[option],
      selected: _selectedSizes,
      onSelected: (List<String> newSelected) {
        setState(() {
          _selectedSizes = newSelected;
          // getFlights(reset: false);
        });
      },
    );

    popup.showPopup(context, _sizeKey).then((_) {
      setState(() {
        _isSizeOpen = false;
      });
    });
  }

  Map<String, List<String>> driveMap = {
    "M": ["M", "N", "C"],
    "A": ["A", "B", "D"]
  };

  List<String> _selectedDrive = ["M", "A"];
  void _showDrivePopup() {
    if (cars.isEmpty) return;
    setState(() {
      _isDriveOpen = true;
    });

    final popup = CheckboxPopup(
      options: const ["M", "A"],
      format: (String option) => option == "M" ? "Manual" : "Automatic",
      selected: _selectedDrive,
      onSelected: (List<String> newSelected) {
        setState(() {
          _selectedDrive = newSelected;
        });
      },
    );

    popup.showPopup(context, _driveKey).then((_) {
      setState(() {
        _isDriveOpen = false;
      });
    });
  }

  List<String> _selectedFuel = [
    "N",
    "Z",
    "D",
    "E",
    "H",
    "I",
    "S",
    "F",
    "B",
    "X"
  ];

  Map<String, String> fuel = {
    "N": "Gasoline",
    "Z": "Petrol",
    "D": "Diesel",
    "E": "Electric",
    "H": "Hybrid",
    "I": "Hybrid Plug-in",
    "S": "LPG/Compressed Gas",
    "F": "Multi Fuel/Power",
    "B": "Hydrogen",
    "X": "Ethanol",
  };

  Map<String, List<String>> fuelMap = {
    "N": ["N", "R"],
    "Z": ["Z", "V"],
    "D": ["D", "Q"],
    "E": ["E", "C"],
    "H": ["H"],
    "I": ["I"],
    "S": ["S", "L"],
    "F": ["F", "M"],
    "B": ["B", "A"],
    "X": ["X", "U"]
  };

  void _showFuelPopup() {
    if (cars.isEmpty) return;
    setState(() {
      _isFuelOpen = true;
    });

    final popup = CheckboxPopup(
      options: fuel.keys.toList(),
      format: (String option) => fuel[option],
      selected: _selectedFuel,
      onSelected: (List<String> newSelected) {
        setState(() {
          _selectedFuel = newSelected;
        });
      },
    );

    popup.showPopup(context, _fuelKey).then((_) {
      setState(() {
        _isFuelOpen = false;
      });
    });
  }

  bool filterCar(RentalCarOffer car) {
    if (_selectedCompanies.isNotEmpty) {
      if (!_selectedCompanies.contains(car.provider.providerName)) {
        return false;
      }
    }
    if (_selectedSizes.isNotEmpty) {
      if (!_selectedSizes.any((s) => sizeMap[s]!.contains(car.sipp[0]))) {
        return false;
      }
    }
    if (_selectedDrive.isNotEmpty) {
      if (!_selectedDrive.any((s) => driveMap[s]!.contains(car.sipp[2]))) {
        return false;
      }
    }
    if (_selectedFuel.isNotEmpty) {
      if (!_selectedFuel.any((s) => fuelMap[s]!.contains(car.sipp[3]))) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context, listen: false);
    return widget.currentGroup == null
        ? const Center(
            child: Text("Select or create a group to choose a rental car"))
        : cars.isEmpty ? const Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    strokeWidth: 20,
                    semanticsLabel: 'Circular progress indicator',
                  ),
                ),
              ) :  Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Rental Cars for ${widget.currentGroup!.name}",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        children: <Widget>[
                          FilterButton(
                              text: 'Company',
                              globalKey: _companyKey,
                              onPressed: () => _showCompanyPopup(),
                              icon: Icon(
                                _isCompanyOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              )),
                          FilterButton(
                              text: 'Size',
                              globalKey: _sizeKey,
                              onPressed: _showSizePopup,
                              icon: Icon(
                                _isSizeOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              )),
                          FilterButton(
                              text: 'Drive',
                              globalKey: _driveKey,
                              onPressed: _showDrivePopup,
                              icon: Icon(
                                _isDriveOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              )),
                          FilterButton(
                              text: 'Fuel',
                              globalKey: _fuelKey,
                              onPressed: _showFuelPopup,
                              icon: Icon(
                                _isFuelOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              )),
                        ],
                      ),
                    ),
                    FilterButton(
                        color: Colors.grey[50]!,
                        text: 'Sort by Price',
                        globalKey: _sortKey,
                        onPressed: () {},
                        icon: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedSort = !_selectedSort;
                            });
                          },
                          icon: Icon(_selectedSort
                              ? Icons.arrow_upward
                              : Icons.arrow_downward),
                        )),
                  ],
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: ImplicitlyAnimatedList<RentalCarOffer>(
                    insertDuration: const Duration(milliseconds: 350),
                    removeDuration: const Duration(milliseconds: 350),
                    updateDuration: const Duration(milliseconds: 350),
                    areItemsTheSame: (a, b) => a.guid == b.guid,
                    items: (_selectedSort ? cars : cars.reversed)
                        .where(filterCar)
                        .toList(),
                    itemBuilder: (context, animation, car, i) =>
                        SizeFadeTransition(
                      sizeFraction: 0.8,
                      curve: Curves.easeInOut,
                      animation: animation,
                      child: ListTile(
                        tileColor: i % 2 == 0 ? Colors.white : Colors.grey[200],
                        leading: Image.network(
                          "https://logos.skyscnr.com/images/carhire/sippmaps/${car.group.img}",
                          width: 80,
                          height: 80,
                        ),
                        title: Text(
                            "${car.sipp.fromSipp()} (${car.carName} or similar)"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CarInfoDialog(car);
                                  },
                                );
                              },
                            ),
                            ElevatedButton(
                              child: Text(
                                "Select${widget.currentGroup!.options.map((c) => c.guid).contains(car.guid) ? "ed" : ""}",
                              ),
                              onPressed: () async {
                                if (widget.currentGroup!.options
                                    .map((c) => c.guid)
                                    .contains(car.guid)) {
                                  await widget.currentGroup!
                                      .removeOptionById(car.guid);
                                } else {
                                  await widget.currentGroup!.addOption(car);
                                }
                                setState(() {});
                                widget.setState();
                                if (isMobile && mounted) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                        subtitle: Text("\$${car.price.toStringAsFixed(2)}"),
                      ),
                    ),
                  ),
                ),
                // for (RentalCarOffer car in (_selectedSort ? cars : cars.reversed).where(filterCar))
                // ListTile(
                //     leading: Image.network("https://logos.skyscnr.com/images/carhire/sippmaps/${car.group.img}", width: 80, height: 80),
                //     title: Text("${car.sipp.fromSipp()} (${car.carName} or similar)"),
                //     trailing: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         IconButton(
                //           icon: Icon(Icons.info),
                //           onPressed: () {
                //             showDialog(
                //               context: context,
                //               builder: (BuildContext context) {
                //                 return CarInfoDialog(car);
                //               }
                //             );
                //           },
                //         ),
                //         ElevatedButton(
                //           child: Text("Select${widget.currentGroup!.options.map((c) => c.guid).contains(car.guid) ? "ed" : ""}"),
                //           onPressed: () async {
                //             if(widget.currentGroup!.options.map((c) => c.guid).contains(car.guid)) {
                //               await widget.currentGroup!.removeOptionById(car.guid);
                //             } else {
                //               await widget.currentGroup!.addOption(car);
                //             }
                //             setState(() {});
                //             widget.setState();
                //           },
                //         )
                //       ]
                //     ),
                //     subtitle: Text("\$${car.price.toStringAsFixed(2)}"),
                //   )
              ],
            ),
          );
  }
}
