#!/usr/bin/env python
### from within python, I can type 
#execfile("game_topology_scaling_dynamics.py")

#an ordinal game is a normal form economic game with n players and m strategies
#a strategy is what a player chooses. all players strategies are a list that uniquely determines anoutcome out of the list of outcomes that defines a game.
import numpy as np
import numpy.random 
from copy import deepcopy
import itertools
from pprint import pprint
#from numpy.math import factorial as factorial
#from scipy import factorial

from ordinalGameSolver import *

def factorial_recursive(n):
  if n <= 0: return( 1 )
  else: return( n*factorial_recursive(n-1) )






#http://planspace.org/2013/06/21/how-to-calculate-gini-coefficient-from-raw-data-in-python/
def gini(list_of_values):
    sorted_list = sorted(list_of_values)
    height, area = 0, 0
    for value in sorted_list:
        height += value
        area += height - value / 2.
    fair_area = height * len(list_of_values) / 2.
    return (fair_area - area) / fair_area

if __name__ == '__main__':
  g = OrdinalGame(2)
  g.outcomes = np.array([[[3,3],[1,4]],[[4,1],[2,2]]] )
  #g.outcomes = np.array((((3,3),(1,4)),((4,1),(2,2))) )
  g.name = "pd"
  #print ( g.outcomes )
  print(" test flipping of strategy sets" )
  print(all( g.outcomes[0][0] == g.outcomes[(0,0)] ) )
  print(all( [3,3] == g.outcomes[(0,0)] ) )
  print(g.outcomes[0][0][1] == 3 )
  print(g.flip([0,0],1) == (0,1) )
  print(g.flip([0,0],0)== (1,0) )
  strategy_set = [0,0]
  strategy_set = (0,0)
  print( " test indexing of outcomes via strategy sets" )
  print( g.outcomes[strategy_set[0]][strategy_set[1]][1] == g.outcomes[strategy_set][1] )
  print( g.outcomes[strategy_set[0]][strategy_set[1]][1] == 3 )
  print( g.payoff(strategy_set, 1) ==  3 )
  print( g.payoff(g.flip(strategy_set, 1), 1 ) == 4 )
  print( g.payoff(g.flip(strategy_set, 0), 1 ) == 1 )
  print( " test Nash testing" )
  print( g.isNash((0,0)) == False )
  print( g.isNash((1,0)) == False )
  print( g.isNash((0,1)) == False )
  print( g.isNash((1,1)) == True )

  print( " test three player games" )
  threep = OrdinalGame(3)
  threep.outcomes = np.array( [[[[1,1,1],[0,0,0]],[[0,0,0],[4,0,0]]], [[[0,0,0],[0,4,0]],[[0,0,4],[3,3,3]]]] )
  # if all agree then all get a payoff.  but if they are the only one to pick strategy one, they get lots more.
  threep2 = OrdinalGame(3)
  threep2.outcomes = np.array( [[[[1,1,1],[0,0,0]],[[0,0,0],[4,0,0]]], [[[0,0,0],[0,4,0]],[[0,0,4],[5,5,5]]]] )
  # if all agree then all get a payoff.  but if they are the only one to pick strategy one, they get lots more.
  s1 = (0,0,0) 
  s2 = (1,1,1) 
  s3 = (1,0,1) 
  s4 = (1,0,0) 
  print( all(threep.outcomes[s1] == [1,1,1]) )
  print( all(threep.outcomes[s3] == [0,4,0]) )
  print( threep.flip(s3, 1)== s2 )
  print( " test 3p Nash testing" )
  print( threep.flip(s4, 0)==s1 )
  print( threep.isNash(s1) == True )
  print( threep.isNash(s2) ==False )
  print( threep.isNash(s3) ==False )
  print( threep.isNash(s4) ==False )
  print( " more 3p Nash testing" )
  print( threep2.isNash(s1) == True )
  print( threep2.isNash(s2) == True )
  print( threep2.isNash(s3) ==False )
  print( threep2.isNash(s4) ==False )
  s = """
  So the number of strategies 

  OK, i've got the number of win-win games
  """


  print( " tests for two space" )
  ### count the number of 2x2 games
  twoSpace = Ordinal2PGameSpace()
  twoSpace.ngamesrecommended = 10000
  twoSpace.populateGameSpace(twoSpace.ngamesrecommended, False, strictlyOrdinal=True )
  games1 = twoSpace.attractorGames( twoSpace.games.values() )
  games2 = twoSpace.winWinAttractorGames( twoSpace.games.values() )
  #print( len( twoSpace.games.values()) )
  #print( len(twoSpace.winWinAttractorGames( twoSpace.games.values() )) )
  #for i in range(0, 10000):
    #aGame = twoSpace.generateRandomOrdinalGame()
    #if not aGame.gameID() in twoSpace.games: twoSpace.games[aGame.gameID()] = aGame
  print( len(twoSpace.games.keys())/4 == 144  )
  print( len(twoSpace.winwinattractorgames.keys())/2 == 54 )
  print( )
  print( " test heuristic Nash hunting" )
  fourSpace = OrdinalGameSpace(4)
  h = fourSpace.generateRandomOrdinalGame()
  h.outcomes
  h.findNashEq( fourSpace.orderedStrategySets, False)
  print( h.foundNashEq )

