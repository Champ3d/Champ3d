function rho = f__rho(T)

% --- measurement data
Ti = linspace(0,1000,2);
ri = linspace(1,1,length(Ti));
% ---
rho = interp1(Ti,ri,T);