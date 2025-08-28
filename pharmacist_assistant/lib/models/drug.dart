class Drug {
  final String? drugCode;
  final String? greenrainCode;
  final String? insurancePlan;
  final int? tier;
  final String? packageName;
  final String? genericName;
  final String? strength;
  final String? dosageForm;
  final String? packageSize;
  final double? pricePublic;
  final double? pricePharmacy;
  final double? unitPricePublic;
  final double? unitPricePharmacy;
  final String? status;
  final String? deleteEffectiveDate;
  final String? lastChange;
  final String? agentName;
  final String? manufacturerName;
  final String category;
  final double? savingsDifference;
  final double? savingsPercent;

  const Drug({
    required this.drugCode,
    required this.greenrainCode,
    required this.insurancePlan,
    required this.tier,
    required this.packageName,
    required this.genericName,
    required this.strength,
    required this.dosageForm,
    required this.packageSize,
    required this.pricePublic,
    required this.pricePharmacy,
    required this.unitPricePublic,
    required this.unitPricePharmacy,
    required this.status,
    required this.deleteEffectiveDate,
    required this.lastChange,
    required this.agentName,
    required this.manufacturerName,
    required this.category,
    required this.savingsDifference,
    required this.savingsPercent,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        final s = v.trim();
        if (s.isEmpty) return null;
        return double.tryParse(s);
      }
      return null;
    }

    return Drug(
      drugCode: json['drugCode'] as String?,
      greenrainCode: json['greenrainCode'] as String?,
      insurancePlan: json['insurancePlan'] as String?,
      tier: json['tier'] is num ? (json['tier'] as num).toInt() : int.tryParse('${json['tier']}'),
      packageName: json['packageName'] as String?,
      genericName: json['genericName'] as String?,
      strength: json['strength'] as String?,
      dosageForm: json['dosageForm'] as String?,
      packageSize: json['packageSize'] as String?,
      pricePublic: _toDouble(json['pricePublic']),
      pricePharmacy: _toDouble(json['pricePharmacy']),
      unitPricePublic: _toDouble(json['unitPricePublic']),
      unitPricePharmacy: _toDouble(json['unitPricePharmacy']),
      status: json['status'] as String?,
      deleteEffectiveDate: json['deleteEffectiveDate'] as String?,
      lastChange: json['lastChange'] as String?,
      agentName: json['agentName'] as String?,
      manufacturerName: json['manufacturerName'] as String?,
      category: (json['category'] as String?) ?? 'Other',
      savingsDifference: _toDouble(json['savingsDifference']),
      savingsPercent: _toDouble(json['savingsPercent']),
    );
  }
}
