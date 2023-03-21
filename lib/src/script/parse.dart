import 'dart:convert';
import 'dart:typed_data';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:tuple/tuple.dart';
import 'package:moontree_utils/src/script/util.dart';

enum VoutDataType {
  address,
  assetAmount,
  assetMetadata,
  assetMemo,
  assetVerifier,
  h160Freeze,
  globalFreeze,
  h160Qualification,
  opReturn,
}

abstract class VoutData {
  final VoutDataType type;
  const VoutData(this.type);
}

class AddressVoutData extends VoutData {
  final String address;
  const AddressVoutData(this.address) : super(VoutDataType.address);

  @override
  String toString() {
    return 'ToAddress($address)';
  }
}

class OPReturnVoutData extends VoutData {
  final Uint8List opReturn;
  const OPReturnVoutData(this.opReturn) : super(VoutDataType.opReturn);

  @override
  String toString() {
    return 'OP_RETURN(${hex.encode(opReturn)})';
  }
}

abstract class AssetTagData extends VoutData {
  const AssetTagData(VoutDataType type) : super(type);
}

class H160Freeze extends AssetTagData {
  final Uint8List h160;
  final String asset;
  final bool isFrozen;
  const H160Freeze(this.h160, this.asset, this.isFrozen)
      : super(VoutDataType.h160Freeze);

  @override
  String toString() {
    return '$asset ${isFrozen ? "froze" : "unfroze"} ${h160ToAddress(h160, 111)}';
  }
}

class H160Qualification extends AssetTagData {
  final Uint8List h160;
  final String asset;
  final bool isQualified;
  const H160Qualification(this.h160, this.asset, this.isQualified)
      : super(VoutDataType.h160Qualification);

  @override
  String toString() {
    return '$asset ${isQualified ? "qualified" : "unqualified"} ${h160ToAddress(h160, 111)}';
  }
}

class Verifier extends AssetTagData {
  final String verifierString;
  const Verifier(this.verifierString) : super(VoutDataType.assetVerifier);

  @override
  String toString() {
    return 'Verifier: $verifierString';
  }
}

class GlobalFreeze extends AssetTagData {
  final String asset;
  final bool isFrozen;
  const GlobalFreeze(this.asset, this.isFrozen)
      : super(VoutDataType.globalFreeze);

  @override
  String toString() {
    return '$asset ${isFrozen ? "froze" : "unfroze"} globally';
  }
}

abstract class AssetData extends VoutData {
  const AssetData(VoutDataType type) : super(type);
}

class AssetAmount extends AssetData {
  final String asset;
  final int sats;
  const AssetAmount(this.asset, this.sats) : super(VoutDataType.assetAmount);

  @override
  String toString() {
    return 'Asset amount: $asset ($sats)';
  }
}

class RawAssetMetadata extends AssetData {
  final String asset;
  final int divisibility;
  final bool reissuable;
  final Uint8List? associatedData;
  const RawAssetMetadata(
      this.asset, this.divisibility, this.reissuable, this.associatedData)
      : super(VoutDataType.assetMetadata);

  @override
  String toString() {
    return 'Asset data: $asset ($divisibility, $reissuable, ${associatedData == null ? "none" : base58.encode(associatedData!)})';
  }
}

class AssetMemo extends AssetData {
  final Uint8List memo;
  final int? timestamp;
  const AssetMemo(this.memo, [this.timestamp]) : super(VoutDataType.assetMemo);

  @override
  String toString() {
    return 'Asset memo: ${base58.encode(memo)} ($timestamp)';
  }
}

AddressVoutData? tryGuessAddressFromOpList(
  List<Tuple3<int, int, Uint8List>> ops,
  Constants networkConstants,
) {
  if (ops.length == 5 &&
      ops[0].item1 == 0x76 &&
      ops[1].item1 == 0xa9 &&
      ops[2].item3.length == 0x14 &&
      ops[3].item1 == 0x88 &&
      ops[4].item1 == 0xac) {
    return AddressVoutData(
        h160ToAddress(ops[2].item3, networkConstants.p2pkhType));
  } else if (ops.length == 3 &&
      ops[0].item1 == 0xa9 &&
      ops[1].item3.length == 0x14 &&
      ops[2].item1 == 0x87) {
    return AddressVoutData(
        h160ToAddress(ops[1].item3, networkConstants.p2shType));
  } else {
    return null;
  }
}

// TODO: Multiple networks
Iterable<VoutData> parseVoutScriptForData(Uint8List script) {
  final opCodes = getOpCodes(script);
  final dataPoints = <VoutData>[];

  int maybeOpRVNAssetTuplePtr = opCodes.length;

  for (int tupleCnt = 0; tupleCnt < opCodes.length; tupleCnt++) {
    if (opCodes[tupleCnt].item1 == 0xc0) {
      maybeOpRVNAssetTuplePtr = tupleCnt;
      break;
    }
  }

  if (opCodes.isNotEmpty && opCodes[0].item1 == 0x6a) {
    dataPoints.add(OPReturnVoutData(script));
  }

  final addressData = tryGuessAddressFromOpList(
      opCodes.sublist(0, maybeOpRVNAssetTuplePtr), testnetConstants);
  if (addressData != null) dataPoints.add(addressData);

  if (maybeOpRVNAssetTuplePtr == 0) {
    final assetTagData = tryGuessAssetTagFromOpList(opCodes);
    if (assetTagData != null) dataPoints.add(assetTagData);
  } else if (maybeOpRVNAssetTuplePtr < opCodes.length) {
    final assetTransferData =
        parseAssetTransfer(opCodes.sublist(maybeOpRVNAssetTuplePtr), script);
    dataPoints.addAll(assetTransferData);
  }

  return dataPoints;
}

AssetTagData? tryGuessAssetTagFromOpList(
  List<Tuple3<int, int, Uint8List>> ops,
) {
  // We assume first op is OPRVNASSET
  if (ops.length == 3 && ops[1].item3.length == 0x14) {
    final dataTuple = parseAssetAndFlag(ops[2].item3);
    if (dataTuple != null) {
      final assetName = dataTuple.item1;
      final flag = dataTuple.item2;
      if (assetName[0] == '\$') {
        return H160Freeze(ops[1].item3, assetName, flag);
      } else if (assetName[0] == '#') {
        return H160Qualification(ops[1].item3, assetName, flag);
      }
    }
  } else if (ops.length == 3 && ops[1].item1 == 0x50) {
    //TODO: We probably wanna run our own standardization on the verifier string
    final verifierString = utf8.decode(ops[2].item3);
    return Verifier(verifierString);
  } else if (ops.length == 4 && ops[1].item1 == 0x50 && ops[2].item1 == 0x50) {
    final dataTuple = parseAssetAndFlag(ops[3].item3);
    if (dataTuple != null) {
      final assetName = dataTuple.item1;
      final flag = dataTuple.item2;
      if (assetName[0] == '\$') {
        return GlobalFreeze(assetName, flag);
      }
    }
  }
  return null;
}

Tuple2<String, bool>? parseAssetAndFlag(Uint8List data) {
  if (data.isEmpty) return null;
  final assetNameLength = data[0];
  if (data.length < assetNameLength + 2) return null;
  final assetName = utf8.decode(data.sublist(1, 1 + assetNameLength));
  final flag = data[1 + assetNameLength] != 0;
  return Tuple2(assetName, flag);
}

List<AssetData> parseAssetTransfer(
    List<Tuple3<int, int, Uint8List>> ops, Uint8List raw) {
  // Starts at OP_RVN_ASSET
  if (ops.length >= 2 && ops[0].item1 == 0xc0) {
    if (ops.length == 3 && ops[2].item1 == 0x75) {
      // This is a good and proper asset script
      final assetPortion = ops[1].item3;
      return parseAssetScript(assetPortion);
    } else {
      // This could be malformed asset script
      // Just grab everything after OP_RVN_ASSET and try to parse
      final malformedScript = raw.sublist(ops[0].item2);

      int startPtr = -1;
      if (malformedScript[2] == 0x72 &&
          malformedScript[3] == 0x76 &&
          malformedScript[4] == 0x6e) {
        startPtr = 2;
      } else if (malformedScript[3] == 0x72 &&
          malformedScript[4] == 0x76 &&
          malformedScript[5] == 0x6e) {
        startPtr = 3;
      }
      if (startPtr > 0) {
        return parseAssetScript(malformedScript.sublist(startPtr));
      }
    }
  }
  return [];
}

List<AssetData> parseAssetScript(Uint8List assetPortion) {
  final dataToReturn = <AssetData>[];
  if (assetPortion.length > 5 &&
      assetPortion[0] == 0x72 &&
      assetPortion[1] == 0x76 &&
      assetPortion[2] == 0x6e) {
    final type = assetPortion[3];
    final assetNameLength = assetPortion[4];
    if (assetPortion.length >= 5 + assetNameLength) {
      final assetName =
          utf8.decode(assetPortion.sublist(5, 5 + assetNameLength));
      if (type == 0x6f) {
        // Ownership creation
        dataToReturn.add(AssetAmount(assetName, coin));
        dataToReturn.add(RawAssetMetadata(assetName, 0, false, null));
      } else if (assetPortion.length >= 13 + assetNameLength) {
        final sats = assetPortion
            .sublist(5 + assetNameLength, 13 + assetNameLength)
            .buffer
            .asByteData()
            .getUint64(0, Endian.little);
        dataToReturn.add(AssetAmount(assetName, sats));
        if (type == 0x74 && assetPortion.length >= 47 + assetNameLength) {
          final Uint8List assetMemo =
              assetPortion.sublist(13 + assetNameLength, 47 + assetNameLength);
          int? timestamp;
          if (assetPortion.length >= 55 + assetNameLength) {
            timestamp = assetPortion
                .sublist(47 + assetNameLength, 55 + assetNameLength)
                .buffer
                .asByteData()
                .getUint64(0, Endian.little);
          }
          dataToReturn.add(AssetMemo(assetMemo, timestamp));
        } else if (type == 0x71 &&
            assetPortion.length >= 16 + assetNameLength) {
          // Asset creation
          final divisions = assetPortion[13 + assetNameLength];
          final reissuability = assetPortion[14 + assetNameLength] != 0;
          final hasAssociatedData = assetPortion[15 + assetNameLength] != 0;
          Uint8List? associatedData;
          if (hasAssociatedData &&
              assetPortion.length >= 50 + assetNameLength) {
            associatedData = assetPortion.sublist(
                16 + assetNameLength, 50 + assetNameLength);
          }
          dataToReturn.add(RawAssetMetadata(
              assetName, divisions, reissuability, associatedData));
        } else if (type == 0x72 &&
            assetPortion.length >= 15 + assetNameLength) {
          // Asset Reissuance
          final divisions = assetPortion[13 + assetNameLength];
          final reissuability = assetPortion[14 + assetNameLength] != 0;
          Uint8List? associatedData;
          if (assetPortion.length >= 49 + assetNameLength) {
            associatedData = assetPortion.sublist(
                15 + assetNameLength, 49 + assetNameLength);
          }
          dataToReturn.add(RawAssetMetadata(
              assetName, divisions, reissuability, associatedData));
        }
      } else {
        print(hex.encode(assetPortion));
        throw Exception('Bad length');
      }
    }
  }
  return dataToReturn;
}
