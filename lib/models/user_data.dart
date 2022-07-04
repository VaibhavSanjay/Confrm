class UserData {
  String famID;
  String name;
  String email;
  bool location;

  String get initials {
    return name.split(' ').map((v) => v[0].toUpperCase()).join('');
  }

  UserData({this.name = 'No Name', this.email = 'No Email', this.famID = '', this.location = false});
}