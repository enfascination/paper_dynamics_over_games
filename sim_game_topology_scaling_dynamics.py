#!/usr/bin/env python
### from within python, I can type 
#execfile("sim_game_topology_scaling_dynamics.py")

from game_topology_scaling_dynamics import *
import cProfile
from time import clock
#import simplejson ###stackoverflow python-write-a-list-to-a-file
import sys
import csv

def runClassifyAttractors(i, reps=10000, parallelize=False):
    space = OrdinalGameSpace(i)
    space.ngamesrecommended=reps
    #print( "players: %d\noutcomes: %d"%(i,space.noutcomes) )
    #print( "games, total: (2^%d)!^%d\ngames, sample size: %d"%(i, i, space.ngamesrecommended ) )
    parallelize = False if i < 3 else parallelize ## below 4 is like arbitrary termination, which I can't get in parallel (and below which I don't need parallel)
    space.populateGameSpace( space.ngamesrecommended, True , parallelize=parallelize )
    dist = space.classifyGameAttractors( space.games.values())
    for j in range(i+3):
        commentary = "%d winner attractor games "%(j-2)
        if j==1: commentary="0 winner games (non-attractors, 1 Nash)"
        elif j==i+2: commentary="%d winner games (win-win attractors)"%(j-2)
        elif j==0: commentary="games without Nash eq."
        elif j==2: commentary="games with multiple Nash eq."
        print( "%s: %d"%(commentary, dist[j]) )

    print( "total games: %d, attractor games: %d  win-win games: %d"%(len( space.games.values() ), len(space.attractorGames( space.games.values() )),len(space.winWinAttractorGames( space.games.values() ))) )
    #print( "mean length of trajectories: %d"%(0,) )
    dist = list(dist)
    dist.insert(0, i)
    dist.insert(1, reps )
    return( dist )


reps = 200000
with open("./data_phase1.csv", "a") as output_summary:
    #header1 = ("space", "population", "reps", "game_ineq", "nash_ineq", "nash_count")
    #header2 = ("space", "outcomes", "population", "reps", "lots  of values"))
    header1 = ( "exp_num", "population", "nruns", "unstable0eq", "unstable1eq", "unstableneq", "stable1boss", "stable2boss", "stable3boss", "stable4boss", "stable5boss", "stable6boss", "stable7boss", "stable8boss", "stable9boss")
    summarywriter = csv.writer(output_summary)
    print( header1)
    summarywriter.writerow(header1)
    if True:
        #for i in tuple([2,9,8, 9,8,9,8,7,7,9,8,9,8,10]):
        #for i in (6,7,8):
        for j in range(1):
            for i in range(2,10):
                ### actual reps will be a bit lower than target reps when parallelize is True. it's fine
                out = runClassifyAttractors(i, reps, parallelize=True)
                out.insert(0, j)
                out.extend( [-1, ]*( len(header1) - len(out) ))
                summarywriter.writerow( out )
                print( out )
