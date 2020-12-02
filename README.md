# Code for paper "A dynamic over games drives selfish agents to win-win outcomes" by Seth Frey, Curtis Atkisson
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4301086.svg)](https://doi.org/10.5281/zenodo.4301086)

### `sim_game_topology_scaling_dynamics.py`

Main functionality in `sim_game_topology_scaling_dynamics.py`. (test with `python sim_game_topology_scaling_dynamics.py`) 
It searches the spaces of n=2-9 player games with the property of having different numbers of pure Nash eq (whch reproduces Poisson distribution result) and the number of game that have the property of being attractor games, and the distribution of winners within attractor games.
file output gives different number of columns depending on size of game space. It is used to produce Figure 4a. Columns:
 *  number of players in the space
 *  number of reps: number of games in the space searched
 *  number of games with no pure Nash eq
 *  number of games with 1 pure Nash eq. that are not attractors
 *  number of games with multiple pure Nash eq
 *  number that are attractors and have 1 player getting the maximum payoff in the Nash outcome
 *  ...
 *  number that are attractors and have n players getting the maximum payoff in the Nash outcome (these are win-win attractors)
Values in latter columns are -1 if they refer to numbers of players that are bigger than the numer of players in the row's game space (can't be a 9-winner attractor in the 2-player game space)
printed output gives rich summary of file output


### `sim_game_topology_scaling_dynamics_inequality.py`

Main functionality in `sim_game_topology_scaling_dynamics_inequality.py`. test with `python sim_game_topology_scaling_dynamics_inequality.py` 
Output is one row per series of simulations.  
 *  __space__: Were the simulations run among *all_games* or just among games that are *attractors*.
 *  __population__: This is a number, the number of players in the space of games being played: sampling from the space of 3 player games, then up through 4 to 9 or 10.  2 player games are not sampled because they can be queried exhaustively.
 *  __reps__: The number of simulations run in the reported subspace. One game gets queried per simulation.
 *  __game_ineq__: The output of a game-level measure of inequality: the average over all simulation runs, all games in a run, all outcomes in a game. Outcome inequality is GINI over payoffs.
 *  __nash_ineq__: The average outcome-level inequality for outcomes that are Nash eq. 
 *  __nash_count__: The number of Nash eq outcomes that were found over the course of the simulation.

Two files that are output from the main function `sim_inequality_dataout.txt` and `sim_inequality_full_dataout.txt`. The former gives the same output as above in `csv`.  The latter gives one row per series of simulations, the first columns matching the above, and subsequent n columns, for reps=n, the calculated GINI for each of n runs.   Figure 4b can be generated from the latter.


### `sim_2p_game_attractors.py`

Other main function: `sim_2p_game_attractors.py` (run with `python sim_2p_game_attractors.py`). Figure 3 can be built by hand from the output of this, which finds the attractor games of the 2p space exhaustively.

### `topology_sim_analysis001.r`

Main script `topology_sim_analysis001.r` (run `Rscript topology_sim_analysis001.r` ) produces figure 4 and exploratory plots from collected data.

### Supporting files

Supporting functions in `ordinalGameSolver.py`. (test with `python ordinalGameSolver.py`). Implements basic constructs of game theory in 2x2x...x2 ordinal games 
Supporting functions in `game_topology_scaling_dynamics.py`. (test with `python game_topology_scaling_dynamics.py`). Implements larger spaces of ordinal games 

