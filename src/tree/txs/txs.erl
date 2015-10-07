%each tx with a fee needs a to reference a recent hash. Everyone needs to be incentivized to make the hash as recent as possible.

-module(txs).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2, dump/0,txs/0,digest/5,test/0]).
init(ok) -> {ok, []}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("txs died!"), ok.
handle_info(_, X) -> {noreply, X}.

handle_call(txs, _From, X) -> {reply, X, X}.
handle_cast(dump, _) -> {noreply, []};
handle_cast({add_tx, Tx}, X) -> {noreply, [Tx|X]}.
dump() -> gen_server:cast(?MODULE, dump).
txs() -> gen_server:call(?MODULE, txs).
-record(signed, {data="", sig="", sig2="", revealed=[]}).
-record(sign_tx, {acc = 0, nonce = 0, secret_hash = [], winners = [], prev_hash = ""}).
winners(Txs) -> winners(Txs, 0).
winners([], X) -> X;
winners([#signed{data = Tx}|T], X) when is_record(Tx, sign_tx) -> 
    winners(T, X+length(Tx#sign_tx.winners));
winners([_|T], X) -> winners(T, X).
digest(Txs, ParentKey, Channels, Accounts, BlockGap) ->
    Winners = winners(Txs),
    digest(Txs, ParentKey, Channels, Accounts, BlockGap, Winners).
digest([], _, Channels, Accounts, _, _) -> {Channels, Accounts};
digest([SignedTx|Txs], ParentKey, Channels, Accounts, BlockGap, Winners) ->
    true = sign:verify(SignedTx, Accounts),
    Tx = SignedTx#signed.data,
    {NewChannels, NewAccounts} = 
	case element(1, Tx) of
            sign_tx -> sign_tx:doit(Tx, ParentKey, Channels, Accounts, Winners);
            ca -> create_account_tx:doit(Tx, ParentKey, Channels, Accounts);
            spend -> spend_tx:doit(Tx, ParentKey, Channels, Accounts);
            da -> delete_account_tx:doit(Tx, ParentKey, Channels, Accounts);
            sign -> sign_tx:doit(Tx, ParentKey, Channels, Accounts);
            slasher -> slasher_tx:doit(Tx, ParentKey, Channels, Accounts);
            reveal -> reveal_tx:doit(Tx, ParentKey, Channels, Accounts);
            tc -> to_channel_tx:doit(SignedTx, ParentKey, Channels, Accounts, BlockGap);
            channel_block -> channel_block_tx:doit(Tx, ParentKey, Channels, Accounts);
            timeout -> channel_timeout_tx:doit(Tx, ParentKey, Channels, Accounts, BlockGap);
            channel_slash -> channel_slash_tx:doit(Tx, ParentKey, Channels, Accounts);
            channel_close -> channel_close_tx:doit(Tx, ParentKey, Channels, Accounts);
            _ -> 
		io:fwrite(packer:pack(Tx)),
		1=2
        end,
    digest(Txs, ParentKey, NewChannels, NewAccounts, BlockGap, Winners).

test() -> 0.
