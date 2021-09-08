## IBC relayer for kichain testnet

Instructions for installing and configuring the IBC relayer [strangelove-ventures](https://github.com/strangelove-ventures/relayer). At first, the [relayer](https://github.com/cosmos/relayer) was used, but it proved to be not very stable.

So, the initial state, we have two test nodes in two different cosmos blockchains - kichain and juno. They are running on the same virtual server, this will simplify setup a little.

First, we create a new user. This will simplify our administration.
Run as root or use the sudo utility:

	sudo useradd -m -G sudo -s /bin/bash relayer

Change the password of the created user:

	sudo passwd relayer

Switch to the created user and go to the home directory:

	su relayer
	cd ~

**Note:** it is advisable to create your own git repository in the home directory and add to it all the configurations files that will be created during the process of configuring the relayer.

For the relayer to work, the go compiler is required, but since it is already installed on the system, you need to specify this in the settings, and also create a directory for it to work:

	GOPATH = /usr/local/go
	PATH = $GOPATH/bin:$PATH
	mkdir -p ~/go/bin/
	echo "export PATH=$PATH:$(go env GOPATH)/bin" >> ~/.bash_profile
	source ~ / .bash_profile

Downloading the relayer source files from the github repository

	git clone https://github.com/strangelove-ventures/relayer.git

Go to the relayer directory and switch to branch 0.9.3

	cd relayer
	git checkout v0.9.3

Compiling the source code:

	make install

If everything went well, the rly utility will appear in the *~/go/bin/* directory.
All further configuration of the relayer will be done with its help.

Initializing the relayer:

	rly config init

The command will create a working directory for the relayer *~/.relayer/config/*

In it, you need to create two configuration files with the settings of our test networks:

	echo {"chain-id": "kichain-t-4", "rpc-addr": "http://127.0.0.1:26657", "account-prefix": "tki", "gas-adjustment": 1.5, "gas-prices": "1utki", "trusting-period": "24h"}> ~ / .relayer / config / kichain_config.json
	echo {"chain-id": "lucina", "rpc-addr": "http://127.0.0.1:26757", "account-prefix": "juno", "gas-adjustment": 1.5, "gas -prices ":" 1ujuno "," trusting-period ":" 24h "}> ~ / .relayer / config / juno_config.json

Add them to the main configuration file *~/.relayer/config/config.yaml* using the commands:

	rly chains add -f ~/.relayer/config/kichain_config.json
	rly chains add -f ~/.relayer/config/juno_config.json

We need create one account in each of our blockchains. We could use the accounts of validators, but I think it will not be safe if they store a considerable amount of tokens.
On the kichain network, I created a new account with the command:

	rly keys add kichain

It displays mnemonic and wallet address that need to be stored in a safe place. The wallet address looks like tki1u6fx6fwmjwq9c3qxrtt7r50jrsr3qnuskpj5nw
We need to send a few tokens to this address in the kichain network so that it can support the relayer operation:

	kid tx bank send wallet555 tki1u6fx6fwmjwq9c3qxrtt7r50jrsr3qnuskpj5nw 10000000utki --chain-id kichain-t-4

For juno network, I added an existing validator account:

	rly keys restore lucina lucina “<my mnemo phrase>”

where **my mnemo phrase** is my saved mnemonic phrase.
If you create a new one account, it is so necessary to send a certain amount of tokens to it for the relayer to work.

Let's establish a correspondence between accounts and their network:

	rly chains edit kichain-t-4 key kichain
	rly chains edit lucina key lucina

The relayer now has the ability to check the balance in each account:

	rly q balance kichain-t-4
	rly q balance lucina

Initializing light clients:

	rly light init kichain-t-4 -f
	rly light init lucina -f

We create channels between blockchains:

	rly paths generate kichain-t-4 lucina transfer –port=transfer

We open channels:

	rly tx link transfer

If everything went well, we can start the relayer:

	rly start transfer

It will connect to our blockchains via RPC and will see all transactions. If any transaction is intended for its, relayer will try to relay it to the second blockchain
To send a transaction from the kichain blockchain to the juno blockchain, use the command:

	kid tx ibc-transfer transfer transfer channel-109 juno1n6hsd8we9s9ww3ahfwsa9nxlxfp3szlwheg6kl 10utki --from wallet555 --home kid/ --chain-id kichain-t-4
where *channel-109* is a channel created by a relayer. It can be found in the config file *~/.relayer/config/config.yaml*
