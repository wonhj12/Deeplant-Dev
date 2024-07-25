//
//
// 원육 추가 페이지(View) : Researcher
//
//

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:structure/components/custom_app_bar.dart';
import 'package:structure/components/custom_scroll.dart';
import 'package:structure/components/main_button.dart';
import 'package:structure/components/step_card.dart';
import 'package:structure/model/meat_model.dart';
import 'package:structure/viewModel/data_management/researcher/add_raw_meat_view_model.dart';

class AddRawMeatScreen extends StatelessWidget {
  final MeatModel meatModel;
  const AddRawMeatScreen({super.key, required this.meatModel});

  @override
  Widget build(BuildContext context) {
    AddRawMeatViewModel addRawMeatViewModel =
        context.watch<AddRawMeatViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '추가 정보 입력',
        backButton: true,
        closeButton: false,
      ),
      body: ScrollConfiguration(
        behavior: CustomScroll(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 육류 기본 정보
              StepCard(
                onTap: () => addRawMeatViewModel.clicekdBasic(context),
                mainText: '원육 기본정보',
                status: 4, // 없음
                imageUrl: 'assets/images/meat_info.png',
              ),
              SizedBox(height: 10.h),

              // 육류 단면 촬영
              StepCard(
                mainText: '원육 단면 촬영',
                status: 4, // 없음
                onTap: () => addRawMeatViewModel.clickedBasicImage(context),
                imageUrl: 'assets/images/meat_image.png',
              ),
              SizedBox(height: 10.h),

              // 신선육 관능 평가
              StepCard(
                mainText: '원육 관능평가',
                status: 4, // 없음
                onTap: () => addRawMeatViewModel.clicekdFresh(context),
                imageUrl: 'assets/images/meat_eval.png',
              ),
              SizedBox(height: 10.h),

              StepCard(
                mainText: '원육 전자혀 데이터',
                status: meatModel.tongueCompleted ? 1 : 2,
                onTap: () => addRawMeatViewModel.clickedTongue(context),
                imageUrl: 'assets/images/meat_tongue.png',
              ),
              SizedBox(height: 10.h),

              StepCard(
                mainText: '원육 실험 데이터',
                status: meatModel.labCompleted ? 1 : 2,
                onTap: () => addRawMeatViewModel.clickedLab(context),
                imageUrl: 'assets/images/meat_lab.png',
              ),
              SizedBox(height: 10.h),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                child: const Divider(
                  color: Color.fromARGB(255, 155, 155, 155),
                  thickness: 1,
                ),
              ),

              // 가열육 단면촬영 체크하는 변수 meatModel의 변수 추가하고 변경
              StepCard(
                mainText: '가열육 단면 촬영',
                status: meatModel.heatedImageCompleted ? 1 : 2,
                onTap: () => addRawMeatViewModel.clickedImage(context),
                imageUrl: 'assets/images/meat_image.png',
              ),
              SizedBox(height: 10.h),

              StepCard(
                mainText: '가열육 관능평가',
                status: meatModel.heatedSensoryCompleted ? 1 : 2,
                onTap: () => addRawMeatViewModel.clickedHeated(context),
                imageUrl: 'assets/images/meat_eval.png',
              ),
              SizedBox(height: 10.h),

              StepCard(
                mainText: '가열육 전자혀 데이터',
                status: meatModel.heatedTongueCompleted ? 1 : 2,
                onTap: () => addRawMeatViewModel.clickedHeatedTongue(context),
                imageUrl: 'assets/images/meat_tongue.png',
              ),
              SizedBox(height: 10.h),

              StepCard(
                mainText: '가열육 실험 데이터',
                status: meatModel.heatedLabCompleted ? 1 : 2,
                onTap: () => addRawMeatViewModel.clickedHeatedLab(context),
                imageUrl: 'assets/images/meat_lab.png',
              ),
              SizedBox(height: 10.h),

              Container(
                margin: EdgeInsets.only(bottom: 20.h),
                child: MainButton(
                  onPressed: () async {
                    addRawMeatViewModel.clickedbutton(context, meatModel);
                  },
                  text: '완료',
                  width: 658.w,
                  height: 104.h,
                  mode: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
