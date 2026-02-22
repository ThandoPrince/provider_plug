import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/controller/registration/address_id_doc_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SPAddressDocumentScreen extends StatefulWidget {
  final String email;
  const SPAddressDocumentScreen({super.key, required this.email});
  

  @override
  State<SPAddressDocumentScreen> createState() =>
      _SPAddressDocumentScreenState();
}

class _SPAddressDocumentScreenState extends State<SPAddressDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _unitNumberCtrl = TextEditingController();
  File? _documentFile;
  String? _documentName;
Map<String, dynamic>? _fullAddressMap;
  final _picker = ImagePicker();
  static final String kGoogleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  final _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  

  Future<void> _pickAddress() async {
  Prediction? p = await PlacesAutocomplete.show(
    context: context,
    apiKey: kGoogleApiKey,
    mode: Mode.overlay,
    types: ["address"],
    components: [Component(Component.country, "za")],
    logo: const SizedBox.shrink(),
  );

  if (p != null) {
    final details = await _places.getDetailsByPlaceId(p.placeId!);
    
    // Create a map to hold the detailed parts
    Map<String, dynamic> addressData = {
      "place_id": p.placeId,
      "formatted_address": details.result.formattedAddress,
      "latitude": details.result.geometry?.location.lat,
      "longitude": details.result.geometry?.location.lng,
    };

    // Extract components (street, city, province, etc.)
    for (var component in details.result.addressComponents) {
      var types = component.types;
      if (types.contains('street_number')) addressData['street_number'] = component.longName;
      if (types.contains('route')) addressData['route'] = component.longName;
      if (types.contains('locality')) addressData['locality'] = component.longName;
      if (types.contains('administrative_area_level_1')) addressData['administrative_area_level_1'] = component.longName;
      if (types.contains('country')) addressData['country'] = component.longName;
      if (types.contains('postal_code')) addressData['postal_code'] = component.longName;
    }

    setState(() {
      _addressCtrl.text = details.result.formattedAddress ?? "";
      // Store the full map in a state variable to use during submission
      _fullAddressMap = addressData; 
    });
  }
}

  Future<void> _pickDocument() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _documentFile = File(picked.path);
        _documentName = picked.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SPAddressDocumentController>();

    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Kolors.kPrimary, Color(0xFF121212)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        _buildSectionTitle(
                          "RESIDENTIAL ADDRESS",
                          Feather.map_pin,
                        ),
                        _buildAddressField(),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _unitNumberCtrl,
                          hint: "Apartment / Unit Number (Optional)",
                          icon: Feather.home,
                        ),
                        SizedBox(height: 32.h),
                        _buildSectionTitle(
                          "IDENTITY VERIFICATION",
                          Feather.shield,
                        ),
                        Text(
                          "Upload a clear photo of your National ID or Passport for security verification.",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildUploadZone(),
                        SizedBox(height: 40.h),
                        _buildSubmitButton(ctrl),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Feather.chevron_left, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "Security & Address",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return InkWell(
      onTap: _pickAddress,
      borderRadius: BorderRadius.circular(16.r),
      child: IgnorePointer(
        child: _buildTextField(
          controller: _addressCtrl,
          hint: "Search for your address...",
          icon: Feather.search,
          validator: (val) => val!.isEmpty ? "Address required" : null,
        ),
      ),
    );
  }

  Widget _buildUploadZone() {
    bool hasFile = _documentFile != null;
    return GestureDetector(
      onTap: _pickDocument,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: hasFile
              ? Colors.green.withOpacity(0.05)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: hasFile
                ? Colors.greenAccent.withOpacity(0.3)
                : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Feather.check_circle : Feather.upload_cloud,
              color: hasFile ? Colors.greenAccent : Colors.white38,
              size: 40.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              hasFile ? "Document Selected" : "Tap to upload document",
              style: TextStyle(
                color: hasFile ? Colors.greenAccent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            if (hasFile)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  _documentName ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white24, fontSize: 14.sp),
        prefixIcon: Icon(icon, color: Colors.white54, size: 18.sp),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(SPAddressDocumentController ctrl) {
    return SizedBox(
      width: double.infinity,
      height: 58.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Kolors.kPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          elevation: 0,
        ),
        onPressed: ctrl.isLoading ? null : _submitAddressDocument,
        child: ctrl.isLoading
            ? const CircularProgressIndicator(color: Kolors.kPrimary)
            : Text(
                "COMPLETE REGISTRATION",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  // --- Logic ---

  Future<void> _submitAddressDocument() async {
  if (!_formKey.currentState!.validate() || _fullAddressMap == null) return;
  if (_documentFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload an ID document")));
    return;
  }

  // Merge the manual inputs (unit number) into the Google data
  final finalAddress = Map<String, dynamic>.from(_fullAddressMap!);
  finalAddress["unit_number"] = _unitNumberCtrl.text.trim();
  finalAddress["building_type"] = "house"; // Or a dropdown selection

  final success = await context.read<SPAddressDocumentController>().addAddressAndDocument(
    email: widget.email,
    address: finalAddress, // This now contains all 10+ fields
    documentFile: _documentFile,
    documentName: _documentName,
  );

  if (success && mounted) {
    context.go('/sp_select_service/${widget.email}');
  }
}
}
