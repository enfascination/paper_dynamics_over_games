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
    return( float('%.5f'%np.mean( inequalityGame )), float('%.5f'%inequalityOutcome) if inequalityOutcome else None )

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
    return( [(mode, i, reps, gamesMean, outcomesMean, len(inequalitiesOutcomes) ), inequalitiesGames, inequalitiesOutcomes] )


reps = 2000000
with open("./sim_inequality_dataout.txt", "a") as output_summary, open("./sim_inequality_full_dataout.txt", "a") as output_specific:
    header1 = ("space", "population", "reps", "game_ineq", "nash_ineq", "nash_count")
    #header2 = ("space", "outcomes", "population", "reps", "lots  of values"))
    summarywriter = csv.writer(output_summary)
    giniwriter = csv.writer(output_specific)
    print( header1)
    summarywriter.writerow(header1)
    #for i in tuple([2,9,8, 9,8,9,8,7,7,9,8,9,8,10]):
    #for i in (6,7,8):
    if True:
        for i in range(int(reps/500000)):
            for i in range(3,10):
                #start = clock()
                out, inequalitiesAttractorGamesAllOutcomes, inequalitiesAttractorGamesNashOutcomes = runGameFairness(i, 500000, mode="attractors", parallelize=True)
                summarywriter.writerow( out )
                print( out )
                out, inequalitiesAllGamesAllOutcomes, inequalitiesAllGamesNashOutcomes = runGameFairness(i, 500000, mode="all_games", parallelize=True)
                summarywriter.writerow( out )
                print( out )
                ### prep raw gini scores, for error bars
                
                if True:
                    #giniwriter.writerow((["attractor_gamess", "all_outcomes", i, 500000, ] + list(inequalitiesAttractorGamesAllOutcomes)))
                    giniwriter.writerow((["attractor_gamess", "nash_outcomes", i, 500000, ] + list(inequalitiesAttractorGamesNashOutcomes)))
                    #giniwriter.writerow((["all_games", "all_outcomes", i, 500000, ] + list(inequalitiesAllGamesAllOutcomes)))
                    giniwriter.writerow((["all_games", "nash_outcomes", i, 500000, ] + list(inequalitiesAllGamesNashOutcomes)))
