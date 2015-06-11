defmodule Talker do
  #this module creates and maintains connections with multiple peers. It downloads blocks from them.
  #grabs the list of peers from peers thread.
  #has ability to black-list peers who are bad?
  #don't talke to same peers too frequently
  #don't ignore any peer much longer than the others.
  #download blocks and peers.
  use GenServer
  @name __MODULE__
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [name: @name])
  end
  def start do spawn_link(fn() -> timer end) end
  def still_on(blocks) do
    blocks == :ok or blocks == [] or (is_tuple(hd(blocks)) and :error in Dict.keys(blocks))
  end
  def add_peers(x) do
    Enum.map(x, fn(x) -> Peers.add_peer(x) end)
  end
  def download_blocks(i, u, p) do
		#IO.puts("in talker p is #{inspect p}")
    blocks = Cli.download_blocks(min(50, u - i), i, p)
    my_block = Cli.blocks(i, i)
    cond do
      my_block == [] ->
        BlockAbsorber.absorb(blocks)
        [status: :first_blocks]
      still_on(my_block) -> IO.puts("thread died")
      still_on(blocks) -> IO.puts("peer died 0")
      hd(my_block).data.hash == hd(blocks).data.hash ->
        BlockAbsorber.absorb(blocks)
        [status: :ahead]
      true ->
        blocks = Cli.download_blocks(min(50, u), max(0, i-40), p)
        BlockAbsorber.absorb(blocks)
        [status: :fork, height: u, peer: p]
    end
  end
  def trade_peers(p) do
		keys = fn(z) -> Enum.map(z, fn({x, y}) -> x end) end
		my_peers = Cli.all_peers
    peers = Cli.all_peers(p)
		my_keys = keys.(my_peers)
		#IO.puts("my_keys #{inspect my_keys}")
		peers_keys = keys.(peers)
		#IO.puts("peers_keys #{inspect peers_keys}")
    if my_peers == :ok or peers == :ok do
      IO.puts("peer died 1")
    else
      not_yours = Enum.filter(my_peers, &(not elem(&1, 0) in peers_keys))
      not_mine = Enum.filter(peers, &(not elem(&1, 0) in my_keys))
			#IO.puts("not_mine #{inspect not_mine}")
			#IO.puts("not_yours #{inspect not_yours}")
      Enum.map(not_yours,&(Cli.add_peer(elem(&1, 1),p)))
      Enum.map(not_mine, &(Peers.add_peer(elem(&1, 1))))
    end
  end
  def check_peer(p) do #validating mode
    status = Cli.status(p)
		#IO.puts("status #{inspect status}")
    cond do
			not is_list(status) -> IO.puts "peer crashed"
      :error in Dict.keys(status) ->
        #IO.puts("error #{inspect status[:error]}")
				false
      status[:height] > 0 and is_number(status[:height]) ->
        x = Peers.get(p)
        |> Map.put(:height, status[:height])
        |> Map.put(:hash, status[:hash])
        #|> Peers.add_peer
				#IO.puts("add peer x #{inspect x}}")
				Peers.add_peer(x)
        check_peer_2(p, status)
			true -> IO.puts("nothing to do")
    end
  end
  def check_peer_2(p, status) do
		#IO.puts("check peer 2 #{inspect p}")
    trade_peers(p)
    txs = Cli.txs(p)
    u = status[:height]
    i = KV.get("height")
    cond do
      txs == :ok -> IO.puts("txs shouldn't be :ok")
      (txs != []) and length(txs)>0 and is_tuple(hd(txs)) ->
        IO.puts("tx error #{inspect txs}")
      u > i -> download_blocks(i, u, p)
      u == i -> Enum.map(txs, &(Mempool.add_tx(&1)))
      true ->
        IO.puts("im ahead")
        true
    end
  end
  def check_peers do
    Peers.get_all
    |> Enum.map(&(elem(&1,1)))
    |> Enum.map(&(spawn_link(fn -> check_peer(&1) end)))
   end
  def init(_) do
    start
    Enum.map(0..Constants.max_nodes, &(%Peer{ip: "localhost", port: Constants.tcp_port+&1})) 
    |> Enum.map(&(Peers.add_peer(&1)))
    {:ok, []}
  end
  def doit do GenServer.cast(@name, :doit) end
  def handle_cast(:doit, state) do
    check_peers
    {:noreply, state}
  end
  def timer do
    :timer.sleep(3000)
    doit
    timer
  end
end