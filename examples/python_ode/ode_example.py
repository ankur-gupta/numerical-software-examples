from scipy.integrate import ode
import matplotlib.pyplot as plt
import numpy as np


def dydt(t, y, nd, theta):
    return [y[0] * nd, -y[0] * y[1] * sum(theta)]


# def jac(t, y, nd, theta):
#     return [[1j*arg1, 1], [0, -arg1*2*y[1]]]


# Initial condition
t0 = 0
y0 = [1, 2]

# Setup ODE instance
r = ode(f=dydt).set_integrator('lsoda', method='bdf')
r.set_initial_value(y0, t0).set_f_params(1, [1, 2])

# Manually solve ODE step-by-step
t1 = 10
dt = 0.1
t = []
y = []
t.append(t0)
y.append(np.array(y0))
while r.successful() and r.t < t1:
    r.integrate(r.t + dt)
    t.append(r.t)
    y.append(r.y)
    print 't = ', r.t, ", y = ", r.y

t = np.array(t)
y = np.array(y)

plt.figure('1')
plt.clf()
plt.plot(t, y[:, 0], 'r')
plt.plot(t, y[:, 1], 'b')
plt.xlabel('t')
plt.ylabel('y')
plt.grid('on')
