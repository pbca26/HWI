# ledger nano s/x
# ref: https://github.com/bitcoin/bitcoin/blob/master/doc/external-signer.md

# launch chipsd with the following params
# ./chipsd -signer=hwi.py -daemon -addresstype=bech32 -changetype=bech32
# if you already have a wallet use loadwallet rpc, otherwise it will be created on step 3
# ./chips-cli loadwallet hww

# step 1 get device fingerprint
fingerprint="$(./chips-cli enumeratesigners | jq -r '.signers[].fingerprint')"
echo "ledger device fingerprint: ${fingerprint}"

# step 2 generate keypool
echo "generating a pool of 1000 addresses..."
keypool="$(./hwi.py -f $fingerprint getkeypool 0 1000)"
keypool_human_readable="$(echo $keypool | jq -rc)"
echo "keypool: ${keypool_human_readable}"

# step 3 create wallet and import wallet descriptors
echo "creating wallet 'hww'..."
./chips-cli createwallet "hww" true true "" true true true
# for some reasone createwallet doesn't import wallet descriptors automatically
# need to import manually
# if descriptors are not imported chips-cli getnewaddress yields the following error
# error code: -4
# error message:
# Error: This wallet has no available keys

echo "importdescriptors..."
#echo "$(./chips-cli -rpcwallet=ledger importdescriptors ${keypool_human_readable})"
./chips-cli -rpcwallet=hww importdescriptors ${keypool_human_readable}

# step 4 (optional) rescan the wallet to make funds visible for the daemon
#./chips-cli rescanblockchain 8491100

# step 5 get new address
./chips-cli -rpcwallet=hww getnewaddress

# step 6 display display address on the screen
./chips-cli -rpcwallet=hww walletdisplayaddress bc1q8ldt3av53n7wjq0s0k8wwsyqxr8jn74r5x2q82
# doesn't work for some reason, tried on nano x and nano s
# throws the following error
# error code: -1
# error message:
# Failed to display address

# this works fine to display an address
./hwi.py --fingerprint=$fingerprint displayaddress --path "m/84'/0'/0'/0/0"

# step 7 send transaction
./chips-cli -rpcwallet=hww sendtoaddress bc1q8ldt3av53n7wjq0s0k8wwsyqxr8jn74r5x2q82 0.00001
# doesn't work for some reason, tried on nano x and nano s
# throws the following error
# error code: -4
# error message:
# Error: Private keys are disabled for this wallet

# see send-transaction-test.sh for a detailed example how to create and sign a transaction using hwi.py
