import stochpy
import matplotlib.pyplot as plt
import numpy as np

t = [None] * 3
x = [None] * 3

a = stochpy.SSA()
a.Model('vsvgfp_n_delay1.psc')
a.SetSeeding(False)
np.random.seed(10)
a.DoStochSim(end=40, mode='time')
a.PlotSpeciesTimeSeries()
t[0] = a.data_stochsim.time.copy()
x[0] = a.data_stochsim.species.copy()

a.DumpTrajectoryData(1)
np.random.seed(100)
a.DoStochSim(end=40, mode='time')
a.PlotSpeciesTimeSeries()
t[1] = a.data_stochsim.time.copy()
x[1] = a.data_stochsim.species.copy()

a.DumpTrajectoryData(1)
np.random.seed(10)
a.DoStochSim(end=40, mode='time')
a.PlotSpeciesTimeSeries()
t[2] = a.data_stochsim.time.copy()
x[2] = a.data_stochsim.species.copy()

np.all(t[0] == t[2])
np.all(x[0] == x[2])
np.all(t[0] == t[1])
np.all(x[0] == x[1])

b = stochpy.SSA()
b.Model('vsvgfp_n_delay1.psc')
b.ChangeParameter('kP', 100)
b.DoStochSim(end=40, mode='time', trajectories=10)
plt.figure(2)
b.PlotSpeciesTimeSeries(species2plot=['P'])
plt.grid('on')
plt.show(block=False)
