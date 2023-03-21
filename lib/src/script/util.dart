import 'dart:typed_data';

import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:tuple/tuple.dart';

const coin = 100000000;

String h160ToAddress(Uint8List h160, int addrType) {
  if (h160.length != 0x14) {
    throw Exception('Invalid h160 length');
  }
  List<int> x = [];
  x.add(addrType);
  x.addAll(h160);
  x.addAll(doubleSHA256(Uint8List.fromList(x)).sublist(0, 4));
  return base58.encode(Uint8List.fromList(x));
}

// (OPCODE, LAST_POSITION, PUSHED_DATA)
List<Tuple3<int, int, Uint8List>> getOpCodes(Uint8List data, [offset = 0]) {
  final ops = <Tuple3<int, int, Uint8List>>[];
  int ptr = offset;

  while (ptr < data.length) {
    final op = data[ptr];
    var opTuple = Tuple3(op, ptr, Uint8List.fromList([]));
    ptr += 1;

    if (op <= 0x4e) {
      // These are OP_PUSHes
      int len;
      int lenSize;

      if (op < 0x4c) {
        len = op;
        lenSize = 0;
      } else if (op == 0x4c) {
        len = data[ptr];
        lenSize = 1;
      } else if (op == 0x4d) {
        len = data
            .sublist(ptr, ptr + 2)
            .buffer
            .asByteData()
            .getUint16(0, Endian.little);
        lenSize = 2;
      } else {
        len = data
            .sublist(ptr, ptr + 4)
            .buffer
            .asByteData()
            .getUint32(0, Endian.little);
        lenSize = 4;
      }

      ptr += lenSize;
      try {
        opTuple = Tuple3(op, ptr + len, data.sublist(ptr, ptr + len));
      } on RangeError {
        opTuple = Tuple3(-1, data.length - 1, data.sublist(ptr));
        ops.add(opTuple);
        break;
      }
      ptr += len;
    }
    ops.add(opTuple);
  }

  return ops;
}

// This returns a var int and how long it was
Tuple2<int, int> readVarInt(Uint8List data, [offset = 0]) {
  if (data[offset] < 0xfd) {
    return Tuple2(1, data[offset]);
  } else if (data[offset] == 0xfd) {
    return Tuple2(3,
        data.sublist(offset).buffer.asByteData().getUint16(1, Endian.little));
  } else if (data[offset] == 0xfe) {
    return Tuple2(5,
        data.sublist(offset).buffer.asByteData().getUint32(1, Endian.little));
  } else {
    return Tuple2(9,
        data.sublist(offset).buffer.asByteData().getUint64(1, Endian.little));
  }
}

Uint8List doubleSHA256(Uint8List data) {
  return Uint8List.fromList(sha256.convert(sha256.convert(data).bytes).bytes);
}

String hashDecode(Uint8List rawHash) {
  return hex.encode(List.from(rawHash.reversed));
}

const String testNetName = 'testnet';
const String mainNetName = 'mainnet';

class Constants {
  final int kawpowActivationTimestamp;
  final int p2pkhType;
  final int p2shType;

  Constants(this.kawpowActivationTimestamp, this.p2pkhType, this.p2shType);
}

final testnetConstants = Constants(1585159200, 111, 196);
final mainnetConstants = Constants(1588788000, 60, 122);

class RawVin {
  String txid;
  int idx;
  Uint8List script;
  int sequence;

  RawVin(this.txid, this.idx, this.script, this.sequence);

  @override
  String toString() {
    return 'RawVin(txid: $txid, idx: $idx, sequence: $sequence, script: ${hex.encode(script)})';
  }
}

class RawVout {
  int ravenValue;
  Uint8List script;

  RawVout(this.ravenValue, this.script);

  @override
  String toString() {
    return 'RawVout(ravenValue: $ravenValue, script: ${hex.encode(script)})';
  }
}

class RawTransaction {
  int version;
  bool hasWitFlag;
  int locktime;
  String txid;

  List<RawVin> vins;
  List<List<Uint8List>>? witness;
  List<RawVout> vouts;

  RawTransaction(this.version, this.hasWitFlag, this.locktime, this.vins,
      this.vouts, this.txid, this.witness);

  @override
  String toString() {
    String parseWitness(List<List<Uint8List>>? witness) {
      if (witness == null) {
        return 'none';
      }
      var retVal = '';
      for (int i = 0; i < witness.length; i++) {
        retVal +=
            'vin $i witness list: ${witness[i].map((e) => hex.encode(e))}';
      }
      return retVal;
    }

    return 'RawTransaction(version: $version, hasWitness: $hasWitFlag, locktime: $locktime, txid: $txid, ${vins.length} vins, ${vouts.length} vouts, witness: ${parseWitness(witness)})';
  }
}

class RawBlock {
  int version;
  String previousBlockHash;
  String merkleRoot;
  int timestamp;
  int bits;
  int nonce;
  int? nHeight;
  String? mixHash;
  List<RawTransaction> transactions = [];

  RawBlock(this.version, this.previousBlockHash, this.merkleRoot,
      this.timestamp, this.bits, this.nonce, this.nHeight, this.mixHash);

  @override
  String toString() {
    return 'RawBlock(version: $version, prevHash: $previousBlockHash, merkle: $merkleRoot, timestamp: $timestamp, bits: $bits, nonce: $nonce, nHeight: $nHeight, mixHash: $mixHash) ${transactions.length} transaction(s)';
  }
}

Tuple2<int, RawVout> _parseRawVout(Uint8List data, int offset) {
  final ravenValueBytes = data.sublist(offset, offset + 8);
  final ravenValue =
      ravenValueBytes.buffer.asByteData().getUint64(0, Endian.little);
  final scriptVarIntTuple = readVarInt(data, offset + 8);
  final scriptBytes = data.sublist(offset + 8 + scriptVarIntTuple.item1,
      offset + 8 + scriptVarIntTuple.item1 + scriptVarIntTuple.item2);
  return Tuple2(8 + scriptVarIntTuple.item1 + scriptVarIntTuple.item2,
      RawVout(ravenValue, scriptBytes));
}

Tuple2<int, RawVin> _parseRawVin(Uint8List data, int offset) {
  final transactionIdBytes = data.sublist(offset, offset + 32);
  final transactionId = hashDecode(transactionIdBytes);
  final idxBytes = data.sublist(offset + 32, offset + 32 + 4);
  final idx = idxBytes.buffer.asByteData().getUint32(0, Endian.little);
  final scriptVarIntTuple = readVarInt(data, offset + 36);
  final script = data.sublist(offset + 36 + scriptVarIntTuple.item1,
      offset + 36 + scriptVarIntTuple.item1 + scriptVarIntTuple.item2);
  final sequenceBytes = data.sublist(
      offset + 36 + scriptVarIntTuple.item1 + scriptVarIntTuple.item2,
      offset + 40 + scriptVarIntTuple.item1 + scriptVarIntTuple.item2);
  final sequence =
      sequenceBytes.buffer.asByteData().getUint32(0, Endian.little);
  return Tuple2(40 + scriptVarIntTuple.item1 + scriptVarIntTuple.item2,
      RawVin(transactionId, idx, script, sequence));
}

RawTransaction parseRawTransaction(String hexData) {
  return _parseRawTransaction(Uint8List.fromList(hex.decode(hexData)), 0).item2;
}

Tuple2<int, RawTransaction> _parseRawTransaction(Uint8List data, int offset) {
  final versionBytes = data.sublist(offset, offset + 4);
  final version = versionBytes.buffer.asByteData().getUint32(0, Endian.little);
  var internalOffset = 4;
  bool hasWit;
  if (data[offset + internalOffset] == 0) {
    // TODO: What to do with this?
    // assert(data[offset + internalOffset + 1] == 1);
    hasWit = true;
    internalOffset += 2;
  } else {
    hasWit = false;
  }

  final List<int> strippedTransactionRaw = [];
  strippedTransactionRaw.addAll(versionBytes);

  final vinsVarIntTuple = readVarInt(data, offset + internalOffset);
  strippedTransactionRaw.addAll(data.sublist(offset + internalOffset,
      offset + internalOffset + vinsVarIntTuple.item1));
  internalOffset += vinsVarIntTuple.item1;

  final List<RawVin> vins = [];
  for (var vinCount = 0; vinCount < vinsVarIntTuple.item2; vinCount++) {
    final vinTuple = _parseRawVin(data, offset + internalOffset);
    strippedTransactionRaw.addAll(data.sublist(
        offset + internalOffset, offset + internalOffset + vinTuple.item1));
    internalOffset += vinTuple.item1;
    vins.add(vinTuple.item2);
  }

  final voutsVarIntTuple = readVarInt(data, offset + internalOffset);
  strippedTransactionRaw.addAll(data.sublist(offset + internalOffset,
      offset + internalOffset + voutsVarIntTuple.item1));
  internalOffset += voutsVarIntTuple.item1;

  final List<RawVout> vouts = [];

  for (var voutCount = 0; voutCount < voutsVarIntTuple.item2; voutCount++) {
    final voutTuple = _parseRawVout(data, offset + internalOffset);

    strippedTransactionRaw.addAll(data.sublist(
        offset + internalOffset, offset + internalOffset + voutTuple.item1));
    internalOffset += voutTuple.item1;

    vouts.add(voutTuple.item2);
  }

  List<List<Uint8List>>? witness;
  if (hasWit) {
    witness = <List<Uint8List>>[];
    for (var vinCount = 0; vinCount < vins.length; vinCount++) {
      final vinWitVarIntTuple = readVarInt(data, offset + internalOffset);
      internalOffset += vinWitVarIntTuple.item1;
      List<Uint8List> witForVin = [];
      for (var vinWitCount = 0;
          vinWitCount < vinWitVarIntTuple.item2;
          vinWitCount++) {
        final witVarIntTuple = readVarInt(data, offset + internalOffset);
        witForVin.add(data.sublist(offset + internalOffset,
            offset + internalOffset + witVarIntTuple.item2));
        internalOffset += witVarIntTuple.item1 + witVarIntTuple.item2;
      }
      witness.add(witForVin);
    }
  }

  final locktimeBytes =
      data.sublist(offset + internalOffset, offset + internalOffset + 4);
  final locktime =
      locktimeBytes.buffer.asByteData().getUint32(0, Endian.little);
  internalOffset += 4;
  strippedTransactionRaw.addAll(locktimeBytes);

  return Tuple2(
      internalOffset,
      RawTransaction(
          version,
          hasWit,
          locktime,
          vins,
          vouts,
          hex.encode(List.from(
              doubleSHA256(Uint8List.fromList(strippedTransactionRaw))
                  .reversed)),
          witness));
}

RawBlock parseRawBlock(String rawBlockHex) {
  final rawData = Uint8List.fromList(hex.decode(rawBlockHex));
  final versionBytes = rawData.sublist(0, 4);
  final version = versionBytes.buffer.asByteData().getUint32(0, Endian.little);
  final previousBlockHashBytes = rawData.sublist(4, 36);
  final previousBlockHash = hashDecode(previousBlockHashBytes);
  final merkleRootBytes = rawData.sublist(36, 68);
  final merkleRoot = hashDecode(merkleRootBytes);
  final timestampBytes = rawData.sublist(68, 72);
  final timestamp =
      timestampBytes.buffer.asByteData().getUint32(0, Endian.little);
  final bitsBytes = rawData.sublist(72, 76);
  final bits = bitsBytes.buffer.asByteData().getUint32(0, Endian.little);

  int? nHeight;
  String? mixhash;

  int nonce;
  int dataPtr;

  // TODO: Other nets
  if (timestamp > testnetConstants.kawpowActivationTimestamp) {
    final nHeightBytes = rawData.sublist(76, 80);
    nHeight = nHeightBytes.buffer.asByteData().getUint32(0, Endian.little);
    final nonceBytes = rawData.sublist(80, 88);
    nonce = nonceBytes.buffer.asByteData().getUint64(0, Endian.little);
    final mixhashBytes = rawData.sublist(88, 120);
    mixhash = hashDecode(mixhashBytes);

    dataPtr = 120;
  } else {
    final nonceBytes = rawData.sublist(76, 80);
    nonce = nonceBytes.buffer.asByteData().getUint32(0, Endian.little);

    dataPtr = 80;
  }

  final block = RawBlock(version, previousBlockHash, merkleRoot, timestamp,
      bits, nonce, nHeight, mixhash);

  final transactionVarIntTuple = readVarInt(rawData, dataPtr);
  dataPtr += transactionVarIntTuple.item1;

  for (var transactionCount = 0;
      transactionCount < transactionVarIntTuple.item2;
      transactionCount++) {
    final transactionTuple = _parseRawTransaction(rawData, dataPtr);
    dataPtr += transactionTuple.item1;

    block.transactions.add(transactionTuple.item2);
  }

  return block;
}
