#!/usr/bin/env python3

import igraph
import random
import os
import sys
import logging

from wide import *
from wide_sim import *


def print_usage():
    print('Usage: main_wide.py [env_openness=#] [tolerance=#] [sweep=#] ' +
        '[seed=#] [logLevel=level|NONE].')

if len(sys.argv) > 5:
    print_usage()
    sys.exit(1)

this_module = sys.modules[__name__]

for arg in sys.argv[1:]:
    if not '=' in arg:
        print("Malformed argument '{}'.".format(arg))
        print_usage()
        sys.exit(2)
    arg_name, arg_val = arg.split('=')
    try:
        setattr(this_module, arg_name, float(arg_val))
    except:
        setattr(this_module, arg_name, arg_val)

params = [
    ('env_openness',.5),
    ('tolerance',.5),
    ('sweep',0),
    ('seed',0),
    ('logLevel','INFO')]
for (param,default) in params:
    if not hasattr(this_module, param):
        setattr(this_module, param, default)

if logLevel == 'NONE':
    logging.getLogger().setLevel(logging.CRITICAL + 1)
else:
    logging.getLogger().setLevel(logLevel)

if seed in (0,None):
    seed = random.randrange(10000)



# Other configuration parameters.
N = 50
MIN_FRIENDS_PER_NEIGHBOR = 3
NUM_IDEOLOGIES = 3
NUM_ITER = 200


if sweep:
    pass
else:
    print('=== Using seed {}.'.format(seed))
    print("=== tolerance={}, env_openness={}, N={}, MIN_FRIENDS={}.".format(
        tolerance, env_openness, N, MIN_FRIENDS_PER_NEIGHBOR))
    print("=== NUM_ITER={}, NUM_IDEOLOGIES={}.".format(NUM_ITER, 
                                                            NUM_IDEOLOGIES))
    random.seed(seed)

    associates_graph = generate_associates_graph(N, MIN_FRIENDS_PER_NEIGHBOR,
        NUM_IDEOLOGIES)
    graph = generate_friends_graph(associates_graph, env_openness, tolerance,
        MIN_FRIENDS_PER_NEIGHBOR)
    results = run_bvm(graph, NUM_ITER, True)
    with open('/tmp/results.csv','w') as f:
        results.to_csv(f)
    print('results at /tmp/results.csv.')
    os.system('./plotSingle.R --args /tmp/results.csv')
