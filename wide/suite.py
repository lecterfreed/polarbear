
import logging
import random
#import pandas as pd

from wide import *
from wide_sim import *


class Suite():

    def __init__(self, seeds=range(10)):
        self.seeds = seeds

    def run(self, param_dict):
        #index= pd.MultiIndex.from_product([self.seeds,
        #    range(param_dict['num_iter'])], names=['seed','iter'])   
        #suite_results = pd.DataFrame(
        #        index=index, columns=['assortativity'])
        suite_results = {}
        for seed in self.seeds:
            logging.critical('Running seed {}...'.format(seed))
            random.seed(seed)
            associates_graph = generate_associates_graph(param_dict['N'],
                param_dict['MIN_FRIENDS_PER_NEIGHBOR'],
                param_dict['NUM_IDEOLOGIES'])
            graph = generate_friends_graph(associates_graph,
                param_dict['env_openness'], param_dict['tolerance'],
                param_dict['MIN_FRIENDS_PER_NEIGHBOR'])
            results = run_bvm(graph, param_dict['num_iter'], False)
            suite_results[seed] = results
        return suite_results
