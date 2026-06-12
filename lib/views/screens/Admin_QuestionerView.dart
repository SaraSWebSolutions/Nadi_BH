import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/providers/AdminQuestionRequest_Provider.dart';
import 'package:nadi_user_app/providers/AdminQuestioner_Provider.dart';
import 'package:nadi_user_app/providers/pointshistory_provider.dart';
import 'package:nadi_user_app/services/admin_questioner.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/buttons/primary_button.dart';

class AdminQuestionerview extends ConsumerStatefulWidget {
  const AdminQuestionerview({super.key});

  @override
  ConsumerState<AdminQuestionerview> createState() =>
      _AdminQuestionerviewState();
}

class _AdminQuestionerviewState extends ConsumerState<AdminQuestionerview>
    with SingleTickerProviderStateMixin {
  final Map<int, int> selectedAnswers = {};
  final Map<int, TextEditingController> inputControllers = {};

  final AdminQuestioner adminQuestioner = AdminQuestioner();

  int currentQuestionIndex = 0;
  String? errorMessage;

  bool isSuccess = false;
  bool isSubmitting = false;
  String successMessage = "";
  String pointsEarned = "";
  String totalUserPoints = "";

  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeAnimation;
  final Map<int, String?> inputErrors = {};
  final Map<int, String?> chooseErrors = {};
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.refresh(fetchadminquestionrequestprovider);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    );
  }

  // void nextQuestion(int totalQuestions, questions) {
  //   final currentQuestion = questions[currentQuestionIndex];

  //   bool isValid = false;

  //   if (currentQuestion.type == "choose") {
  //     isValid = selectedAnswers.containsKey(currentQuestionIndex);
  //   } else if (currentQuestion.type == "input") {
  //     isValid =
  //         inputControllers[currentQuestionIndex]?.text.trim().isNotEmpty ??
  //         false;
  //   }

  //   if (!isValid) {
  //     final loc = AppLocalizations.of(context)!;
  //     setState(() {
  //       errorMessage = loc.pleaseAnswerBeforeNext;
  //     });
  //     return;
  //   }

  //   setState(() {
  //     errorMessage = null;
  //     if (currentQuestionIndex < totalQuestions - 1) {
  //       currentQuestionIndex++;
  //     }
  //   });
  // }
  void nextQuestion(int totalQuestions, questions) {
    final currentQuestion = questions[currentQuestionIndex];

    bool isValid = true;

    if (currentQuestion.type == "choose") {
      isValid = selectedAnswers.containsKey(currentQuestionIndex);
    } else if (currentQuestion.type == "input") {
      final text = inputControllers[currentQuestionIndex]?.text.trim() ?? "";

      if (text.isEmpty) {
        isValid = false;
        inputErrors[currentQuestionIndex] =
            AppLocalizations.of(context)!.fieldCannotBeEmpty;
      } else {
        inputErrors[currentQuestionIndex] = null;
      }
    }

    if (!isValid) {
      setState(() {});
      return;
    }

    setState(() {
      errorMessage = null;
      if (currentQuestionIndex < totalQuestions - 1) {
        currentQuestionIndex++;
      }
    });
  }

  void previousQuestion() {
    setState(() {
      errorMessage = null;
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      }
    });
  }

  Future<void> submitQuestions(List questions, String questionnaireId) async {
    final loc = AppLocalizations.of(context)!;

    // 🔥 CLEAR OLD ERRORS FIRST
    setState(() {
      inputErrors.clear();
      errorMessage = null;
    });

    // 🔴 VALIDATION PHASE
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];

      // ❌ INPUT VALIDATION
      if (q.type == "input") {
        final text = inputControllers[i]?.text.trim() ?? "";

        if (text.isEmpty) {
          setState(() {
            currentQuestionIndex = i;
            inputErrors[i] = loc.fieldCannotBeEmpty;
          });
          return;
        }
      }

      // ❌ CHOOSE VALIDATION
      if (q.type == "choose") {
        if (!selectedAnswers.containsKey(i)) {
          setState(() {
            currentQuestionIndex = i;
            chooseErrors[i] = loc.pleaseSelectAnOption;
          });
          return;
        } else {
          chooseErrors[i] = null;
        }
      }
    }

    // 🔥 START LOADING ONLY AFTER VALIDATION PASSES
    setState(() {
      isSubmitting = true;
    });

    try {
      List<Map<String, dynamic>> answers = [];

      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];

        if (question.type == "choose") {
          answers.add({
            "questionIndex": i,
            "selectedOption": selectedAnswers[i],
          });
        } else {
          answers.add({
            "questionIndex": i,
            "selectedOption": inputControllers[i]?.text.trim() ?? "",
          });
        }
      }

      final payload = {"questionnaireId": questionnaireId, "answers": answers};

      final response = await adminQuestioner.submitquestiondatas(
        payload: payload,
      );

      setState(() {
        isSuccess = true;
        successMessage =
            response["message"] ??
            AppLocalizations.of(context)!.submittedSuccessfully;
        pointsEarned = response["pointsEarned"].toString();
        totalUserPoints = response["totalUserPoints"].toString();
      });

      _controller?.forward();

      ref.refresh(fetchadminquestionerprovider);
      ref.refresh(pointshistoryprovider);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminRequest = ref.watch(fetchadminquestionrequestprovider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.gold_coin,
        elevation: 0,
        centerTitle: true,
        title: Text(
          loc.qaConversation,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 38,
              height: 38,
              child: FittedBox(
                child: AppCircleIconButton(
                  icon: Icons.arrow_back,
                  color: const Color(0xFFF6C956),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ),
      ),
      body: isSuccess
          ? successUI()
          : adminRequest.when(
              data: (response) {
                final adminList = response.data;

                if (adminList.isEmpty) {
                  return Center(child: Text(loc.noAdminQuestions));
                }

                // Filter only items that have questionnaire
                final validItems = adminList
                    .where((item) => item.questionnaireId != null)
                    .toList();

                if (validItems.isEmpty) {
                  return Center(child: Text(loc.noQuestionsAvailable));
                }

                final questionnaire = validItems.first.questionnaireId!;

                if (questionnaire.questions.isEmpty) {
                  return Center(child: Text(loc.noQuestionsAvailable));
                }

                final questions = questionnaire.questions;

                final totalQuestions = questions.length;
                final currentQuestion = questions[currentQuestionIndex];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        loc.questionProgress(
                          (currentQuestionIndex + 1).toString(),
                          totalQuestions.toString(),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// QUESTION CARD
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 40,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentQuestion.question,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                /// TYPE BASED UI
                                /// TYPE BASED UI
                                if (currentQuestion.type == "choose") ...[
                                  ...List.generate(currentQuestion.options.length, (
                                    index,
                                  ) {
                                    final isSelected =
                                        selectedAnswers[currentQuestionIndex] ==
                                        index;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedAnswers[currentQuestionIndex] =
                                              index;

                                          chooseErrors[currentQuestionIndex] =
                                              null;
                                          errorMessage =
                                              null; // 🔥 IMPORTANT FIX
                                        });
                                      },
                                      // onTap: () {
                                      //   setState(() {
                                      //     selectedAnswers[currentQuestionIndex] =
                                      //         index;
                                      //     chooseErrors[currentQuestionIndex] =
                                      //         null;
                                      //   });
                                      // },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.gold_coin.withOpacity(
                                                  isDark ? 0.25 : 0.1,
                                                )
                                              : (isDark
                                                    ? Theme.of(
                                                        context,
                                                      ).colorScheme.surface
                                                    : Colors.white),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.gold_coin
                                                : (isDark
                                                      ? Colors.grey.shade700
                                                      : Colors.grey.shade300),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                currentQuestion.options[index],
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),

                                  /// ✅ ERROR MUST BE INSIDE SAME BLOCK
                                  if (chooseErrors[currentQuestionIndex] !=
                                      null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        chooseErrors[currentQuestionIndex]!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ] else if (currentQuestion.type == "input")
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: inputControllers
                                            .putIfAbsent(
                                              currentQuestionIndex,
                                              () => TextEditingController(),
                                            ),
                                        onChanged: (value) {
                                          if (value.trim().isNotEmpty) {
                                            inputErrors[currentQuestionIndex] =
                                                null;
                                            setState(() {});
                                          }
                                        },
                                        keyboardType: TextInputType.multiline,
                                        minLines: 3,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          hintText: loc.enterYourAnswer,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),

                                      if (inputErrors[currentQuestionIndex] !=
                                          null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          inputErrors[currentQuestionIndex]!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                if (errorMessage != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// NAVIGATION BUTTONS
                      Row(
                        children: [
                          if (currentQuestionIndex > 0)
                            Expanded(
                              child: AppButton(
                                height: 47,
                                text: loc.previous,
                                color: Colors.grey,
                                width: double.infinity,
                                onPressed: previousQuestion,
                              ),
                            ),
                          if (currentQuestionIndex > 0)
                            const SizedBox(width: 10),
                          Expanded(
                            child: isSubmitting
                                ? Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: AppColors.gold_coin,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                : AppButton(
                                    height: 47,
                                    text:
                                        currentQuestionIndex ==
                                            totalQuestions - 1
                                        ? loc.submit
                                        : loc.next,
                                    width: double.infinity,
                                    color: AppColors.gold_coin,
                                    onPressed: () {
                                      if (currentQuestionIndex ==
                                          totalQuestions - 1) {
                                        submitQuestions(
                                          questions,
                                          questionnaire.id,
                                        );
                                      } else {
                                        nextQuestion(totalQuestions, questions);
                                      }
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
    );
  }

  Widget successUI() {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FadeTransition(
          opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1),
          child: ScaleTransition(
            scale: _scaleAnimation ?? const AlwaysStoppedAnimation(1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 90, color: Colors.green),
                const SizedBox(height: 20),
                Text(
                  loc.success,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(successMessage, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Text(
                  loc.pointsEarnedLabel(pointsEarned),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold_coin,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.totalPointsLabel(totalUserPoints),
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 30),
                AppButton(
                  text: loc.done,
                  color: AppColors.gold_coin,
                  onPressed: () => context.pop(),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
