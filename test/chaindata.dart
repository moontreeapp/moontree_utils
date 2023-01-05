import 'package:test/test.dart';
import 'package:moontree_utils/moontree_utils.dart';

void main() {
  test('Test chaindata map', () async {
    /// if you explicitly import these objects they will be found on the class.
    //ravencoinMainnetChaindata;
    //ravencoinTestnetChaindata;
    //evrmoreMainnetChaindata;
    //evrmoreTestnetChaindata;
    //print(Chaindata.chains);
    //expect(getChaindataFor('ravencoin_mainnet').symbol, 'RVN');
    //expect(getChaindataFor('evrmore_testnet').name, 'evrmore_testnet');
    //expect(Chaindata.chains['ravencoin_mainnet']?.symbol, 'RVN');
    //expect(Chaindata.chains['nothing']?.symbol, null);
    //expect(Chaindata.chains['evrmore_testnet']?.symbol, 'EVR');
    //expect(Chaindata.chains['evrmore_testnet']?.name, 'evrmore_testnet');

    expect(Chaindata.from('ravencoin_mainnet').symbol, 'RVN');
    expect(Chaindata.from('nothing').symbol, 'RVN');
    expect(Chaindata.from('evrmore_testnet').symbol, 'EVR');
    expect(Chaindata.from('evrmore_testnet').name, 'evrmore_testnet');
  });
}
