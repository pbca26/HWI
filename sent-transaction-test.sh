# ledger nano s/x

# launch chipsd with the following params
#./chipsd -daemon -addresstype=bech32 -changetype=bech32
# if you already have a wallet use loadwallet rpc, otherwise it will be created on step 3
# ./chips-cli loadwallet ledger
# use this command if you have small CHIPS funds in your wallet
# ./chips-cli -rpcwallet=ledger settxfee 0.00001

# step 1 get device fingerprint
fingerprint="$(./hwi.py enumerate | jq -r '.[].fingerprint')"
echo "ledger device fingerprint: ${fingerprint}"

# step 2 create psbt transaction
psbt="$(./chips-cli -rpcwallet=ledger walletcreatefundedpsbt '[]' '[{"RKJ7w414rXMyqUgE2NNE29xSLNY119NqNs":0.00001}]' 0 '{"includeWatching":true}' true | jq -r '.psbt')"
echo "psbt hex: ${psbt}"

# step 3 display decoded psbt transaction
echo "decoded psbt"
./chips-cli decodepsbt $psbt

# step 4 sign psbt transaction
echo "follow instructions on device display to sign transaction"
psbt="$(./hwi.py -f ${fingerprint} signtx ${psbt} | jq -r '.psbt')"
echo "signed psbt hex: ${psbt}"

# step 4 display decoded signed psbt transaction
echo "decoded signed psbt"
./chips-cli decodepsbt $psbt

# step 5 finalize signed psbt transaction
echo "finalized transaction hex"
rawtx_hex="$(./chips-cli finalizepsbt $psbt | jq -r '.hex')"
echo $rawtx_hex

# broadcasted tx example: https://explorer.chips.cash/tx/933c1f0c2b8f7ba023db3b65324d444eb022cccd3d4fcf59f9f7575e8d52adb8

# note: native segwit has different addresses displayed on the screen and strange output order sequence (if send to bech32 address it asks to verify output #2 which is a change address). This is only applicable to chipsd, electrum wallet shows correct native segwit addresses.
