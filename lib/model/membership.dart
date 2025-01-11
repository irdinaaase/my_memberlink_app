class Membership {
  String? membershipsId;
  String? membershipsName;
  String? membershipsDescription;
  double? membershipsPrice;
  String? membershipsDuration;
  String? membershipsBenefits;
  String? membershipsTerms;

  Membership({
    this.membershipsId,
    this.membershipsName,
    this.membershipsDescription,
    this.membershipsPrice,
    this.membershipsDuration,
    this.membershipsBenefits,
    this.membershipsTerms,
  });

  Membership.fromJson(Map<String, dynamic> json) {
    membershipsId = json['memberships_id'];
    membershipsName = json['memberships_name'];
    membershipsDescription = json['memberships_description'];
    membershipsPrice = double.parse(json['memberships_price'].toString());
    membershipsDuration = json['memberships_duration'];
    membershipsBenefits = json['memberships_benefits'];
    membershipsTerms = json['memberships_terms'];
  }

  Map<String, dynamic> toJson() {
    return {
      'memberships_id': membershipsId,
      'memberships_name': membershipsName,
      'memberships_description': membershipsDescription,
      'memberships_price': membershipsPrice,
      'memberships_duration': membershipsDuration,
      'memberships_benefits': membershipsBenefits,
      'memberships_terms': membershipsTerms,
    };
  }
} 