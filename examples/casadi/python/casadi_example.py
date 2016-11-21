# This is a basic example to test if casadi is installed correctly.

import os
import sys
sys.path.append(os.path.expanduser("~/toolbox/casadi/python"))
from casadi import *

x = MX.sym("x")
print jacobian(sin(x), x)
