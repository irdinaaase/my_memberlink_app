  class User {
    String? id;
    String? title;
    String? firstName;
    String? lastName;
    String? phone;
    String? address;
    String? email;
    String? password;
    String? profileImage;
    String? dateRegistered;
    String? membershipId;
    String? membershipStatus;

    User({
      this.id,
      this.title,
      this.firstName,
      this.lastName,
      this.phone,
      this.address,
      this.email,
      this.password,
      this.profileImage,
      this.dateRegistered,
      this.membershipId,
      this.membershipStatus,
    });

    User.fromJson(Map<String, dynamic> json) {
      id = json['user_id']?.toString();
      title = json['user_title'];
      firstName = json['user_firstName'];
      lastName = json['user_lastName'];
      phone = json['user_phone'];
      address = json['user_address'];
      email = json['user_email'];
      password = json['user_password'];
      profileImage = json['user_image'];
      dateRegistered = json['user_datereg'];
      membershipId = json['membership_id']?.toString();
      membershipStatus = json['membership_status'];
    }

    Map<String, dynamic> toJson() {
      return {
        'user_id': id,
        'user_title': title,
        'user_firstName': firstName,
        'user_lastName': lastName,
        'user_phone': phone,
        'user_address': address,
        'user_email': email,
        'user_password': password,
        'user_image': profileImage,
        'user_datereg': dateRegistered,
        'membership_id': membershipId,
        'membership_status': membershipStatus,
      };
    }
  }
