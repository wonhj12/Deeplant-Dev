//
//
// 육류 등록 수정 | 확인 페이지(View) : Normal
//
//
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:structure/components/custom_app_bar.dart';
import 'package:structure/components/round_button.dart';
import 'package:structure/components/step_card.dart';
import 'package:structure/config/pallete.dart';
import 'package:structure/viewModel/data_management/normal/edit_meat_data_view_model.dart';

class EditMeatDataScreen extends StatelessWidget {
  const EditMeatDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: '${context.read<EditMeatDataViewModel>().meatModel.id}',
          backButton: true,
          closeButton: false),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 48.h),

            // 육류 기본 정보
            InkWell(
              onTap: () =>
                  context.read<EditMeatDataViewModel>().clicekdBasic(context),
              child: StepCard(
                mainText: '육류 기본정보',
                status: context.read<EditMeatDataViewModel>().isNormal
                    ? context.read<EditMeatDataViewModel>().isEditable
                        ? 3 // 수정 가능
                        : 4 // 수정 불가
                    : null, // 없음
                imageUrl: 'assets/images/meat_info.png',
              ),
            ),
            SizedBox(height: 18.h),

            // 육류 단면 촬영
            InkWell(
              onTap: () =>
                  context.read<EditMeatDataViewModel>().clickedImage(context),
              child: StepCard(
                mainText: '육류 단면 촬영',
                status: context.read<EditMeatDataViewModel>().isNormal
                    ? context.read<EditMeatDataViewModel>().isEditable
                        ? 3 // 수정 가능
                        : 4 // 수정 불가
                    : null, // 없음
                // isEditable: context.read<EditMeatDataViewModel>().isEditable,
                imageUrl: 'assets/images/meat_image.png',
              ),
            ),
            SizedBox(height: 18.h),

            // 신선육 관능 평가
            InkWell(
              onTap: () =>
                  context.read<EditMeatDataViewModel>().clicekdFresh(context),
              child: StepCard(
                mainText: '신선육 관능평가',
                status: context.read<EditMeatDataViewModel>().isNormal
                    ? context.read<EditMeatDataViewModel>().isEditable
                        ? 3 // 수정 가능
                        : 4 // 수정 불가
                    : null, // 없음
                imageUrl: 'assets/images/meat_eval.png',
              ),
            ),

            const Spacer(),

            // 연구자 신분 + 승인되지 않은 데이터일때만
            if (context.read<EditMeatDataViewModel>().showAcceptBtn())
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundButton(
                    onPress: () {
                      context
                          .read<EditMeatDataViewModel>()
                          .rejectMeatData(context);
                    },
                    text: Text('반려', style: Palette.fieldPlaceHolderWhite),
                    bgColor: Palette.alertColor,
                    width: 310.w,
                    height: 96.h,
                  ),
                  SizedBox(width: 20.w),
                  RoundButton(
                    onPress: () {
                      context
                          .read<EditMeatDataViewModel>()
                          .acceptMeatData(context);
                    },
                    text: Text('승인', style: Palette.fieldPlaceHolderWhite),
                    bgColor: Palette.checkSpeciesColor,
                    width: 310.w,
                    height: 96.h,
                  ),
                ],
              ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
