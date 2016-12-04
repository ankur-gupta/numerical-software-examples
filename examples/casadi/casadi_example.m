% This is a basic example to test if casadi is installed correctly.

% You need to add path. This could be in your ~/.octaverc file.
% If not, you can execute this command here.
% addpath(genpath(['~/toolbox/' uname.sysname '/casadi/octave']));
import casadi.*
x = MX.sym('x')
disp(jacobian(sin(x),x))