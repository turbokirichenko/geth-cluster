#!/bin/ash

BOOTNODE_TARGET="bootnode"
SIGNER_TARGET="signer"
NODE_TARGET="node"
GETH_BIN=/usr/local/bin/geth
BOOTNODE_BIN=/usr/local/bin/bootnode
DELAY_ASLEEP=8

if [ $TARGET == $BOOTNODE_TARGET ]; then
	# 
	
	# startup bootnode
	$GETH_BIN init --datadir $SHARED_DIR/$BOOTNODE_DIR $CONFIG_DIR/$GENESIS_FILE
	$GETH_BIN --datadir $SHARED_DIR/$BOOTNODE_DIR --networkid $NETWORKID --nat extip:$BOOTNODE_ADDRESS --port $BOOTNODE_PORT
elif [ $TARGET == $SIGNER_TARGET ] || [ $TARGET == $NODE_TARGET ]; then
	# generated address

	# startup signer
	# waiting for bootnode is startup
	sleep $DELAY_ASLEEP
	# getting voonode enode to connect
	BOOTNODE_PUBLIC_KEY=$($BOOTNODE_BIN -nodekey $SHARED_DIR/$BOOTNODE_DIR/geth/nodekey -writeaddress)
	BOOTNODE_ENCODE_URL=enode://$BOOTNODE_PUBLIC_KEY@$BOOTNODE_ADDRESS:$BOOTNODE_PORT
	# init node
	echo "INFO: connecting to $BOOTNODE_ENCODE_URL"
	$GETH_BIN init --datadir $SHARED_DIR/$NODE_DIR $CONFIG_DIR/$GENESIS_FILE
	# set signer options
	SIGNER_ARGS=""
	if [ $TARGET == $SIGNER_TARGET ]; then
		ADDRESS=$(cat $SHARED_DIR/$NODE_DIR/address.txt)
		SIGNER_ARGS="--unlock $ADDRESS --password $SHARED_DIR/$NODE_DIR/password.txt --mine --miner.etherbase $ADDRESS"
	fi
	HTTP_SERVER_ARGS=""
	if [ ! -z $HTTP_PORT ]; then
		HTTP_SERVER_ARGS="--http --http.port $HTTP_PORT --http.corsdomain '*' --http.api eth,net,web3"
	fi
	#enable metrics
	METRICS_ARGS=""
	if [ ! -z $ENABLE_METRICS ] && [ ! -z $METRICS_PORT ]; then
		METRICS_ARGS="--metrics --metrics.addr 0.0.0.0 --metrics.port $METRICS_PORT"
	fi
	# startup node with options
	$GETH_BIN --datadir $SHARED_DIR/$NODE_DIR \
		--networkid $NETWORKID \
		--bootnodes $BOOTNODE_ENCODE_URL \
		--nat extip:$IPV4_ADDRESS \
		--port $NODE_PORT $SIGNER_ARGS $HTTP_SERVER_ARGS $METRICS_ARGS
else
    echo "ERROR: Invalid TARGET=$TARGET"
	exit 1
fi