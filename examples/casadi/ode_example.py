import numpy as np
import casadi as ca
import matplotlib.pyplot as plt

# Simple Reaction System
# A -> B; k1
# B -> C; k2

# Symbolic rate constants
k = ca.MX.sym('k', 2, 1)

# States
x = ca.MX.sym('x', 3, 1)

# RHS of the ODE
# Works for version casadi v3.1.1. Check ca.__version__.
# For casadi v2.4.3, put all args within a list.
xdot = ca.vertcat(-k[0] * x[0], k[0] * x[0] - k[1] * x[1], k[1] * x[1])

# ODE dict
ode = {'x': x, 'p': k, 'ode': xdot}

# ODE options
opts = {}
opts['abstol'] = 1e-6
opts['reltol'] = 1e-6
opts['grid'] = np.linspace(0, 10, num=1001)
# opts['t0'] = 0
# opts['tf'] = 100
# opts['output_t0'] = True

# Integrator object
f = ca.integrator('F', 'cvodes', ode, opts)
# f = ca.integrator('F', 'collocation', ode, opts)
x0 = [1, 0, 0]
sol = f(x0=x0, p=[1, 0])
xout = sol['xf'].full()
xout = np.hstack((np.reshape(x0, (3, 1)), xout)).T

plt.figure(1)
plt.clf()
plt.plot(opts['grid'], xout[:, 0], 'bo-')
plt.plot(opts['grid'], xout[:, 1], 'go-')
plt.plot(opts['grid'], xout[:, 2], 'ro-')
plt.grid('on')
plt.show(block=False)
