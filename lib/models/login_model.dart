class LoginModel {
  final int userID;
  final String password;

  LoginModel({required this.userID, required this.password});

  Map<String, dynamic> toJson() {
    return {
      "userID": userID,
      "password": password,
    };
  }

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      userID: json["userID"],
      password: json["password"],
    );
  }
}
