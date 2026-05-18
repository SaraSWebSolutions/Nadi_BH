import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/models/Questioner_Model.dart';
import 'package:nadi_user_app/services/Questioner_Service.dart';

final fetchquestionsdataprovider = StreamProvider.autoDispose<Questioner>((
  ref,
) async* {
  while (true) {
    try {
      final result = await QuestionerService().fetchquestionsdata();
      yield result;
    } catch (e) {
      // optional error handling
    }

    await Future.delayed(const Duration(seconds: 20));
  }
});
