import casadi as ca
import casiopeia as cp  # casiopeia requires Casadi v2.4.3. Modify PYTHONPATH.
import numpy as np
from pyDOE import lhs
import pandas as pd
import cPickle as pickle
import sys
import matplotlib.pyplot as plt
import seaborn as sns
from mpl_toolkits.mplot3d import Axes3D
from progress.bar import Bar


# Options
sns.set_style('white')


def run_system(system, param, ic, time_points):
    ''' Run system for given parameter set using casiopeia and
        return information about success or failure.

        Args
        -----
        system (casiopeia.system.System): ODE system to simulate
        param (list): parameter set that `system` can accept
        ic (list): initial condition that `system` can accept
        time_points (np.ndarray): time points at which to simulate the system;
            typically the output of `np.linspace`.

        Returns
        -------
        dict: keys 'code', 'msg', 'values'
    '''

    sim = cp.sim.Simulation(system, param)
    try:
        sim.run_system_simulation(time_points=time_points, x0=ic,
                                  print_status=False)
        ymeas = sim.simulation_results.full()
        out = {'code': 0, 'msg': 'success', 'values': ymeas}
    except:
        e = sys.exc_info()[0]
        out = {'code': -1, 'msg': repr(e), 'values': None}
    return out


def get_lhs_samples(bounds, nsamples):
    ''' Generate parameter samples using Latin Hypercube Sampling Design.

        Args
        -----
        bounds (pd.DataFrame): dataframe (nparam x 3). Each row contains
            'upper' and 'lower' bounds.
        nsamples (int): number of samples to generate

        Returns
        -------
        np.ndarray of size (nsamples x nparam)
    '''
    nparam = bounds.shape[0]
    lhs_design = lhs(n=nparam, samples=nsamples, criterion='center')
    slope_vec = (bounds['upper'] - bounds['lower']).values
    slope_vec = slope_vec.reshape((1, nparam))
    param_samples = bounds['lower'].values.reshape((1, nparam)) + \
        lhs_design * slope_vec
    return param_samples


# Lotka Volterra from Boys. et al (2008)
# X1 --> 2*X1 ; k1
# X1 + X2 --> 2*X2 ; k2
# X2 --> (null) ; k3

# Specify the Lotka Volterra system as a graph
nstates = 2
nparam = 3
x = ca.MX.sym('x', nstates, 1)
k = ca.MX.sym('k', nparam, 1)
xdot = ca.vertcat([k[0] * x[0] - k[1] * x[0] * x[1],
                   k[1] * x[0] * x[1] - k[2] * x[1]])
meas = x
system = cp.system.System(x=x, p=k, f=xdot, phi=meas)

# Time points at which to simulate the Lotka Volterra system
t = np.linspace(0, 50, 51)
x0 = [71, 79]

# Find which parameter values cause the CVODES to fail. casiopeia uses CVODES.
# See https://github.com/adbuerger/casiopeia/blob/master/casiopeia/sim.py#L128
lower = 1e-6
upper = 5
bounds = pd.DataFrame({'param': ['k{}'.format(i) for i in xrange(1, 4)],
                       'lower': lower * np.ones(nparam),
                       'upper': upper * np.ones(nparam)})


# We will use Latin Hypercube design to generate parameter sets at which
# we will test the system simulation.
nsamples = 10000
param_samples = get_lhs_samples(bounds, nsamples)
samples = {}
bar = Bar('Simulating System', max=param_samples.shape[0])
for param in param_samples:
    samples[tuple(param)] = run_system(system, param, x0, t)
    bar.next()
bar.finish()

filename = 'samples_lower{}_upper{}_nsamples{}.pkl'.format(
    lower, upper, nsamples)
with open(filename, 'wb') as f:
    pickle.dump(samples, f)

# Analysis
param_success_samples = [key for key, value in samples.items()
                         if value['code'] == 0]
param_success_samples = pd.DataFrame.from_records(
    param_success_samples, columns=['k1', 'k2', 'k3'])
filename = 'success_params_lower{}_upper{}.csv'.format(lower, upper)
param_success_samples.to_csv(filename, index=False)

param_failure_samples = [key for key, value in samples.items()
                         if value['code'] != 0]
param_failure_samples = pd.DataFrame.from_records(
    param_failure_samples, columns=['k1', 'k2', 'k3'])
filename = 'failure_params_lower{}_upper{}.csv'.format(lower, upper)
param_failure_samples.to_csv(filename, index=False)

ratio_success_samples = pd.DataFrame(
    {'k1/k3': param_success_samples['k1'] / param_success_samples['k3'],
     'k2/k3': param_success_samples['k2'] / param_success_samples['k3'],
     'k1/k2': param_success_samples['k1'] / param_success_samples['k2']})
ratio_failure_samples = pd.DataFrame(
    {'k1/k3': param_failure_samples['k1'] / param_failure_samples['k3'],
     'k2/k3': param_failure_samples['k2'] / param_failure_samples['k3'],
     'k1/k2': param_failure_samples['k1'] / param_failure_samples['k2']})

# Make a 3d plot of parameter values
fig = plt.figure(1)
plt.clf()
ax = fig.add_subplot(111, projection='3d')
ax.scatter(param_success_samples['k1'], param_success_samples['k2'],
           param_success_samples['k3'], c='blue', alpha=0.5, label='Success')
ax.scatter(param_failure_samples['k1'], param_failure_samples['k2'],
           param_failure_samples['k3'], c='red', alpha=0.5, label='Failure')
ax.set_xlabel('k1')
ax.set_ylabel('k2')
ax.set_zlabel('k3')
plt.legend()
plt.show(block=False)
plt.savefig('param-scatter-3d.png')

# Make histogram of individual of parameter values
plt.figure(2)
plt.clf()
for i in xrange(nparam):
    plt.subplot(1, 3, i + 1)
    plt.hist(param_success_samples['k{}'.format(i + 1)],
             bins=int(np.sqrt(param_success_samples.shape[0])),
             color='blue', alpha=0.25, label='Success')
    plt.hist(param_failure_samples['k{}'.format(i + 1)],
             bins=int(np.sqrt(param_failure_samples.shape[0])),
             color='red', alpha=0.25, label='Failure')
    plt.xlabel('k{}'.format(i + 1))
    plt.ylabel('Density')
    plt.legend()
    plt.show(block=False)
plt.savefig('param-hist-individual.png')

# Make histogram of ratios of parameter values
plt.figure(3)
plt.clf()
for i in xrange(3):
    plt.subplot(1, 3, i + 1)
    plt.hist(np.log10(ratio_success_samples.iloc[:, i]),
             bins=int(np.sqrt(ratio_success_samples.shape[0])),
             color='blue', alpha=0.25, label='Success')
    plt.hist(np.log10(ratio_failure_samples.iloc[:, i]),
             bins=int(np.sqrt(ratio_failure_samples.shape[0])),
             color='red', alpha=0.25, label='Failure')
    plt.xlabel('log10({})'.format(ratio_success_samples.columns[i]))
    plt.ylabel('Counts')
    plt.legend()
    plt.show(block=False)
plt.savefig('param-ratio-hist-individual.png')

# Make a 3d histogram of ratios
plt.figure(4)
plt.clf()
sns.kdeplot(np.log10(ratio_success_samples['k1/k3']),
            np.log10(ratio_success_samples['k2/k3']),
            cmap='Blues', alpha=0.3, shade=True, shade_lowest=False,
            label='Success')
sns.kdeplot(np.log10(ratio_failure_samples['k1/k3']),
            np.log10(ratio_failure_samples['k2/k3']),
            cmap='Reds', alpha=0.3, shade=True, shade_lowest=False,
            label='Failure')
plt.grid('on')
plt.legend()
plt.show(block=False)
plt.savefig('param-ratio-kde-2d.png')

