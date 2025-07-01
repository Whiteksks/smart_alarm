import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'exercises/debug_widget.dart';
import 'exercises/exercises.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late Interpreter _interpreter;

  double _x = 0, _y = 0, _z = 0;

  final List<double> _squatList = [];
  final List<double> _lungeList = [];
  final List<double> _raiseArmList = [];


  final List<String> _debugHistory = [];
  Map<int, String> exerciseInfo = {
    0: "Squat",
    1: "Lunge",
    2: "RaiseArm"
  };
  Map<int, int> exerciseCount = {
    0: 0,
    1: 0,
    2: 0
  };

  int numberOfExercise = 0;
  int targetReps = 3;
  int currentReps = 0;

  Timer? _timer;
  UserAccelerometerEvent? _lastEvent;


  @override
  void initState() {
    super.initState();
    loadModel();
    userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      _lastEvent = event;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 250), (Timer t) {
      if (_lastEvent != null) {
        setState(() {
          _x = double.parse(_lastEvent!.x.toStringAsFixed(2));
          _y = double.parse(_lastEvent!.y.toStringAsFixed(2));
          _z = double.parse(_lastEvent!.z.toStringAsFixed(2));

          switch (numberOfExercise) {
            case 0:
              squatExercise(_x, _y, _z);
              break;
            case 1:
              lungeExercise(_x, _y, _z);
              break;
            case 2:
              raiseArmExercise(_x, _y, _z);
              break;
            case 3:
              creativeMode(_x, _y, _z);
              break;
          }
        });
      }
    });
  }
  void creativeMode(double x, double y, double z) {
    _squatList.addAll([x, y, z]);

    if (_squatList.length >= 18) {
      List<double> recentSquatData = _squatList.sublist(_squatList.length - 18);
      _debugHistory.add("$recentSquatData \n");

      _squatList.clear();
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    _interpreter.close();
  }
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      if (kDebugMode) {
        print('Модель загружена успешно');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка загрузки модели: $e');
      }
    }
  }


  late double maxPercentPredict;
  late int predictedClass;

  void predictExercise(var input, var output){
    List<double> outputList = [];
    _interpreter.run(input, output);

    for (var i = 0; i < output[0].length; i++) {
      //_debugHistory.add("${exerciseInfo[i]}: ${output[0][i]} \n");
      outputList.add(output[0][i]);

      if (kDebugMode) {
        print('Predicted value for class ${exerciseInfo[i]}: ${output[0][i]}');
      }
    }
    maxPercentPredict = outputList.reduce(max);
    predictedClass = outputList.indexOf(maxPercentPredict);
    _debugHistory.add("$maxPercentPredict $predictedClass");

    if (maxPercentPredict >= 0.90) {
      if (exerciseCount.containsKey(predictedClass) &&
          exerciseInfo[predictedClass] == exerciseInfo[numberOfExercise]) {
        setState(() {
          exerciseCount[predictedClass] =
              exerciseCount[predictedClass]! + 1;

          if (exerciseCount[predictedClass]! >= targetReps) {
            completedExercises[predictedClass] = true;
            numberOfExercise = (numberOfExercise + 1) % exerciseInfo.length;
          }
        });
      }
    }

  }

  bool _isProcessingSquat = false;
  bool _isProcessingLunge = false;
  bool _isProcessingRaiseArm = false;

  void squatExercise(double x, double y, double z) {
    if (_isProcessingSquat) return;

    _squatList.addAll([x, y, z]);

    if (_squatList.length >= 18) {
      List<double> recentSquatData = _squatList.sublist(_squatList.length - 18);

      for (int i = 2; i <= recentSquatData.length - 1; i += 3) {
        if (recentSquatData[i - 2] <= 1.5 && recentSquatData[i - 2] >= -1.5 &&
            recentSquatData[i] <= 1 && recentSquatData[i] > -1) {

          recentSquatData[i-2]=0;
          recentSquatData[i]=0;

          if (recentSquatData[i - 1] >= 1) {

            _debugHistory.add("Squat $recentSquatData \n");

            var input = recentSquatData.reshape([1, 6, 3]);
            var output = List.filled(3, 0.0).reshape([1, 3]);
            predictExercise(input, output);

            _isProcessingSquat = true;
            Future.delayed(const Duration(seconds: 1), () {
              _isProcessingSquat = false;
            });

            break;
          }
        }
      }
      _squatList.clear();
    }
  }

  void lungeExercise(double x, double y, double z) {
    if (_isProcessingLunge) return;

    _lungeList.addAll([x, y, z]);

    if (_lungeList.length >= 18) {
      List<double> recentLungeData = _lungeList.sublist(_lungeList.length - 18);

      for (int i = 2; i <= recentLungeData.length - 1; i += 3) {
        if (recentLungeData[i - 2] <= 1 && recentLungeData[i - 2] >= -1 && recentLungeData[i - 1] <= 0) {
          recentLungeData[i-2]=0;
          if (recentLungeData[i] <= -1) {

            _debugHistory.add("Lunge $recentLungeData \n");

            var input = recentLungeData.reshape([1, 6, 3]);
            var output = List.filled(3, 0.0).reshape([1, 3]);
            predictExercise(input, output);

            _isProcessingLunge = true;
            Future.delayed(const Duration(seconds: 1), () {
              _isProcessingLunge = false;
            });

            break;
          }
        }
      }
      _lungeList.clear();
    }
  }

  void raiseArmExercise(double x, double y, double z) {
    if (_isProcessingRaiseArm) return;

    _raiseArmList.addAll([x, y, z]);

    if (_raiseArmList.length >= 18) {
      List<double> recentRaiseArmData = _raiseArmList.sublist(_raiseArmList.length - 18);

      for (int i = 2; i <= recentRaiseArmData.length - 1; i += 3) {
        if (recentRaiseArmData[i - 2] <= 1 && recentRaiseArmData[i - 2] >= -1) {
          recentRaiseArmData[i-2]=0;
          if ((recentRaiseArmData[i - 1] >= 2 || recentRaiseArmData[i - 1] <= -2) &&
              (recentRaiseArmData[i] >= 2 || recentRaiseArmData[i] <= -2)) {
            _debugHistory.add("RaiseArm $recentRaiseArmData \n");

            var input = recentRaiseArmData.reshape([1, 6, 3]);
            var output = List.filled(3, 0.0).reshape([1, 3]);
            predictExercise(input, output);

            _isProcessingRaiseArm = true;
            Future.delayed(const Duration(seconds: 1), () {
              _isProcessingRaiseArm = false;
            });

            break;
          }
        }
      }
      _raiseArmList.clear();
    }
  }
  void buttonPressed(){
    numberOfExercise++;
    if(numberOfExercise==3){
      numberOfExercise=0;
    }
  }

  bool isDebug = false;
  void onExerciseCompleted() {
    setState(() {
      exerciseCount[numberOfExercise] =
          (exerciseCount[numberOfExercise] ?? 0) + 1;

      if (exerciseCount[numberOfExercise]! >= targetReps) {
        completedExercises[numberOfExercise] = true;
        numberOfExercise = (numberOfExercise + 1) % exerciseInfo.length;
      }
    });
  }

  Map<int, bool> completedExercises = {};


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isDebug
          ? DebugInfoWidget(
        numberOfExercise: numberOfExercise,
        x: _x,
        y: _y,
        z: _z,
        exerciseCount: exerciseCount,
        debugHistory: _debugHistory,
        onButtonPressed: buttonPressed,
      )
          : ExerciseInstructionWidget(
        numberOfExercise: numberOfExercise,
        exerciseInfo: exerciseInfo,
        targetReps: targetReps,
        currentReps: currentReps,
        onExerciseCompleted: onExerciseCompleted,
        exerciseCount: exerciseCount,
        completedExercises: completedExercises,
      ),
    );
  }
}
