# casadi v3.2.0 onwards some compatibility problems with casiopeia were
# fixed.
import casadi as ca

# Casiopeia used to require Casadi v2.4.3, which required PYTHONPATH
# to be modified. Modifying PYTHONPATH caused other problems because no
# PYTHONPATH variable was even set if not for casiopeia/casadi v2.4.3 issue.
# With casiopeia v0.2.0 and casadi v3.2.0, we no longer need to use older
# versions and no PYTHONPATH modifications or even setup is needed.
import casiopeia as cp
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Lotka Volterra from Boys. et al (2008)
# X1 --> 2*X1 ; k1
# X1 + X2 --> 2*X2 ; k2
# X2 --> (null) ; k3

# Specify the Lotka Volterra system as a graph
x = ca.MX.sym('x', 2, 1)
k = ca.MX.sym('k', 3, 1)
xdot = ca.vertcat(k[0] * x[0] - k[1] * x[0] * x[1],
                  k[1] * x[0] * x[1] - k[2] * x[1])
meas = x
system = cp.system.System(x=x, p=k, f=xdot, phi=meas)

# Simulate the Lotka Volterra System to create dummy data
t = np.linspace(0, 100, 101)
# k_actual = [5, 4, 3]  # This causes ODE solver to fail.
# k_actual = [10, 1, 1]
k_actual = [0.5, 0.0025, 0.3]
x0 = [71, 79]
sim = cp.sim.Simulation(system, k_actual)
sim.run_system_simulation(time_points=t, x0=x0)
ymeas = sim.simulation_results.full()

# Attempt to estimate parameters from the simulated data
# We use "multiple_shooting" as the discretization method because
# "collocation" does not return the correct parameter estimates.
# Multiple shooting performs better in prediction.
# FIXME: This used to work but now it fails!
pe = cp.pe.LSq(system=system, time_points=t, xinit=ymeas, ydata=ymeas,
               pinit=k_actual, discretization_method='multiple_shooting')
pe.run_parameter_estimation()
pe.print_estimation_results()
k_est = np.reshape(pe.estimated_parameters.full(), (3, ))

pe.compute_covariance_matrix()
print 'Covariance matrix: \n', pe.covariance_matrix.full()

# Simulate at estimated parameters
est = cp.sim.Simulation(system, pe.estimated_parameters)
est.run_system_simulation(time_points=t, x0=x0)
yest = est.simulation_results.full()

# Print results
results = pd.DataFrame({'actual': k_actual, 'estimated': k_est})
results['parameter'] = ['k{}'.format(i) for i in xrange(1, 4)]
results = results[['parameter', 'actual', 'estimated']]
print results

# Plot results
plt.figure(1)
plt.clf()
plt.plot(t, ymeas[0, :], 'go', label='Y1')
plt.plot(t, ymeas[1, :], 'bo', label='Y2')
plt.plot(t, yest[0, :], 'g-')
plt.plot(t, yest[1, :], 'b-')
plt.grid('on')
plt.legend()
plt.xlabel('time')
plt.ylabel('species count')
plt.show(block=False)

# Sample results
#   parameter  actual  estimated
# 0        k1      10       10.0
# 1        k2       1        1.0
# 2        k3       1        1.0
