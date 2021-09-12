import 'dart:async';
import 'dart:developer';

import 'package:fluttercalc/calculation_model.dart';
import 'package:fluttercalc/services/calculation_history_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'calculation_state.dart';
import 'calculation_event.dart';

export 'calculation_state.dart';
export 'calculation_event.dart';

class CalculationBloc extends Bloc<CalculationEvent, CalculationState> {
  CalculationBloc({
    @required this.calculationHistoryService
  }) : assert(calculationHistoryService != null), super(CalculationInitial());

  CalculationHistoryService calculationHistoryService;

  @override
  Stream<CalculationState> mapEventToState(
    CalculationEvent event,
  ) async* {
    if (event is NumberPressed) {
      yield await _mapNumberPressedToState(event);
    }

    if (event is OperatorPressed) {
      yield await _mapOperatorPressedToState(event);
    }

    if (event is CalculateResult) {
      yield* _mapCalculateResultToState(event);
    }

    if (event is ClearCalculation) {
      CalculationModel resultModel = CalculationInitial().calculationModel.copyWith();

      yield CalculationChanged(
        calculationModel: resultModel,
        history: List.of(state.history)
      );
    }

    if (event is FetchHistory) {
      yield CalculationChanged(
        calculationModel: state.calculationModel,
        history: calculationHistoryService.fetchAllEntries()
      );
    }
  }

  Future<CalculationState> _mapNumberPressedToState(
    NumberPressed event,
  ) async {
    //if result is not set to null send result null
    //concat the input to decimalNumber
    CalculationModel model = state.calculationModel;

    var decimalNumber = model.decimalNumber;
    if (decimalNumber == null) {
      decimalNumber = "";
    }
    if (decimalNumber.contains('.') && event.number == '.') {
      return state;
    }
    decimalNumber += event.number;
    var expression = model.expression;
    if (expression == null) {
      expression = "";
    }
    expression += event.number;

    if (model.result != null) {
      CalculationModel newModel = model.copyWith(
          operandList: () => null,
          operatorList: () => null,
          expression: () => event.number,
          decimalNumber: () => event.number,
          result: () => null
      );

      return CalculationChanged(
        calculationModel: newModel,
        history: List.of(state.history)
      );
    }

    CalculationModel newModel = model.copyWith(
      decimalNumber: () => decimalNumber,
      expression: () => expression,
    );

    return CalculationChanged(
        calculationModel: newModel,
        history: List.of(state.history)
    );
  }

  Future<CalculationState> _mapOperatorPressedToState(
      OperatorPressed event,
      ) async {
    //return state if not allowed operator
    //if decimalNumber null & empty then send state back
    //if not then add the decimal number in operandList

    List<String> allowedOperators = ['+', '-', '*', '/'];

    if (!allowedOperators.contains(event.operator)) {
      return state;
    }

    CalculationModel model = state.calculationModel;
    if (model.decimalNumber == null || model.decimalNumber.isEmpty) {
      return state;
    }
    if (model.decimalNumber != null || model.decimalNumber.isNotEmpty) {
      var operandList = model.operandList;
      if (operandList == null) {
        operandList = [];
      }
      operandList.add(double.parse(model.decimalNumber));

      var operatorList = model.operatorList;
      if (operatorList == null) {
        operatorList = [];
      }
      operatorList.add(event.operator);

      var expression = model.expression;
      if (expression == null) {
        expression = "";
      }
      expression += event.operator;

      CalculationModel newModel = model.copyWith(
        operatorList: () => operatorList,
        operandList: () => operandList,
        decimalNumber: () => "",
        expression: ()=> expression,
      );

      return CalculationChanged(
          calculationModel: newModel,
          history: List.of(state.history)
      );
    }
  }

  Stream<CalculationState> _mapCalculateResultToState(
      CalculateResult event,
    ) async* {
    CalculationModel model = state.calculationModel;
    // Go though the operatorList and find the operator in order of following preference / * + -
    // Get list of index for division "/"
    // Based on operator's index in operatorList, say x, pick x and x+1 operands from operandList and do the operation
    // Add the result on x and add null at x+1 in operandList
    // Repeat this process until all index's for division "/" is done
    // Remove the "/" from operatorList
    // Remove the nulls from operandList
    // If there is one item left after null removal then that is the result
    // Get list of index for multiplication "*" and repeat the process
    // Do this for addition & subtraction

    if (model.operatorList == null || model.operatorList.isEmpty
        || model.operandList == null || model.operandList.isEmpty) {
      yield state;
      return;
    }
    var operandList = model.operandList;
    if (model.decimalNumber != null && model.decimalNumber.isNotEmpty) {
      if (operandList == null) {
        operandList = [];
      }
      operandList.add(double.parse(model.decimalNumber));
    }

    CalculationModel newModel = model.copyWith(
      operandList: () => operandList,
    );

    yield CalculationChanged(
        calculationModel: newModel,
        history: List.of(state.history)
    );

    var operatorList = model.operatorList;
    var divisionEntries = _findIndexsForOperator(operatorList, "/");
    divisionEntries.asMap().forEach((key, value) {
      print('key = $key ---> value = $value');
      var result = operandList[value]/operandList[value+1];
      operandList[value] = result;
      operandList[value+1] = null;
    });

    var done = resetFor(operandList, operatorList, "/");

    if(!done) {
      var multiplicationEntries = _findIndexsForOperator(operatorList, "*");
      multiplicationEntries.asMap().forEach((key, value) {
        print('key = $key ---> value = $value');
        var result = operandList[value]*operandList[value+1];
        operandList[value] = result;
        operandList[value+1] = null;
      });

      done = resetFor(operandList, operatorList, "*");

      if(!done) {
        var additionEntries = _findIndexsForOperator(operatorList, "+");
        additionEntries.asMap().forEach((key, value) {
          print('key = $key ---> value = $value');
          var result = operandList[value]+operandList[value+1];
          operandList[value] = result;
          operandList[value+1] = null;
        });
        done = resetFor(operandList, operatorList, "+");

        if(!done) {
          var subtractionEntries = _findIndexsForOperator(operatorList, "-");
          subtractionEntries.asMap().forEach((key, value) {
            print('key = $key ---> value = $value');
            var result = operandList[value]-operandList[value+1];
            operandList[value] = result;
            operandList[value+1] = null;
          });
          done = resetFor(operandList, operatorList, "-");
        }
      }
    }

    var result = operandList.first;
    var expression = model.expression;
    if (expression == null) {
      expression = "";
    }
    expression += '=' + _removeTrailingZeros(result);

    CalculationModel copyModel = CalculationInitial().calculationModel.copyWith(
        expression: ()=> expression,
        result: () => result
    );

    yield CalculationChanged(
      calculationModel: copyModel,
      history: List.of(state.history)
    );

    yield* _yieldHistoryStorageResult(model, copyModel);
  }

  Stream<CalculationChanged> _yieldHistoryStorageResult(CalculationModel model, CalculationModel newModel) async* {
    CalculationModel resultModel = model.copyWith(result: () => newModel.result);

    if(await calculationHistoryService.addEntry(resultModel)) {
      yield CalculationChanged(
        calculationModel: newModel,
        history: calculationHistoryService.fetchAllEntries()
      );
    }
  }

  @override
  void onChange(Change<CalculationState> change) {
    log(change.currentState.calculationModel.toString());
    log(change.nextState.calculationModel.toString());
    super.onChange(change);
  }

  String _removeTrailingZeros(double result) {
    RegExp regex = RegExp(r"([.]*0)(?!.*\d)");
    //var precisionResult = result.toStringAsPrecision(2);
    return result.toStringAsFixed(2).replaceAll(regex, "");
  }

  List<int> _findIndexsForOperator(List<String> operatorList, String operator) {
    List<int> index = [];
    if (operatorList.contains(operator)) {
      for (int i = 0; i < operatorList.length; i++) {
        if (operator == operatorList[i]) {
          index.add(i);
        }
      }
    }
    return index;
  }

  List<double> _removeNullsFromOperandList(List<double> operandsList) {
    operandsList.removeWhere((item) => item == null);
    return operandsList;
  }

  List<String> _removeOperatorFromOperatorList(List<String> operatorList, String operator) {
    operatorList.removeWhere((item) => item == operator);
    return operatorList;
  }

  bool resetFor(List<double> operandsList, List<String> operatorList, String operator) {
    operandsList = _removeNullsFromOperandList(operandsList);
    operatorList = _removeOperatorFromOperatorList(operatorList, operator);
    return operandsList.length == 1;
  }
}
