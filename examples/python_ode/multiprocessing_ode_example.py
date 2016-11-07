# From this stackoverflow post:
# https://stackoverflow.com/questions/34291639/multiple-scipy-integrate-ode-instances

from __future__ import division, print_function

import sys
import time
import multiprocessing as mp
import numpy as np
from scipy.integrate import odeint


def lorenz(q, t, sigma, rho, beta):
    x, y, z = q
    return [sigma * (y - x), x * (rho - z) - y, x * y - beta * z]


def solve(ic):
    t = np.linspace(0, 200, 801)
    sigma = 10.0
    rho = 28.0
    beta = 8 / 3
    sol = odeint(lorenz, ic, t, args=(sigma, rho, beta),
                 rtol=1e-10, atol=1e-12)
    return sol


if __name__ == "__main__":
    ics = np.random.randn(100, 3)

    print("multiprocessing:", end='')
    tstart = time.time()
    num_processes = 5
    p = mp.Pool(num_processes)
    mp_solutions = p.map(solve, ics)
    tend = time.time()
    tmp = tend - tstart
    print(" %8.3f seconds" % tmp)

    print("serial:         ", end='')
    sys.stdout.flush()
    tstart = time.time()
    serial_solutions = [solve(ic) for ic in ics]
    tend = time.time()
    tserial = tend - tstart
    print(" %8.3f seconds" % tserial)

    print("num_processes = %i, speedup = %.2f" % (num_processes, tserial / tmp))

    check = [(sol1 == sol2).all()
             for sol1, sol2 in zip(serial_solutions, mp_solutions)]
    if not all(check):
        print("There was at least one discrepancy in the solutions.")
