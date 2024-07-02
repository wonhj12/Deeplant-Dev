import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:structure/components/custom_pop_up.dart';
import 'package:structure/config/pallete.dart';
import 'package:structure/dataSource/remote_data_source.dart';
import 'package:structure/model/user_model.dart';

class ChangePasswordViewModel with ChangeNotifier {
  UserModel userModel;
  ChangePasswordViewModel({required this.userModel});

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  TextEditingController originPW = TextEditingController();
  TextEditingController newPW = TextEditingController();
  TextEditingController newCPW = TextEditingController();

  // 버튼 활성화 확인을 위한 변수
  bool _isValidPw = false;
  bool _isValidNewPw = false;
  bool _isValidCPw = false;

  /// 기존 비밀번호 유효성 검사
  String? pwValidate(String? value) {
    if (value!.isEmpty) {
      _isValidPw = false;
      return '비밀번호를 입력하세요.';
    } else {
      _isValidPw = true;
      return null;
    }
  }

  /// 비밀번호 유효성 검사
  String? newPwValidate(String? value) {
    // 비어있지 않고 비밀번호 형식에 맞지 않을 때, 빨간 에러 메시지
    final bool isValid = _validatePassword(value!);
    if (value.isNotEmpty && !isValid) {
      _isValidNewPw = false;
      return '영문, 숫자, 특수문자를 모두 포함해 10자 이상으로 구성해주세요.';
    } else if (value.isEmpty) {
      _isValidNewPw = false;
      return null;
    } else {
      _isValidNewPw = true;
      return null;
    }
  }

  /// 비밀번호 재입력 유효성 검사
  String? cPwValidate(String? value) {
    // 비어있지 않고 비밀번호와 같지 않을 때, 빨간 에러 메시지
    if (value!.isNotEmpty && value != newPW.text) {
      _isValidCPw = false;
      return '비밀번호가 일치하지 않습니다.';
    } else if (value.isEmpty) {
      _isValidCPw = false;
      return null;
    } else {
      _isValidCPw = true;
      return null;
    }
  }

  /// 비밀번호 유효성 검사
  bool _validatePassword(String password) {
    // 비밀번호 유효성을 검사하는 정규식
    const pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()\-_=+{};:,<.>]).{10,}$';
    final regex = RegExp(pattern);

    return regex.hasMatch(password);
  }

  /// 모든 값이 올바르게 입력됐는지 확인
  bool isAllValid() {
    if (_isValidPw && _isValidNewPw && _isValidCPw) {
      return true;
    } else {
      return false;
    }
  }

  late BuildContext _context;

  /// 비밀번호 변경 함수
  Future<void> changePassword(BuildContext context) async {
    _context = context;
    isLoading = true;
    notifyListeners();
    try {
      // 기존 firebase user 정보 불러오기 (현재 로그인된 유저)
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 비밀번호 변경 전 firebase에 재인증 필요
        await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: userModel.userId!,
            password: originPW.text,
          ),
        );
        await user.updatePassword(newPW.text); // Firebase update password
        // DB에 비밀번호 변경
        final response =
            await RemoteDataSource.changeUserPw(_convertChangeUserPwToJson());
        if (response == null) {
          throw Error();
        }
        _success();
      } else {
        print('User does not exist.');
      }
    } on FirebaseException catch (e) {
      print('error: ${e.code}');
      if (e.code == 'wrong-password') {
        _showAlert('현재 비밀번호가 일치하지 않습니다.'); // 기존 비밀번호가 틀리면 alert 생성
      } else {
        _showAlert('오류가 발생했습니다.');
      }
    }
    isLoading = false;
    notifyListeners();
  }

  /// 유저 비밀번호 변경 시 반환
  String _convertChangeUserPwToJson() {
    return jsonEncode({
      "userId": userModel.userId,
      "password": newPW.text,
    });
  }

  /// 오류 snackbar
  void _showAlert(String message) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(message),
        backgroundColor: Palette.alertBg,
      ),
    );
  }

  /// 비밀번호 변경 성공
  void _success() {
    showSuccessChangeUserInfo(_context);
    originPW.clear();
    newPW.clear();
    newCPW.clear();
    _isValidPw = false;
    _isValidNewPw = false;
    _isValidCPw = false;
  }
}