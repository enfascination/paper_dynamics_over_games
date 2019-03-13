#!/usr/bin/env python
### from within python, I can type 
#execfile("sim_game_topology_scaling_dynamics.py")

from game_topology_scaling_dynamics import *
import cProfile
from time import clock
#import simplejson ###stackoverflow python-write-a-list-to-a-file
import sys
import csv

def runClassifyAttractors(i, reps=10000):
    space = OrdinalGameSpace(i)
    space.ngamesrecommended=reps
    #print( "players: %d\noutcomes: %d"%(i,space.noutcomes) )
    #print( "games, total: (2^%d)!^%d\ngames, sample size: %d"%(i, i, space.ngamesrecommended ) )
    space.populateGameSpace( space.ngamesrecommended, True  )
    dist = space.classifyGameAttractors( space.games.values() )
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

def runGameFairness(i, reps=10000, useGini=True, mode="attractors"):
    space = OrdinalGameSpace(i)
    space.ngamesrecommended=reps
    #print( "players: %d\noutcomes: %d"%(i,space.noutcomes) )
    #print( "games, total: (2^%d)!^%d\ngames, sample size: %d"%(i, i, space.ngamesrecommended ) )
    space.populateGameSpace( space.ngamesrecommended, True  )
    if mode == "attractors":
        games = space.attractorGames( space.games.values() )
    elif mode == "all_games":
        games = space.games.values()
    ### start to measure ineqaulity of each game
    nstrats = len(space.orderedStrategySets)
    inequalitiesGames = [0] * len( games )
    inequalityGame =  [0] * nstrats
    inequalitiesOutcomes = []
    for j, g in enumerate( games ):
        ### get average gini of all of this game's outcomes
        for k, o in enumerate(space.orderedStrategySets):
            if useGini:
                inequalityGame[k] = gini( g.outcomes[ o ] )
            else:
                inequalityGame[k] = np.var( g.outcomes[ o ] / nstrats )
        inequalitiesGames[j] = np.mean( inequalityGame )
        ### now just on its one nash outcome
        ###     over mode=attractors, foundNashEq will aleays have one.  ove rth oether mode, there could be zero or severeal nash eq per game.
        for nashIndex in g.foundNashEq: 
            if useGini:
                inequalitiesOutcomes.append( gini( g.outcomes[ nashIndex ] ) )
            else:
                inequalitiesOutcomes.append( np.var( g.outcomes[ nashIndex ]  / nstrats ) )
    return( (mode, i, np.mean( inequalitiesGames ), np.mean( inequalitiesOutcomes ) ) )


with open("./sim_inequality_dataout.txt", "w") as output:
    csvwriter = csv.writer(output)
    #for i in tuple([2,9,8, 9,8,9,8,7,7,9,8,9,8,10]):
    #for i in (6,7,8):
    for i in range(2,9):
        #start = clock()
        out = runGameFairness(i, 100000, mode="attractors")
        csvwriter.writerow( out )
        print( out )
        out = runGameFairness(i, 100000, mode="all_games")
        csvwriter.writerow( out )
        print( out )
    out = runGameFairness(9, 20000, mode="attractors")
    csvwriter.writerow( out )
    print( out )
    out = runGameFairness(9, 20000, mode="all_games")
    csvwriter.writerow( out )
    print( out )

