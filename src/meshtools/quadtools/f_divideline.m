function line = f_divideline(varargin)

%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'ps','pe','nbi','dtype','flog'};

% --- default input value
ps  = []; % start point
pe  = []; % end point
len = [];  % length of the line
nbi = 0;  % number of intervals
dtype = 'lin'; % division type
flog = 1.3; % log factor

% --- check and update input
if mod(nargin,2) ~= 0
    error([mfilename ': number of arguments should be even !']);
end
for i = 1:nargin/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
dim = length(ps);
if dim ~= length(pe); error([mfilename ': ps pe dimension error !']); end;
%--------------------------------------------------------------------------
if nbi == 1; dtype = 'lin'; end
%--------------------------------------------------------------------------
% len = 0;
% for i = 1:dim
%     len = len + (ps(i) - pe(i))^2;
% end
% len = sqrt(len);
%--------------------------------------------------------------------------
% if strcmpi(dtype,'log+-') || strcmpi(dtype,'log=') || strcmpi(dtype,'log-+') 
%     line = zeros(dim,2*nbi+1);
% else
%     line = zeros(dim,nbi+1);
% end
%--------------------------------------------------------------------------
for i = 1:dim
    d = [];
    len = pe(i) - ps(i);
    if strcmpi(dtype,'lin')
        ratio = nbi;
        d = len/ratio .* ones(1,ratio);
    end
    if strcmpi(dtype,'log+') % || |  |   |
        ratio = logspace(0,flog,nbi)./sum(logspace(0,flog,nbi));
        d = len .* ratio;
    end
    if strcmpi(dtype,'log-') % |   |  | ||
        ratio = logspace(0,flog,nbi)./sum(logspace(0,flog,nbi));
        d = len .* ratio;
        d = d(end:-1:1);
    end
    if strcmpi(dtype,'log+-') || strcmpi(dtype,'log=') % || |  |   |   |  | ||
        nbi1 = (nbi - mod(nbi,2))/2;
        nbi2 = nbi - nbi1;
        ratio1 = logspace(0,flog,nbi1)./sum(logspace(0,flog,nbi1));
        d1 = len * nbi1/nbi .* ratio1;
        ratio2 = logspace(0,flog,nbi2)./sum(logspace(0,flog,nbi2));
        d2 = len * nbi2/nbi .* ratio2;
        d = [d1, d2(end:-1:1)];
    end
    if strcmpi(dtype,'log-+') % |   |  | || |  |   |
        %ratio = logspace(0,flog,nbi)./sum(logspace(0,flog,nbi));
        %d = len/2 .* ratio;
        %d = [d(end:-1:1) d];
        nbi1 = (nbi - mod(nbi,2))/2;
        nbi2 = nbi - nbi1;
        ratio1 = logspace(0,flog,nbi1)./sum(logspace(0,flog,nbi1));
        d1 = len * nbi1/nbi .* ratio1;
        ratio2 = logspace(0,flog,nbi2)./sum(logspace(0,flog,nbi2));
        d2 = len * nbi2/nbi .* ratio2;
        d = [d1(end:-1:1), d2];
    end
    d = [0 cumsum(d)];
    line(i,:) = ps(i) + d;
    line(i,1) = ps(i);
    line(i,end) = pe(i);
end





