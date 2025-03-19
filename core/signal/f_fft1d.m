%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function spec = f_fft1d(args)

arguments
    args.t {mustBeNumeric}
    args.signal {mustBeNumeric}
    args.T {mustBeNumeric}
    args.Fs {mustBeNumeric}
    args.tolerance {mustBeNumeric} = 1e-9
end

% ---
sfac_t_len = 5;
tol = args.tolerance; % tolerance when compute phase
%--------------------------------------------------------------------------
spec.t = [];
spec.signal = [];
spec.fr = [];
spec.harmonic_order = [];
spec.amplitude = [];
spec.phase = [];
%--------------------------------------------------------------------------
with_t_given = 0;
with_Fs_given = 0;
with_T_given = 0;
%--------------------------------------------------------------------------
if isfield(args,'t')
    if ~isempty(args.t)
        t_ = args.t;
        with_t_given = 1;
    end
end
if isfield(args,'signal')
    if isempty(args.signal)
        return
    else
        s_ = args.signal;
    end
else
    return
end
if isfield(args,'Fs')
    if ~isempty(args.Fs)
        Fs = args.Fs;
        with_Fs_given = 1;
    end
end
% ---
T = [];
if isfield(args,'T')
    if ~isempty(args.T)
        T = args.T;
        with_T_given = 1;
    end
end
%--------------------------------------------------------------------------
if with_t_given
    % --- check size
    if numel(s_) ~= numel(t_)
        error('size of signal and time must be equal');
    end
elseif with_Fs_given
    len = length(s_);
    t_  = 1/Fs .* (0:len-1);
end
% --- interpolation
len = sfac_t_len*length(t_);
len = 2^nextpow2(len);
tmin = min(t_);
% ---
if with_T_given
    tmax = tmin + T;
else
    tmax = max(t_);
end
% ---
t = linspace(tmin,tmax,len);
s = interp1(t_,s_,t,'linear','extrap');
% ---
Ts = t(2) - t(1);
Fs = 1/Ts;
%--------------------------------------------------------------------------
N = len;
% --- FFT
Y = fft(s,N);
% --- single-side spectre
if (mod(N,2) == 0)
    NX = N/2;
else
    NX = (N-1)/2;
end
% ---
X  = zeros(1,NX);
% ---
X(1) = 1/N .* Y(1);       % X(1) is at fr = 0
X(2:NX) = 2/N .* Y(2:NX); % 1/N and 2/N are scale factor
% ---
order = (0:NX-1);
fr = Fs/(N-1) .* order;
amplitude = abs(X);
% ---
phase = zeros(1,NX); % unwrap ?
re = real(X);
im = imag(X);
% ---
re(abs(re) < tol) = 0;
im(abs(im) < tol) = 0;
% ---
ire0 = find(re == 0);
ip90 = ire0(im(ire0) > 0); % phase = +90
in90 = ire0(im(ire0) < 0); % phase = -90
i0   = setdiff(ire0,[ip90,in90]); % phase = 0
ipcn = setdiff(1:NX,ire0); % phase computed normally
% ---
phase(ip90) =  90;
phase(in90) = -90;
phase(i0)   =   0;
phase(ipcn) = angle(re(ipcn) + 1j*im(ipcn)) .* (180/pi);
phase(1) = 0; % DC component
% ---
if with_T_given
    harmonic_order = order;
else
    harmonic_order = [];
end
%--------------------------------------------------------------------------
spec.t = t;
spec.signal = s;
spec.fr = fr;
spec.harmonic_order = harmonic_order;
spec.amplitude = amplitude;
spec.phase = phase;

end