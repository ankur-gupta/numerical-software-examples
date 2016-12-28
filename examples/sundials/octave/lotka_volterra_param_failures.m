close all; clear all; clc; more off; format short g

% Function handle. Specify only once.
detfun = @LotkaVolterra_det;

% Get nominal data
[x0, theta0] = detfun([], [], [], 5);

% Test basics
[ns, nr, np] = detfun([], [], [], 6);
stoi = detfun([], [], [], 7);

% Set lsode options
lsode_options('absolute tolerance', 1e-4);
lsode_options('relative tolerance', 1e-3);


%-----------------------------------------------------------------------------------
% Helper functions
%-----------------------------------------------------------------------------------
function [dxdt, flag, new_data] = rhsfn(t, x, data)
  dxdt = data.detfun(t, x, data.param, 1);
  flag = 0;
  new_data = [];
endfunction

function [jac, flag, new_data] = djacfn(t, y, fy, data)
    % t = time (scalar)
    % y = state (vector)
    % fy = ode rhs (vector)
    % data = user supplied data (struct)

    % Jacobian
    jac = data.detfun(t, y, data.param, 3);
    flag = 0;
    new_data = [];
endfunction


function [dsdt, flag, new_data] = rhsSfn(t, y, yd, yS, data)
    % t = time (scalar)
    % y = state (vector)
    % yd = oderhs (vector)
    % yS = stacked sensitivities (vector)
    % data = user supplied data (struct)
    yaug = [y(:); yS(:)];
    dsdt = data.detfun(t, yaug, data.param, 2);
    dsdt(1:length(y)) = [];
    dsdt = reshape(dsdt, data.nstates, data.nparam);
    flag = 0;
    new_data = [];
endfunction



function [lsode_x, lsode_istate, lsode_msg] = solve_using_lsode(param, t, x0, detfun)
        [lsode_x, lsode_istate, lsode_msg] = lsode(@(x, t) detfun(t, x, param, 1), x0, t);
endfunction

function [cvode_x, cvode_status, cvode_msg] = solve_using_cvode(param, t, x0, detfun)
      data.param = param;
      data.detfun = detfun;
      [data.nstates, ~, data.nparam] = data.detfun([], [], [], 6);

      % Remove the initial time from the vector so CVode likes it.
      t0 = t(1);
      t(1) = [];
      s0 = zeros(data.nstates, data.nparam);
      options = CVodeSetOptions('UserData', data, ...
                                'RelTol', 1.e-3, ...
                                'AbsTol', 1.e-4, ...
                                'LinearSolver', 'Dense');
      CVodeInit(@rhsfn, 'BDF', 'Newton', t0, x0, options);

      try
        [cvode_status, tout, cvode_x] = CVode(t, 'Normal');
      catch err
        err.identifier
        err.message
        cvode_status = -1
        tout = []
        cvode_x = []
      end_try_catch
      CVodeFree

      cvode_x = [x0(:) cvode_x];
      if cvode_status == 0;
        cvode_msg = 'successful CVode return';
      elseif cvode_status == -1;
        cvode_msg = ' an error occurred (see printed message)';
      else
        cvode_msg = 'something happened';
      end
endfunction

function [cvode_x, cvode_s, cvode_status, cvode_msg] = solve_using_cvode_sens(param, t, x0, detfun)
      data.param = param;
      data.detfun = detfun;
      [data.nstates, ~, data.nparam] = data.detfun([], [], [], 6);

      % Remove the initial time from the vector so CVode likes it.
      t0 = t(1);
      t(1) = [];
      s0 = zeros(data.nstates, data.nparam);
      options = CVodeSetOptions('UserData', data, ...
                                'RelTol', 1.e-3, ...
                                'AbsTol', 1.e-4, ...
                                'LinearSolver', 'Dense');
      FSAoptions = CVodeSensSetOptions('method', 'Simultaneous');
      CVodeInit(@rhsfn, 'BDF', 'Newton', t0, x0, options);
      CVodeSensInit(data.nparam, @rhsSfn, s0, FSAoptions);

      try
        [cvode_status, tout, cvode_x, cvode_s] = CVode(t, 'Normal');
      catch err
        err.identifier
        err.message
        cvode_status = -1
        tout = []
        cvode_x = []
      end_try_catch
      CVodeFree

      cvode_x = [x0(:) cvode_x];
      if cvode_status == 0;
        cvode_msg = 'successful CVode return';
      elseif cvode_status == -1;
        cvode_msg = ' an error occurred (see printed message)';
      else
        cvode_msg = 'something happened';
      end
endfunction

%-----------------------------------------------------------------------------------
% Main
%-----------------------------------------------------------------------------------
% Test out the functions.
t = 0:1:100;
[lsode_x, lsode_istate, lsode_msg] = solve_using_lsode(theta0, t, x0, detfun);
[cvode_x, cvode_status, cvode_msg] = solve_using_cvode(theta0, t, x0, detfun);
[cvode_sens_x, cvode_sens_s, cvode_sens_status, cvode_sens_msg] = solve_using_cvode_sens(theta0, t, x0, detfun);

figure(1)
clf()
plot(t', lsode_x(:, 1), 'r-')
hold on
plot(t', lsode_x(:, 2), 'b-')
plot(t', cvode_x'(:, 1), 'ro')
plot(t', cvode_x'(:, 2), 'bo')
xlabel('time')
ylabel('concentration')
grid on

% Get parameter grid
vec = 0.1:0.1:3.0;
[k1mat, k2mat, k3mat] = meshgrid(vec, vec, vec);
lsode_success = logical(k1mat);
cvode_success = logical(k1mat);
cvode_sens_success = logical(k1mat);
for i=1:numel(k1mat)
    i
    param = [k1mat(i) k2mat(i) k3mat(i)];
    [lsode_x, lsode_istate, lsode_msg] = solve_using_lsode(param, t, x0, detfun);
    [cvode_x, cvode_status, cvode_msg] = solve_using_cvode(param, t, x0, detfun);
    [cvode_sens_x, cvode_sens_s, cvode_sens_status, cvode_sens_msg] = solve_using_cvode_sens(param, t, x0, detfun);
    lsode_success(i) = lsode_istate == 2;
    cvode_success(i) = cvode_status == 0;
    cvode_sens_success(i) = cvode_sens_status == 0;
end


% Create a tabular format to save
result = [k1mat(:) k2mat(:) k3mat(:) lsode_success(:) cvode_success(:) cvode_sens_success(:)]
save result.dat result
save -binary result.mat result

% Make a 3d plot showing failure parameters in red circles.
k1mat = result(:, 1);
k2mat = result(:, 2);
k3mat = result(:, 3);
lsode_success = result(:, 4);
cvode_success = result(:, 5);
cvode_sens_success = result(:, 6);

all_success = lsode_success & cvode_success & cvode_sens_success;
all_failure = ~lsode_success & ~cvode_success & ~cvode_sens_success;
cvode_failure = lsode_success & ~cvode_success;
sens_failure = cvode_success & ~cvode_sens_success;

figure(2)
clf()
plot3(k1mat(find(all_success)), k2mat(find(all_success)), ...
      k3mat(find(all_success)), 'b.')
hold on
plot3(k1mat(find(all_failure)), k2mat(find(all_failure)), ...
      k3mat(find(all_failure)), 'ko')
plot3(k1mat(find(cvode_failure)), k2mat(find(cvode_failure)), ...
      k3mat(find(cvode_failure)), 'g*')
plot3(k1mat(find(sens_failure)), k2mat(find(sens_failure)), ...
      k3mat(find(sens_failure)), 'r*')
grid on
xlabel('k1')
ylabel('k2')
zlabel('k3')
legend('All Success', 'All Failure', 'LSODE success, CVODE failure', ...
       'CVODE Success, Sens Failure')

