import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_application_2/common/controller/registration/address_id_doc_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'profile_photo_capture/video_capture_screen.dart';

class SPAddressDocumentScreen extends StatefulWidget {
  
  const SPAddressDocumentScreen({super.key});

  @override
  State<SPAddressDocumentScreen> createState() =>
      _SPAddressDocumentScreenState();
}

class _SPAddressDocumentScreenState extends State<SPAddressDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _unitNumberCtrl = TextEditingController();
  String _buildingType = "house"; 

CameraController? _cameraController;

XFile? _livenessVideo;
bool _isRecording = false;
bool _cameraReady = false;

  final List<String> _buildingOptions = ["house", "apartment", "office"];
  String _idType = "card"; 
  File? _frontFile;
  File? _backFile;
  Map<String, dynamic>? _fullAddressMap;
  final _picker = ImagePicker();
  static final String kGoogleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  final _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  @override
void initState() {
  super.initState();
  
}


  




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

     
      for (var component in details.result.addressComponents) {
        var types = component.types;
        if (types.contains('street_number')) {
          addressData['street_number'] = component.longName;
        }
        if (types.contains('route')) addressData['route'] = component.longName;
        if (types.contains('locality')) {
          addressData['locality'] = component.longName;
        }
        if (types.contains('administrative_area_level_1')) {
          addressData['administrative_area_level_1'] = component.longName;
        }
        if (types.contains('country')) {
          addressData['country'] = component.longName;
        }
        if (types.contains('postal_code')) {
          addressData['postal_code'] = component.longName;
        }
      }

      setState(() {
        _addressCtrl.text = details.result.formattedAddress ?? "";
        
        _fullAddressMap = addressData;
      });
    }
  }

  Future<void> _showImageSourceOptions(bool isFront) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.r),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select ID Document",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceItem(
                    icon: Feather.camera,
                    label: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, isFront);
                    },
                  ),
                  _buildSourceItem(
                    icon: Feather.image,
                    label: "Gallery",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, isFront);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
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

                        SizedBox(height: 16.h),
                        _buildSectionTitle("BUILDING TYPE", Feather.home),
                        _buildBuildingTypeDropdown(),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _unitNumberCtrl,
                          // Contextual hint based on selection
                          hint: _buildingType == "house"
                              ? "Apartment / Unit Number (Required)"
                              : "Apartment / Unit Number (Optional)",
                          icon: Feather.hash,

                          validator: (val) {
                            if (_buildingType == "apartment" &&
                                (val == null || val.isEmpty)) {
                              return "Required for apartments";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 32.h),
                        _buildSectionTitle(
                          "IDENTITY VERIFICATION",
                          Feather.shield,
                        ),
                        Text(
                          "Upload a clear photo of your National ID for security verification.",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildSectionTitle(
                          "SELECT ID TYPE",
                          Feather.credit_card,
                        ),
                        _buildIDTypeSelector(),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            _buildUploadTile(
                              title: "Front Side",
                              file: _frontFile,
                              onTap: () => _showImageSourceOptions(true),
                            ),
                            if (_idType == "card") ...[
                              SizedBox(width: 16.w),
                              _buildUploadTile(
                                title: "Back Side",
                                file: _backFile,
                                onTap: () => _showImageSourceOptions(false),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildSectionTitle("LIVENESS CHECK", Feather.camera),
Text(
  "We need to confirm you're physically present.",
  style: TextStyle(color: Colors.white38, fontSize: 13.sp),
),
SizedBox(height: 16.h),

_buildLivenessVideoTile(),
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



  Widget _buildLivenessVideoTile() {
  return GestureDetector(
onTap: () async {
  final result = await Navigator.push<XFile?>(
    context,
    MaterialPageRoute(
      builder: (_) => const LivenessCaptureScreen(),
    ),
  );

  if (result != null) {
    setState(() {
      _livenessVideo = result;
    });
  }
},
    child: Container(
      height: 180.h,
      decoration: BoxDecoration(
        color: _livenessVideo != null
            ? Colors.green.withOpacity(0.05)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _livenessVideo != null
              ? Colors.greenAccent.withOpacity(0.3)
              : Colors.white10,
        ),
      ),
      child: Center(
        child: _isRecording
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 10.h),
                  const Text(
                    "Recording liveness video...",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _livenessVideo != null
                        ? Feather.check_circle
                        : Feather.video,
                    color: _livenessVideo != null
                        ? Colors.greenAccent
                        : Colors.white38,
                    size: 32.sp,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    _livenessVideo != null
                        ? "Liveness captured"
                        : "Tap to record 4s liveness video",
                    style: const TextStyle(color: Colors.white),
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

  Widget _buildBuildingTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _buildingType,
          dropdownColor: const Color(0xFF1A1A1A), // Matches your dark gradient
          isExpanded: true,
          icon: const Icon(
            Feather.chevron_down,
            color: Colors.white54,
            size: 18,
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontFamily: 'Regular',
          ),
          items: _buildingOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.toUpperCase(),
                style: const TextStyle(letterSpacing: 1.1),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _buildingType = newValue!;
            });
            // Re-validate the form automatically when the type changes
            // This clears or shows the unit_number error immediately
            _formKey.currentState?.validate();
          },
        ),
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

  Future<void> _pickImage(ImageSource source, bool isFront) async {
  try {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (picked != null) {
      HapticFeedback.lightImpact();

      setState(() {
        if (isFront) {
          _frontFile = File(picked.path);
        } else {
          _backFile = File(picked.path);
        }
      });
    }
  } catch (e) {
    _showFlushbar("Permission denied or failed to pick image", isError: true);


  }
}

  Widget _buildSourceItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 25.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
          ),
        ),
      ],
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

  

  Widget _buildIDTypeSelector() {
    return Row(
      children: [
        _idTypeButton("ID Card", "card"),
        SizedBox(width: 12.w),
        _idTypeButton("Green Book", "greenbook"),
      ],
    );
  }

  Widget _idTypeButton(String label, String value) {
    bool isSelected = _idType == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _idType = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white10,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Kolors.kPrimary : Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
  

  Widget _buildUploadTile({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    bool hasFile = file != null;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120.h,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasFile ? Feather.check_circle : Feather.camera,
                color: hasFile ? Colors.greenAccent : Colors.white38,
                size: 28.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
          backgroundColor: Kolors.kPrimary,
          foregroundColor: Kolors.kOffWhite,
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

  // SPAddressDocumentScreen.dart

Future<void> _submitAddressDocument() async {
  // 1. Basic Form Validation
  if (!_formKey.currentState!.validate()) {
  HapticFeedback.vibrate(); 
  return;
}

  // 2. Custom Logic Validation (The "Plug" specific checks)
  if (_fullAddressMap == null) {
    _showError("Please search and select a verified Google address.");
    return;
  }

  if (_frontFile == null) {
    _showError("A photo of the front of your ID is required.");
    return;
  }

  if (_idType == "card" && _backFile == null) {
    _showError("For Smart Cards, please upload the back side.");
    return;
  }

  HapticFeedback.heavyImpact(); // Signal start of process

  final finalAddress = Map<String, dynamic>.from(_fullAddressMap!);
  finalAddress["unit_number"] = _unitNumberCtrl.text.trim();
  finalAddress["building_type"] = _buildingType;

  final success = await context
    .read<SPAddressDocumentController>()
    .addAddressAndDocument(
      
      address: finalAddress,
      idType: _idType,
      frontFile: _frontFile,
      backFile: _backFile,

      // 🔥 ADD THIS
      livenessVideo: _livenessVideo != null
          ? File(_livenessVideo!.path)
          : null,
    );

  if (success && mounted) {
    context.go('/sp_select_service');
  } else if (mounted) {
    final errorMsg = context.read<SPAddressDocumentController>().errorMessage;
    _showError(errorMsg ?? "Registration failed. Try again.");
  }
}

// Replaces your old _showSnackBar with a much better Flushbar
void _showError(String message) {
  HapticFeedback.vibrate();
  FlushbarService.error(
    context,
    message,
    duration: const Duration(seconds: 4),
  );
}

void _showFlushbar(String message, {bool isError = false}) {
  if (isError) {
    FlushbarService.error(
      context,
      message,
    );
  } else {
    FlushbarService.success(
      context,
      message,
    );
  }
}
}
