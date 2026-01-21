import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/utils/services.dart';
import 'package:flutter_application_2/const/resource.dart';



List<String> images = [
  "assets/images/Welcome_slider_1.jpeg",
  "assets/images/welcome_slider_2.jpeg",
  "assets/images/welcome_slider_3.jpeg",
];

LinearGradient kGradient = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Kolors.kPrimaryLight,
    Kolors.kWhite,
    Kolors.kPrimary,
  ],
);

LinearGradient kPGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Kolors.kPrimaryLight,
    Kolors.kPrimaryLight.withOpacity(0.7),
    Kolors.kPrimary,
  ],
);

LinearGradient kBtnGradient = const LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.bottomRight,
  colors: [
    Kolors.kPrimaryLight,
    Kolors.kWhite,
  ],
);

BorderRadiusGeometry kClippingRadius = const BorderRadius.only(
  topLeft: Radius.circular(20),
  topRight: Radius.circular(20),
);

BorderRadiusGeometry kRadiusAll = BorderRadius.circular(12);

BorderRadiusGeometry kRadiusTop = const BorderRadius.only(
  topLeft: Radius.circular(9),
  topRight: Radius.circular(9),
);

BorderRadiusGeometry kRadiusBottom = const BorderRadius.only(
  bottomLeft: Radius.circular(12),
  bottomRight: Radius.circular(12),
);

Widget Function(BuildContext, String)? placeholder = (p0, p1) => Image.asset(
     images[0],
      fit: BoxFit.cover,
    );

Widget Function(BuildContext, String)? placeholder2 = (p1, p2) => Image.asset(
     images[2],
      fit: BoxFit.contain,
    );

Widget Function(BuildContext, String, Object)? errorWidget =
    (p0, p1, p3) => Image.asset(
            images[1],

          fit: BoxFit.contain,
        );



// class UserModel {
//   final String id;
//   final String name;
//   final String email;
//   final String phone;
//   final String password;
//   final String avatar;
//   final String serviceID;
//   final String address;
//   final String city;
//   final String country;
//   final String zip;
//   final String gender;
//   final String dob;
//   final String bio;
//   final String businessName;
//   final String businessAddress;
//   final String businessCity;
//   final String businessCountry;
//   final String businessZip;
//   final String businessPhone;
//   final String businessEmail;
//   final String businessWebsite;
//   final String businessBio;
//   final String businessPicture;
//   final String businessCategory;
//   final String businessSubCategory;
//   final String business;

//   userModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.password,
//     required this.avatar,
//     required this.serviceID,
//     required this.address,
//     required this.city,
//     required this.country,
//     required this.zip,
//     required this.gender,
//     required this.dob,
//     required this.bio,
//     required this.businessName,
//     required this.businessAddress,
//     required this.businessCity,
//     required this.businessCountry,
//     required this.businessZip,
//     required this.businessPhone,
//     required this.businessEmail,
//     required this.businessWebsite,
//     required this.businessBio,
//     required this.businessPicture,
//     required this.businessCategory,
//     required this.businessSubCategory,
//     required this.business
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       phone: json['phone'],
//       password: json['password'],
//       avatar: json['avatar'],
//       serviceID: json['serviceID'],
//       address: json['address'],
//       city: json['city'],
//       country: json['country'],
//       zip: json['zip'],
//       gender: json['gender'],
//       dob: json['dob'],
//       bio: json['bio'],
//       businessName: json['businessName'],
//       businessAddress: json['businessAddress'],
//       businessCity: json['businessCity'],
//       businessCountry: json['businessCountry'],
//       businessZip: json['businessZip'],
//       businessPhone: json['businessPhone'],
//       businessEmail: json['businessEmail'],
//       businessWebsite: json['businessWebsite'],
//       businessBio: json['businessBio'],
//       businessPicture: json['businessPicture'],
//       businessCategory: json['businessCategory'],
//       businessSubCategory: json['businessSub Category'],);}
  
// }

// class UserModel {
//     final String id;
//   final String name;
//   final String email;
//   final String phone;
//   final String password;
//   final String avatar;
//   final String serviceID;
//   final String address;
//   final String city;
//   final String country;
//   final String zip;
//   final String gender;
//   final String dob;
//   final String bio;
//   final String businessName;
//   final String businessAddress;
//   final String businessCity;
//   final String businessCountry;
//   final String businessZip;
//   final String businessPhone;
//   final String businessEmail;
//   final String businessWebsite;
//   final String businessBio;
//   final String businessPicture;
//   final String businessCategory;
//   final String businessSubCategory;
//   final String business;

//   UserModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.password,
//     required this.avatar,
//     required this.serviceID,
//     required this.address,
//     required this.city,
//     required this.country,
//     required this.zip,
//     required this.gender,
//     required this.dob,
//     required this.bio,
//     required this.businessName,
//     required this.businessAddress,
//     required this.businessCity,
//     required this.businessCountry,
//     required this.businessZip,
//     required this.businessPhone,
//     required this.businessEmail,
//     required this.businessWebsite,
//     required this.businessBio,
//     required this.businessPicture,
//     required this.businessCategory,
//     required this.businessSubCategory,
//     required this.business
//   });
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       phone: json['phone'],
//       password: json['password'],
//       avatar: json['avatar'],
//       serviceID: json['serviceID'],
//       address: json['address'],
//       city: json['city'],
//       country: json['country'],
//       zip: json['zip'],
//       gender: json['gender'],
//       dob: json['dob'],
//       bio: json['bio'],
//       businessName: json['businessName'],
//       businessAddress: json['businessAddress'],
//       businessCity: json['businessCity'],
//       businessCountry: json['businessCountry'],
//       businessZip: json['businessZip'],
//       businessPhone: json['businessPhone'],
//       businessEmail: json['businessEmail'],
//       businessWebsite: json['businessWebsite'],
//       businessBio: json['businessBio'],
//       businessPicture: json['businessPicture'],
//       businessCategory: json['businessCategory'],
//       businessSubCategory: json['business Sub Category'],
//       business: json['business'],
//       );


// }
// }

// class ServiceModel {
//   final String id;
//   final String title;
//   List<UserModel> users;

//   ServiceModel({
//     required this.id,
//     required this.title,
//     this.users=const [],
//   });

//   factory ServiceModel.fromJson(Map<String, dynamic> json) {
//     return ServiceModel(
//       id: json['id'],
//       title: json['title'],
//       users: json['users'],
//     );
//   }
  
// }

// [{"title":"Hairdresser","id":3,"imageUrl":"https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Frunning_shoe.svg?alt=media&token=0dcb0e57-315e-457c-89dc-1233f6421368"},
// {"title":"T-Shirts","id":5,"imageUrl":"https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Fjersey.svg?alt=media&token=6ca7eabd-54b3-47bb-bb8f-41c3a8920171"},
// {"title":"Jackets","id":4,"imageUrl":"https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Fjacket.svg?alt=media&token=ffdc9a1e-917f-4e8f-b58e-4df2e6e8587e"},
// {"title":"Dresses","id":2,"imageUrl":"https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Fdress.svg?alt=media&token=cf832383-4c8a-4ee1-9676-b66c4d515a1c"},
// {"title":"Pants","id":1,"imageUrl":"https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Fjeans.svg?alt=media&token=eb62f916-a4c2-441a-a469-5684f1a62526"}]

// List<ServiceModel> services = [
//   ServiceModel(
//       title: "Hairdresser",
//       id: "1",
//       users: [],),
//       ServiceModel
//       (id: "2", title: "Gardner",
//       users: []),
//       ServiceModel(id: "3", 
//       title: "Cleaner", 
//       users: [])

// ];




// List<Services> services = [
//   Services(
//       title: "Hairdresser",
//       id: 1,
//       users: [],
//   Categories(
//       title: "T-Shirts",
//       id: 5,
//       imageUrl:
//           "https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Fjersey.svg?alt=media&token=6ca7eabd-54b3-47bb-bb8f-41c3a8920171"),
//   Categories(
//       title: "Sneakers",
//       id: 3,
//       imageUrl:
//           "https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Frunning_shoe.svg?alt=media&token=0dcb0e57-315e-457c-89dc-1233f6421368"),
//   Categories(
//       title: "Dresses",
//       id: 2,
//       imageUrl:
//           "https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Fdress.svg?alt=media&token=cf832383-4c8a-4ee1-9676-b66c4d515a1c"),
//   Categories(
//       title: "Jackets",
//       id: 4,
//       imageUrl:
//           "https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Fjacket.svg?alt=media&token=ffdc9a1e-917f-4e8f-b58e-4df2e6e8587e")
// ];

// var products = [
//   {
//     "id": 3,
//     "title": "Converse Chuck Taylor All Star",
//     "price": 60.0,
//     "description":
//         "The classic Chuck Taylor All Star sneaker from Converse, featuring a timeless design and comfortable fit.",
//     "is_featured": true,
//     "clothesType": "kids",
//     "ratings": 4.333333333333333,
//     "colors": ["black", "white", "red"],
//     "imageUrls": [
//       "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp",
//       "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp"
//     ],
//     "sizes": ["7", "8", "9", "10", "11"],
//     "created_at": "2024-06-06T07:57:45Z",
//     "category": 3,
//     "brand": 1
//   },
//   {
//     "id": 1,
//     "title": "LV Trainers",
//     "price": 798.88,
//     "description":
//         "LV Trainers blend sleek style with athletic functionality, featuring bold logos, premium materials, and comfortable designs that elevate your everyday look with a touch of luxury.",
//     "is_featured": true,
//     "clothesType": "women",
//     "ratings": 4.5,
//     "colors": ["white", "black", "red"],
//     "imageUrls": [
//       "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp",
//       "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp"
//     ],
//     "sizes": ["7", "8", "9", "10", "11"],
//     "created_at": "2024-06-06T07:49:15Z",
//     "category": 3,
//     "brand": 1
//   },
//   {
//     "id": 2,
//     "title": "Adidas Ultraboost",
//     "price": 180.0,
//     "description":
//         "xperience the comfort and energy return of the Ultraboost, designed for running and everyday wear.",
//     "is_featured": true,
//     "clothesType": "unisex",
//     "ratings": 5.0,
//     "colors": ["navy", "grey", "blue"],
//     "imageUrls": [
//       "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp",
//       "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp"
//     ],
//     "sizes": ["7", "8", "9", "10", "11"],
//     "created_at": "2024-06-06T07:55:20Z",
//     "category": 3,
//     "brand": 1
//   }
// ];

// List<Products> products = [
//   Products(
//       id: 3,
//       title: "Converse Chuck Taylor All Star",
//       price: 60.0,
//       description:
//           "The classic Chuck Taylor All Star sneaker from Converse, featuring a timeless design and comfortable fit.",
//       isFeatured: true,
//       clothesType: "kids",
//       ratings: 4.333333333333333,
//       colors: ["black", "white", "red"],
//       imageUrls: [
//         "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp",
//         "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp"
//       ],
//       sizes: ["7", "8", "9", "10", "11"],
//       createdAt: DateTime.parse("2024-06-06T07:57:45Z"),
//       category: 3,
//       brand: 1),
//   Products(
//       id: 1,
//       title: "LV Trainers",
//       price: 798.88,
//       description:
//           "LV Trainers blend sleek style with athletic functionality, featuring bold logos, premium materials, and comfortable designs that elevate your everyday look with a touch of luxury.",
//       isFeatured: true,
//       clothesType: "women",
//       ratings: 4.5,
//       colors: ["white", "black", "red"],
//       imageUrls: [
//         "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp",
//         "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp"
//       ],
//       sizes: ["7", "8", "9", "10", "11"],
//       createdAt: DateTime.parse("2024-06-06T07:49:15Z"),
//       category: 3,
//       brand: 1),
//   Products(
//       id: 2,
//       title: "Adidas Ultraboost",
//       price: 180.0,
//       description:
//           "Experience the comfort and energy return of the Ultraboost, designed for running and everyday wear.",
//       isFeatured: true,
//       clothesType: "unisex",
//       ratings: 5.0,
//       colors: ["navy", "grey", "blue"],
//       imageUrls: [
//         "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp",
//         "https://media.cnn.com/api/v1/images/stellar/prod/220210051008-04-lv-virgil-abloh.jpg?q=w_2000,c_fill/f_webp"
//       ],
//       sizes: ["7", "8", "9", "10", "11"],
//       createdAt: DateTime.parse("2024-06-06T07:55:20Z"),
//       category: 3,
//       brand: 1)
// ];

String avatar =
    'https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Favatar.png?alt=media&token=7da81de9-a163-4296-86ac-3194c490ce15';


// class _buildtextfield extends StatelessWidget {
//   const _buildtextfield({
//     Key? key,
//     required this.hintText,
//     required this.controller,
//     required this.onSubmitted,
//     this.keyboard,
//     this.readOnly,
//   }) : super(key: key);

//   final TextEditingController controller;
//   final String hintText;
//   final TextInputType? keyboard;
//   final void Function(String)? onSubmitted;
//   final bool? readOnly;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20.0),
//       child: TextField(
//           keyboardType: keyboard,
//           readOnly: readOnly ?? false,
//           decoration: InputDecoration(
//               hintText: hintText,
//               errorBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: Kolors.kRed, width: 0.5),
//               ),
//               focusedBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: Kolors.kPrimary, width: 0.5),
//               ),
//               focusedErrorBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: Kolors.kRed, width: 0.5),
//               ),
//               disabledBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: Kolors.kGray, width: 0.5),
//               ),
//               enabledBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: Kolors.kGray, width: 0.5),
//               ),
//               border: InputBorder.none),
//           controller: controller,
//           cursorHeight: 25,
//           style: appStyle(12, Colors.black, FontWeight.normal),
//           onSubmitted: onSubmitted),
//     );
//   }
// }
