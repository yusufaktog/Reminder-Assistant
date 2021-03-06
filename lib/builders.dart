import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reminder_app/constants.dart';

class CustomCard extends StatelessWidget {
  const CustomCard(
      {Key? key,
      required this.backGroundColor,
      required this.verticalMargin,
      required this.horizontalMargin,
      required this.padding,
      required this.child,
      required this.borderRadius})
      : super(key: key);

  final Color backGroundColor;
  final double verticalMargin;
  final double horizontalMargin;
  final EdgeInsets padding;
  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backGroundColor,
      margin: EdgeInsets.symmetric(vertical: verticalMargin, horizontal: horizontalMargin),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      child: Padding(padding: padding, child: child),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key? key,
      required this.hintText,
      required this.fontSize,
      required this.textColor,
      this.controller,
      this.prefixIcon,
      this.suffixIcon,
      this.onChanged,
      this.isObscureText})
      : super(key: key);

  final String hintText;
  final double fontSize;
  final Color textColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function? onChanged;
  final TextEditingController? controller;
  final bool? isObscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
      obscureText: isObscureText ?? false,
      obscuringCharacter: '*',
      onChanged: (value) {
        onChanged!(value);
      },
      cursorColor: textColor,
      keyboardType: TextInputType.text,
      controller: controller,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textColor, fontSize: fontSize, fontWeight: FontWeight.normal),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final TextStyle? textStyle;
  final BoxFit? fit;

  const CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.fit,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onPressed();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: fit ?? BoxFit.none,
            child: Text(
              text,
              style: textStyle,
            ),
          )
          // Text(
          //   text,
          //   style: textStyle,
          // ),
        ],
      ),
    );
  }
}

Future<Object?> switchPage(BuildContext context, Widget widget) async {
  return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => widget,
      ),
      (route) => false);
}

class CustomUnderlinedTextField extends StatelessWidget {
  final Function onChanged;
  final TextStyle style;
  final String? labelText;
  final String? hintText;
  final Color? borderColor;
  final TextInputType? keyboardType;
  final TextEditingController? textEditingController;

  const CustomUnderlinedTextField(
      {Key? key,
      required this.onChanged,
      required this.style,
      this.hintText,
      this.labelText,
      this.borderColor,
      this.keyboardType,
      this.textEditingController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType ?? TextInputType.text,
      controller: textEditingController,
      onChanged: (value) {
        onChanged(value);
      },
      style: style,
      decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? Colors.black),
          ),
          labelText: labelText ?? "",
          hintText: hintText ?? "",
          labelStyle: style),
    );
  }
}
//

class CustomDropDownMenu extends StatefulWidget {
  final Function onChanged;
  final List<dynamic> items;
  final Icon? icon;
  final TextStyle? itemTextStyle;
  final int? elevation;
  final Color? dropDownColor;
  final Function? onTap;

  final dynamic dropDownValue;

  const CustomDropDownMenu(
      {Key? key,
      required this.onChanged,
      required this.items,
      required this.dropDownValue,
      this.dropDownColor,
      this.icon,
      this.elevation,
      this.itemTextStyle,
      this.onTap})
      : super(key: key);

  @override
  State<CustomDropDownMenu> createState() => _CustomDropDownMenuState();
}

class _CustomDropDownMenuState extends State<CustomDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<dynamic>(
      alignment: Alignment.centerRight,
      value: widget.dropDownValue,
      underline: Container(),
      icon: widget.icon ??
          Icon(
            Icons.arrow_drop_down_sharp,
            color: mainTheme.primaryColor,
            size: 36,
          ),
      elevation: widget.elevation ?? 1,
      dropdownColor: widget.dropDownColor ?? Colors.white,
      onChanged: (value) {
        widget.onChanged(value);
      },
      items: widget.items.map<DropdownMenuItem<dynamic>>((dynamic value) {
        return DropdownMenuItem<dynamic>(
          value: value,
          child: Text(value.toString(), style: widget.itemTextStyle),
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!(value);
            }
          },
        );
      }).toList(),
    );
  }
}
