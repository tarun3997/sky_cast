import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sky_cast/model/current_weather.dart';

class CustomAppBar extends StatefulWidget {
  final WeatherResponse? weatherResponse;
  final bool isLoading;
  final Function(String) onSearch;

  CustomAppBar({
    Key? key,
    required this.weatherResponse,
    required this.isLoading,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: isSearch
          ? Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Enter ZIP Code...',
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isSearch = false; // Close search mode
                });
              },
              icon: const Icon(Icons.cancel_outlined, color: Colors.white),
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              widget.onSearch(value); // Call the search function from HomeScreen
              setState(() {
                isSearch = false; // Close search after submitting
              });
            }
          },
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: 8),
              widget.isLoading
                  ? Text(
                "Loading...",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 18),
              )
                  : Text(
                "${widget.weatherResponse!.name}, ${widget.weatherResponse!.sys.country}",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isSearch = true; // Open search mode
              });
            },
            child: const Icon(Icons.search_rounded, color: Colors.white),
          )
        ],
      ),
    );
  }
}


