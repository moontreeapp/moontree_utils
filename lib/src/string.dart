String whiteSapce = '  ';
String punctuationProblematic = '`?:;"\'\\\$|/<>';
String punctuationNonProblematic = '~.,-_';
String punctuation =
    '$punctuationProblematic$punctuationNonProblematic[]{}()=+*&^%#@!';
String punctuationMinusCurrency =
    punctuation.replaceAll('.', '').replaceAll(',', '');
String alphanumeric = 'abcdefghijklmnopqrstuvwxyz12345674890';
String addressChars = alphanumeric
    .replaceAll('0', '')
    .replaceAll('o', '')
    .replaceAll('l', '')
    .replaceAll('i', '')
    .toUpperCase();
String base58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
String base58Regex = '[a-km-zA-HJ-NP-Z1-9]';
String assetBaseRegex = r'^[A-Z0-9]{1}[A-Z0-9_.]{2,29}[!]{0,1}$';
String subAssetBaseRegex = r'^[A-Z0-9]{1}[a-zA-Z0-9_.#]{2,29}[!]{0,1}$';
String mainAssetAllowed = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ._';
String verifierStringAllowed = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ._ (#&|!)';
String assetTypeIdentifiers = r'[/$#~!]';
String ravenBase58Regex([bool mainnet = true]) =>
    r'^' + (mainnet ? 'R' : '(m|n)') + r'(' + base58Regex + r'{33})$';
