#!/usr/bin/env python
### from within python, I can type 
#execfile("sim_game_topology_scaling_dynamics.py")

from game_topology_scaling_dynamics import *
import cProfile
from time import clock
#import simplejson ###stackoverflow python-write-a-list-to-a-file
import sys
import csv
import multiprocessing
from functools import partial

def runClassifyAttractors(i, reps=10000, parallelize=False):
    space = OrdinalGameSpace(i)
    space.ngamesrecommended=reps
    #print( "players: %d\noutcomes: %d"%(i,space.noutcomes) )
    #print( "games, total: (2^%d)!^%d\ngames, sample size: %d"%(i, i, space.ngamesrecommended ) )
    parallelize = False if i < 3 else parallelize ## below 4 is like arbitrary termination, which I can't get in parallel (and below which I don't need parallel)
    space.populateGameSpace( space.ngamesrecommended, True , parallelize=parallelize )
    dist = space.classifyGameAttractors( space.games.values())
    for j in range(i+3):
        commentary = "%d winner attractor games "%j
        if j==0: commentary="%d winner games (non-attractors)"%j
        elif j==i: commentary="%d winner games (win-win attractors)"%j
        elif j==i+1: commentary="games without Nash eq."
        elif j==i+2: commentary="games with multiple Nash eq."
        print( "%s: %d"%(commentary, dist[j]) )

    print( "attractor games: %d  win-win games: %d"%(len(space.attractorGames( space.games.values() )),len(space.winWinAttractorGames( space.games.values() ))) )
    #print( "mean length of trajectories: %d"%(0,) )
    dist = list(dist)
    dist.append(i)
    dist.append(reps)
    return( dist )

### helper for parallelization.  takes a game and computes he inequalities of its outcomes, with special treatmetnfor its nash outcomes
def calcInequalities(g, orderedStrategySets, nstrats, useGini):
    inequalityGame =  [0] * nstrats
    inequalityOutcome = None
    ### get average gini of all of this game's outcomes
    for k, o in enumerate(orderedStrategySets):
        if useGini:
            inequalityGame[k] = gini( g.outcomes[ o ] )
        else:
            inequalityGame[k] = np.var( g.outcomes[ o ] / nstrats )
    ### now just on its one nash outcome
    ###     over mode=attractors, foundNashEq will aleays have one.  ove rth oether mode, there could be zero or severeal nash eq per game.
    for nashIndex in g.foundNashEq:
        if useGini:
            inequalityOutcome = gini( g.outcomes[ nashIndex ] )
        else:
            inequalityOutcome = np.var( g.outcomes[ nashIndex ]  / nstrats )
    return( np.mean( inequalityGame ), inequalityOutcome )

def runGameFairness(i, reps=10000, useGini=True, mode="attractors", parallelize=False):
    space = OrdinalGameSpace(i)
    space.ngamesrecommended=reps
    #print( "players: %d\noutcomes: %d"%(i,space.noutcomes) )
    #print( "games, total: (2^%d)!^%d\ngames, sample size: %d"%(i, i, space.ngamesrecommended ) )
    parallelize = False if i < 3 else parallelize ## below 4 is like arbitrary termination, which I can't get in parallel (and below which I don't need parallel)
    space.populateGameSpace( space.ngamesrecommended, True, parallelize=parallelize  )
    if mode == "attractors":
        games = space.attractorGames( space.games.values() )
    elif mode == "all_games":
        games = space.games.values()
    ### start to measure ineqaulity of each game
    nstrats = len(space.orderedStrategySets)
    inequalitiesGames = [0] * len( games )
    inequalitiesOutcomes = []
    if parallelize:
        calcInequalitiesPartial = partial( calcInequalities, orderedStrategySets = space.orderedStrategySets, nstrats=nstrats, useGini=useGini)
        with multiprocessing.Pool( multiprocessing.cpu_count() ) as p:
            inequalitiesGames, inequalitiesOutcomes = zip(*p.map(calcInequalitiesPartial, games))
    else:
        for j, g in enumerate( games ):
            inequalityGame, inequalityOutcome = calcInequalities(g, space.orderedStrategySets, nstrats, useGini)
            inequalitiesGames[j] = inequalityGame
            inequalitiesOutcomes.append( inequalityOutcome )
    inequalitiesOutcomes = [o for o in inequalitiesOutcomes if o is not None]
    gamesMean = np.mean( inequalitiesGames )
    outcomesMean = np.mean( inequalitiesOutcomes )
    return( (mode, i, gamesMean, outcomesMean ) )


with open("./sim_inequality_dataout.txt", "a") as output:
    csvwriter = csv.writer(output)
    #for i in tuple([2,9,8, 9,8,9,8,7,7,9,8,9,8,10]):
    #for i in (6,7,8):
    if False:
        for i in range(2,9):
            #start = clock()
            out = runGameFairness(i, 100000, mode="attractors", parallelize=True)
            csvwriter.writerow( out )
            print( out )
            out = runGameFairness(i, 100000, mode="all_games", parallelize=True)
            csvwriter.writerow( out )
            print( out )
        out = runGameFairness(9, 20000, mode="attractors", parallelize=True)
        csvwriter.writerow( out )
        print( out )
        out = runGameFairness(9, 20000, mode="all_games", parallelize=True)
        csvwriter.writerow( out )
    out = runGameFairness(10, 3000, mode="attractors", parallelize=True)
    csvwriter.writerow( out )
    print( out )
    out = runGameFairness(10, 3000, mode="all_games", parallelize=True)
    csvwriter.writerow( out )
    print( out )

