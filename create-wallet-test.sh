# ledger nano s/x

# ref: https://hwi.readthedocs.io/en/latest/examples/bitcoin-core-usage.html
#      https://github.com/bitcoin-core/HWI
# to build GUI run "pip3 install PySide2" followed by "./contrib/generate-ui.sh"
# install jq

# launch chipsd with the following params
#./chipsd -daemon -addresstype=bech32 -changetype=bech32
# if you already have a wallet use loadwallet rpc, otherwise it will be created on step 3
# ./chips-cli loadwallet ledger
# rm -rf ~/Library/Application\ Support/Chips/wallets/ledger

# step 1 get device fingerprint
fingerprint="$(./hwi.py enumerate | jq -r '.[].fingerprint')"
echo "ledger device fingerprint: ${fingerprint}"

# step 2 generate keypool
echo "generating a pool of 1000 addresses..."
keypool="$(./hwi.py -f $fingerprint getkeypool 0 1000)"
keypool_human_readable="$(echo $keypool | jq -rc)"
echo "keypool: ${keypool_human_readable}"

# step 3 create wallet and import wallet descriptors
echo "creating wallet 'ledger'..."
./chips-cli -named createwallet wallet_name=ledger disable_private_keys=true descriptors=true
echo "importdescriptors..."
#echo "$(./chips-cli -rpcwallet=ledger importdescriptors ${keypool_human_readable})"
./chips-cli -rpcwallet=ledger importdescriptors ${keypool_human_readable}

# step 4 get new native segwit receive address and display it's info
receive_address="$(./chips-cli -rpcwallet=ledger getnewaddress)"
echo "new native segwit receive address: ${receive_address}"
./chips-cli -rpcwallet=ledger getaddressinfo $receive_address

# step 5 display address on device screen
./hwi.py --fingerprint=$fingerprint displayaddress --path "m/84'/0'/0'/0/0"
