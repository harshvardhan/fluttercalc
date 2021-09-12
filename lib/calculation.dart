import 'package:fluttercalc/calculation_history_container.dart';
import 'package:fluttercalc/calculation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/calculation_bloc.dart';
import 'calculator_button.dart';
import 'result_display.dart';

class Calculation extends StatefulWidget {
  @override
  _CalculationState createState() => _CalculationState();
}

class _CalculationState extends State<Calculation> {
  double width;

  @override
  void initState() {
    context.read<CalculationBloc>().add(FetchHistory());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    width = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculationBloc, CalculationState>(
      builder: (context, CalculationState state) {
        return Container(
          child: Column(
            children: [
              ResultDisplay(
                text: _getDisplayText(state.calculationModel),
              ),
              Row(
                children: [
                  _getButton(text: '7', onTap: () => numberPressed('7')),
                  _getButton(text: '8', onTap: () => numberPressed('8')),
                  _getButton(text: '9', onTap: () => numberPressed('9')),
                  _getButton(text: 'x', onTap: () => operatorPressed('*'), backgroundColor: Color.fromRGBO(220, 220, 220, 1)),
                ],
              ),
              Row(
                children: [
                  _getButton(text: '4', onTap: () => numberPressed('4')),
                  _getButton(text: '5', onTap: () => numberPressed('5')),
                  _getButton(text: '6', onTap: () => numberPressed('6')),
                  _getButton(text: '/', onTap: () => operatorPressed('/'), backgroundColor: Color.fromRGBO(220, 220, 220, 1)),
                ],
              ),
              Row(
                children: [
                  _getButton(text: '1', onTap: () => numberPressed('1')),
                  _getButton(text: '2', onTap: () => numberPressed('2')),
                  _getButton(text: '3', onTap: () => numberPressed('3')),
                  _getButton(text: '+', onTap: () => operatorPressed('+'), backgroundColor: Color.fromRGBO(220, 220, 220, 1))
                ],
              ),
              Row(
                children: [
                  _getButton(text: '.', onTap: () => numberPressed('.')),
                  _getButton(text: '0', onTap: () => numberPressed('0')),
                  _getButton(text: 'C', onTap: clear, backgroundColor: Color.fromRGBO(220, 220, 220, 1)),
                  _getButton(text: '-', onTap: () => operatorPressed('-'),backgroundColor: Color.fromRGBO(220, 220, 220, 1)),
                ],
              ),
              _getButton(text: '=', onTap: calculateResult, backgroundColor: Colors.orange, textColor: Colors.white),
            ],
          ),
        );
      },
    );
  }

  Widget _getButton({String text, Function onTap, Color backgroundColor = Colors.white, Color textColor = Colors.black}) {
    return CalculatorButton(
      label: text,
      onTap: onTap,
      size: width / 4 - 12,
      backgroundColor: backgroundColor,
      labelColor: textColor,
    );
  }

  numberPressed(String number) {
    context.read<CalculationBloc>().add(NumberPressed(number: number));
  }

  operatorPressed(String operator) {
    context.read<CalculationBloc>().add(OperatorPressed(operator: operator));
  }

  calculateResult() {
    context.read<CalculationBloc>().add(CalculateResult());
  }

  clear() {
    context.read<CalculationBloc>().add(ClearCalculation());
  }

  String _getDisplayText(CalculationModel model) {
    var displayExpression = "";
    if (model.expression != null && model.expression.isNotEmpty) {
      return displayExpression = model.expression;
    }

    return "${displayExpression.isNotEmpty ? displayExpression : 0}";
  }
}