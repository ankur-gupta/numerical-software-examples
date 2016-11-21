% This is a basic example to test if casadi is installed correctly.

addpath('~/toolbox/casadi/octave')
import casadi.*
x = MX.sym('x')
disp(jacobian(sin(x),x))