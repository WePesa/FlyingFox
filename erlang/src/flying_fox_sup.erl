-module(flying_fox_sup).
-behaviour(supervisor).
-export([start_link/0,init/1]).
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).
init([]) ->
    Children = 
	[ 
	  ?CHILD(keys, worker),
	  ?CHILD(kv, worker),
	  ?CHILD(finality_accounts, worker),%rename to accounts
	  ?CHILD(finality_channels, worker),
	  ?CHILD(blocktree_kv, worker),
	  ?CHILD(block_dump, worker),
	  ?CHILD(block_pointers, worker),
	  ?CHILD(block_finality, worker),
	  ?CHILD(block_tree, worker),
	  ?CHILD(block_blacklist, worker)
	],
    {ok, { {one_for_one, 5, 10}, Children} }.