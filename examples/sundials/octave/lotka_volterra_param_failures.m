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


% Create a tabular format to save
result = [k1mat(:) k2mat(:) k3mat(:) success(:)]
save result.dat result
csvwrite('result.csv', result)

% Make a 3d plot showing failure parameters in red circles.
k1mat = result(:, 1);
k2mat = result(:, 2);
k3mat = result(:, 3);
success = result(:, 4);
figure(1)
clf()
plot3(k1mat(find(success)), k2mat(find(success)), k3mat(find(success)), 'b.')
hold on
grid on
plot3(k1mat(find(!success)), k2mat(find(!success)), k3mat(find(!success)), 'ro')
xlabel('k1')
ylabel('k2')
zlabel('k3')




