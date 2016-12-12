# Requires casadi v3 or higher
from casadi import *

S = 10
L = 1
g = 9.81
m = 1

P = MX.sym('P', 2, 1)
A = MX.zeros(2, 1)
d = norm_2(P - A)
V = 0.5 * S * (d - L) ** 2 + m * g * P[1]

nlp = {'x': P, 'f': V}
solver = nlpsol('solver', 'ipopt', nlp)
sol = solver(x0=[2, -1])

# Functions
E = Function('E', [P], [V])
e = E([-1, 2])
print(e)

