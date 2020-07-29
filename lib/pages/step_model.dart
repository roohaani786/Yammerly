class StepModel {
  final int id;
  final String text;

  StepModel({this.id, this.text});

  static List<StepModel> list = [
    StepModel(
      id: 1,
      text: "Quick and easy way\nto interact with your\nfriends.",
    ),
    StepModel(
      id: 2,
      text: "Add pictures and\nshowcase your life\nSocially.",
    ),
    StepModel(
        id: 3,
        text:
            "Make new friends\nand increase your popularity\nto receive rewards."),
  ];
}
