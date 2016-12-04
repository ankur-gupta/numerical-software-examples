# This is a basic example to test if casadi is installed correctly.

import os
import sys
from platform import uname
# You should update your PYTHONPATH to add the location of CasADi
# installation. If not, you can execute this command below.
# location = "~/toolbox/{}/casadi/python".format(uname()[0])
# sys.path.append(os.path.expanduser(location))
from casadi import *

x = MX.sym("x")
print jacobian(sin(x), x)
