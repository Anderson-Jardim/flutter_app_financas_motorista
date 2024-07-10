class User {
  int? id;
  String? name;
  String? username;
  String? contact;
  String? token;

  User({
    this.id,
    this.name,
    this.username,
    this.contact,
    this.token
  });


  // function to convert json data to user model
  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json['user']['id'],
      name: json['user']['name'],
      username: json['user']['username'],
      contact: json['user']['contact'],
      token: json['token']
    );
  }
}