import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselPage extends StatefulWidget {
  const CarouselPage({super.key});

  @override
  _CarouselPageState createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  // List of image URLs (or local assets if needed)
  final List<String> imgList = [
    'https://via.placeholder.com/600x400/0000FF/808080?Text=Image+1',
    'https://via.placeholder.com/600x400/FF0000/FFFFFF?Text=Image+2',
    'https://via.placeholder.com/600x400/00FF00/000000?Text=Image+3',
    'https://via.placeholder.com/600x400/FFFF00/000000?Text=Image+4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Carousel'),
      ),
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            autoPlay: true, // Auto play images
            enlargeCenterPage: true, // Enlarge the center image
            aspectRatio: 16 / 9, // Aspect ratio of the carousel
            onPageChanged: (index, reason) {
              print('Current page: $index');
            },
          ),
          items: imgList
              .map((item) => Container(
                    child: Center(
                      child: Image.network(
                        item,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
