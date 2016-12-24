close all; clear all; clc; more off; format short g

% Function handle. Specify only once.
detfun = @LotkaVolterra_det;

% Get nominal data
[x0, theta0] = detfun([], [], [], 5);

% Test basics
[ns, nr, np] = detfun([], [], [], 6);
stoi = detfun([], [], [], 7);



function [dxdt, flag, new_data] = rhsfn(t, x, data)
  dxdt = data.detfun(t, x, data.param, data.mode);
  flag = 0;
  new_data = [];
endfunction

function [x, status, msg] = solve_using_cvode(param, t, x0, detfun)
  data.param = param;
  data.mode = 1;
  data.detfun = detfun;
  t0 = t(1);
  t(1) = [];
  options = CVodeSetOptions('UserData', data, ...
                            'RelTol', 1.e-3, ...
                            'AbsTol', 1.e-4, ...
                            'LinearSolver', 'Dense');
  CVodeInit(@rhsfn, 'BDF', 'Newton', t0, x0, options);
  try
    [status, tout, x] = CVode(t, 'Normal');
  catch err
    err.identifier
    err.message
    status = -1
    tout = []
    x = []
  end_try_catch
  CVodeFree

  x = [x0(:) x];
  if status == 0;
    msg = 'successful CVode return';
  elseif status == -1;
    msg = ' an error occurred (see printed message)';
  else
    msg = 'something happened';
  end
endfunction

% Test out the functions.
t = 0:1:100;
[x, status, msg] = solve_using_cvode(theta0, t, x0, detfun);
status
msg


% Get parameter grid
vec = 0.1:0.1:3.0;
[k1mat, k2mat, k3mat] = meshgrid(vec, vec, vec);
success = logical(k1mat);
for i=1:numel(k1mat)
    i
    theta = [k1mat(i) k2mat(i) k3mat(i)];
    [x, status, msg] = solve_using_cvode(theta, t, x0, detfun);
    success(i) = status == 0;
end

figure(1)
clf()
plot3(k1mat(success), k2mat(success), k3mat(success), 'bo')
hold on
grid on
plot3(k1mat(~success), k2mat(~success), k3mat(~success), 'ro')
xlabel('k1')
ylabel('k2')
zlabel('k3')

disp('Failure Parameters:')
[k1mat(~success) k2mat(~success) k3mat(~success)]






% % % Read the csv file containing failure parameters
% failure_params = csvread('../../casiopeia/failure_params_lower1e-06_upper5.csv');
% failure_params(1, :)= [];    % Remove the header
% failure_params = failure_params(randperm(rows(failure_params))(1:20), :)
% success_params = csvread('../../casiopeia/success_params_lower1e-06_upper5.csv');
% success_params(1, :)= [];    % Remove the header
% success_params = success_params(randperm(rows(success_params))(1:20), :)

% % Time points for simulation
% t = 0:1:100;
% [x, status, msg] = solve_using_cvode(theta0, t, x0, detfun);
% status
% msg

% success_logical_for_failure_params = zeros(rows(failure_params), 1);
% for i = 1:rows(failure_params)
%     disp(i)
%     % odefun = @(x,t) detfun(t, x, failure_params(i, :), 1);
%     % [x, istate, msg] = lsode(odefun, x0, t);
%     % success_logical_for_failure_params(i, 1) = istate == 2;
%     [x, status, msg] = solve_using_cvode(failure_params(i, :), t, x0, detfun);
%     success_logical_for_failure_params(i, 1) = status == 0;
% end

% success_logical_for_success_params = zeros(rows(success_params), 1);
% for i = 1:rows(success_params)
%     disp(i)
%     % odefun = @(x, t) detfun(t, x, success_params(i, :), 1);
%     % [x, istate, msg] = lsode(odefun, x0, t);
%     % success_logical_for_success_params(i, 1) = istate == 2;
%     [x, status, msg] = solve_using_cvode(success_params(i, :), t, x0, detfun);
%     success_logical_for_success_params(i, 1) = status == 0;
% end


% [success_logical_for_failure_params success_logical_for_success_params]









