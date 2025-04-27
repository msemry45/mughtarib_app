@echo off
REM إنشاء هيكل المجلدات داخل lib

mkdir lib
mkdir lib\models
mkdir lib\services
mkdir lib\screens
mkdir lib\widgets

REM إنشاء ملفات النماذج (models)
type nul > lib\models\student_model.dart
type nul > lib\models\property_model.dart
type nul > lib\models\host_family_model.dart
type nul > lib\models\real_estate_office_model.dart
type nul > lib\models\review_model.dart
type nul > lib\models\message_model.dart
type nul > lib\models\university_clinic_model.dart
type nul > lib\models\login_model.dart

REM إنشاء ملفات الخدمات (services)
type nul > lib\services\api_service.dart
type nul > lib\services\auth_service.dart

REM إنشاء ملفات الشاشات (screens)
type nul > lib\screens\login_screen.dart
type nul > lib\screens\home_screen.dart
type nul > lib\screens\student_screen.dart
type nul > lib\screens\property_screen.dart
type nul > lib\screens\messages_screen.dart

REM إنشاء ملفات الويجتس (widgets)
type nul > lib\widgets\custom_widget.dart

echo هيكل المشروع تم إنشاؤه بنجاح.
pause
