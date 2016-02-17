The market cap of bitcoin is only in the billions. We want a cryptocurrency to be in the trillions as soon as possible, so that it can be used for commerce. 

Bitcoin only allows for the creation of a small fixed number of new coins per day. If I had $1 trillion, and I wanted to turn it all into bitcoin, I could not do it. There aren't enough bitcoins in existence.

The following proposal is for a POW system that would allow any amount of new coins to be created in a day. If I had a $ trillion, and I wanted to turn it all into bitcoin, I could. And the bitcoin market cap would be $1 trillion higher.

It is bad to connect the consensus mechanism to the coin creation mechanism, because the rate of coin creation should be determined by the demand for new coin.

When the demand for gold goes up, we invest more into mining, and rate of gold production increases to meet demand.
When the demand for bitcoin goes up, we invest more into mining, and the rate of coin production stays static.

Having a fixed unchanging rate of supply is bad. It makes the currency price very volatile.
What we really want is for it to always cost 1000 coins of POW to produce 1000 coins.

If we disconnect the consensus from coin creation, then we can create something much more elegant. We can sell small amount of coins for small amounts of POW to determine the current exchange rate between coins and POW, then offer to sell any amount of coins at the current exchange rate. The resulting blockchain would be able to grow it's market cap very quickly when it needs to, without changing the price of individual coins.

We need a mechanism to measure the current POW price. Then we can sell as many coins as they want at that price.
Below I will derive such a mechanism:
The block creator should choose a number B between 0 and 1. The bigger the B, the more work he has to do exponentially (w).

The optimal strategy of the block creator is to select B such that his reward is big, but the amount of work he has to do is small. Based on the number the block creator selects, we can approximate the real price of POW.

D is the money that is usually destroyed to create a block. The block creator can win some of it back by providing POW=w.
C is the 80th percentile amount of work the block creator provided over the last 100 blocks. Units of POW are scaled so that C is always = 1. It is measured in the number of times the hash function was called to create the digital artifact. 

POW-1(w) = 1/(1/w+1) is a mapping from any amount of work to the range 0-1. This is B, the portion of the reward that he wins back.
POW(x) = x*1/(1-x) is the inverse.

G(x) = f*POW(x) is the cost of the POW. f is the exchange rate. 
When the creator reveals w, we can derive B = w/(1+w), which gives us an estimate for f.
Since C is tuned to be 1, w will also usually be about 1, so B ~= 1/2.

0 = d/dx profit(x)|[x = 1/2] 

  = d/dx(reward(x) - G(x))|[x = 1/2] 

  = D - f*(((1/2)+1/2)/((1/2)^2))

-> 4f = D

-> f = D/4

-> G(x) = D*x/4/(1-x)

We want to find X s.t. G(X) = R(X)

D*X = D*X/4/(1-X) -> 1 = 4(1-X) -> X = 3/4

so the price is right where X=3/4. To win 3/4, you need to work 3/4 * C / (1/4) = 3*C.

The creator does 1/3 as much work to win 2/3 as much money. So that means the block creator pays 1/2 the normal price.