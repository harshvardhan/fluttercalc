import 'package:equatable/equatable.dart';

class CalculationModel extends Equatable {
  CalculationModel({
    this.operandList,
    this.operatorList,
    this.result,
    this.decimalNumber,
    this.expression,
  });

  final List<double> operandList;
  final List<String> operatorList;
  final double result;
  final String decimalNumber;
  final String expression;

  CalculationModel copyWith({
    List<double> Function() operandList,
    List<String> Function() operatorList,
    double Function() result,
    String Function() decimalNumber,
    String Function() expression
    })
  {
    return CalculationModel(
      operandList: operandList?.call() ?? this.operandList,
      operatorList: operatorList?.call() ?? this.operatorList,
      result: result?.call() ?? this.result,
      decimalNumber: decimalNumber?.call() ?? this.decimalNumber,
      expression: expression?.call() ?? this.expression,
    );
  }

  CalculationModel.fromJson(Map<String, dynamic> json)
      : operandList = json['operandList'],
        operatorList = json['operatorList'],
        result = json['result'],
        decimalNumber = json['decimalNumber'],
        expression = json['expression'];

  Map<String, dynamic> toJson() =>
      {
        'operandList': operandList,
        'operatorList': operatorList,
        'result': result,
        'decimalNumber': decimalNumber,
        'expression': expression,
      };

  @override
  String toString() {
    return "$expression";
  }

  @override
  List<Object> get props => [operandList,
    operatorList,
    result,
    decimalNumber,
    expression];
}