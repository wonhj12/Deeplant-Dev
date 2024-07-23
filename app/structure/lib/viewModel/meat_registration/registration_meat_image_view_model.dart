//
//
// 육류 이미지 등록 viewModel.
//
//

import 'dart:io';
import 'package:go_router/go_router.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:structure/components/custom_dialog.dart';
import 'package:structure/components/custom_pop_up.dart';
import 'package:structure/config/userfuls.dart';
import 'package:structure/dataSource/remote_data_source.dart';
import 'package:structure/model/meat_model.dart';
import 'package:structure/dataSource/local_data_source.dart';
import 'package:structure/model/user_model.dart';

class RegistrationMeatImageViewModel with ChangeNotifier {
  final MeatModel meatModel;
  final UserModel userModel;

  RegistrationMeatImageViewModel(this.meatModel, this.userModel) {
    _initialize();
  }
  bool isLoading = false;

  // 초기 변수
  String filmedAt = '-';
  String date = '-'; // 화면에 표시하는 촬영 날짜
  String userName = '-'; // 촬영자

  // 사진 관련 변수
  String? imgPath;
  File? imgFile;
  bool imgAdded = false;

  late BuildContext _context;

  /// 초기 할당
  void _initialize() async {
    isLoading = true;
    notifyListeners();

    // 임시저장/수정 데이터 불러오기
    if (meatModel.sensoryEval != null) {
      userName = meatModel.sensoryEval!['userName'];
      imgPath = meatModel.sensoryEval!['imagePath'];
      filmedAt = meatModel.sensoryEval!['filmedAt'];
      date = Usefuls.parseDate(meatModel.sensoryEval!['filmedAt']);
    }

    isLoading = false;
    notifyListeners();
  }

  /// 촬영한 이미지가 있는지 확인하는 함수
  bool imageCheck() {
    return imgPath != null;
  }

  /// 뒤로가기 버튼
  VoidCallback? backBtnPressed(BuildContext context) {
    return () => showExitDialog(context);
  }

  /// 촬영자, 촬영 날짜 설정
  void _setInfo() {
    filmedAt = Usefuls.getCurrentDate();
    date = Usefuls.parseDate(filmedAt);
    userName = userModel.name ?? '-';
  }

  /// 이미지 촬영을 위한 메소드
  /// 카메라 실행 후 촬영한 사진 경로를 받아옴
  Future<void> pickImage(BuildContext context) async {
    String? tempImgPath = await context.push('/home/registration/image/camera');

    // 반환된 사진이 있으면 저장 팝업 생성
    if (tempImgPath != null) {
      if (context.mounted) {
        showSaveImageDialog(
          context,
          tempImgPath,
          () => context.pop(),
          () {
            isLoading = true; // 로딩 활성화
            notifyListeners();

            // 정보 저장
            imgPath = tempImgPath;
            imgFile = File(tempImgPath);
            imgAdded = true;

            _setInfo();

            isLoading = false; // 로딩 비활성화
            notifyListeners();
            context.pop();
          },
        );
      }
    } else {
      // 사진 찍기 오류
      // TODO : 이미지 촬영 오류 팝업 띄우기
      debugPrint('Image error');
    }
  }

  /// 사진 초기화
  void deleteImage(BuildContext context) {
    showDeletePhotoDialog(context, () {
      imgPath = null;
      imgFile = null;
      imgAdded = false;
      date = '-';
      userName = '-';

      notifyListeners();
      context.pop();
    });
  }

  /// 데이터 등록
  Future<void> saveMeatData(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      if (meatModel.meatId == null) {
        // 새로운 이미지 등록
        meatModel.imgAdded = true; // 새로 등록할때는 항상 true
        meatModel.sensoryEval = {};
        meatModel.sensoryEval!['userId'] = userModel.userId;
        meatModel.sensoryEval!['userName'] = userModel.name;
        meatModel.sensoryEval!['imagePath'] = imgPath; // 로컬을 위한 imgagePath 저장
        meatModel.sensoryEval!['filmedAt'] = filmedAt;
        meatModel.sensoryEval!['seqno'] = 0;
      } else {
        // 이미지 수정
        meatModel.imgAdded = imgAdded;
        meatModel.sensoryEval!['imagePath'] = imgPath; // 로컬을 위한 imgagePath 저장
        meatModel.sensoryEval!['filmedAt'] = filmedAt;
        await _sendImageToFirebase();

        final response = await RemoteDataSource.patchMeatData(
            'sensory-eval', meatModel.toJsonSensory());

        if (response != 200) {
          throw Error();
        }

        // 팝업 띄우기 전에 isLoading 끄기
        isLoading = false;
        notifyListeners();
      }
      meatModel.checkCompleted();

      // 임시저장
      await tempSave();

      isLoading = false;
      notifyListeners();

      _context = context; // movePage를 위한 context 설정
      _movePage();
    } catch (e) {
      debugPrint('에러발생: $e');
    }
  }

  /// 페이지 이동
  void _movePage() {
    if (meatModel.meatId == null) {
      // 신규 등록
      _context.go('/home/registration');
    } else {
      // 원육 수정
      if (meatModel.sensoryEval!['seqno'] == 0) {
        showDataManageSucceedPopup(_context, () {
          _context.go('/home/data-manage-normal/edit');
        });
      } else {
        // 처리육 수정
        _context.go('/home/data-manage-researcher/add/processed-meat');
      }
    }
  }

  /// 이미지를 파이어베이스에 저장
  ///
  /// imgAdded가 참일 때만 파이어베이스에 업로드
  Future<void> _sendImageToFirebase() async {
    try {
      // fire storage에 육류 이미지 저장
      final refMeatImage = FirebaseStorage.instance
          .ref()
          .child('sensory_evals/${meatModel.meatId}-${meatModel.seqno}.png');

      // if (imgPath!.contains('http')) {
      //   // db 사진
      //   final http.Response response =
      //       await http.get(Uri.parse(meatModel.imagePath!));
      //   final Uint8List imageData = Uint8List.fromList(response.bodyBytes);
      //   await refMeatImage.putData(
      //     imageData,
      //     SettableMetadata(contentType: 'image/jpeg'),
      //   );
      // } else

      // 이미지가 새롭게 수정된 경우에만 firebase에 업로드
      if (imgAdded) {
        // TODO : 이미지 업데이트 확인
        await refMeatImage.putFile(
          imgFile!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      // 에러 팝업
      if (_context.mounted) showFileUploadFailPopup(_context);
    }
  }

  /// 임시저장
  Future<void> tempSave() async {
    try {
      dynamic response = await LocalDataSource.saveDataToLocal(
          meatModel.toJsonTemp(), meatModel.userId!);
      if (response == null) throw Error();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
