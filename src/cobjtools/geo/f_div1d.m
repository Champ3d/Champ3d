function divline = f_div1d(line1d,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {''};

% --- default input value

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
d     = line1d.d;
dnum  = line1d.dnum;
dtype = line1d.dtype;
flog  = line1d.flog;
%--------------------------------------------------------------------------
if strcmpi(dtype,'lin')
    ratio = dnum;
    divline = d/ratio .* ones(1,ratio);
end
if strcmpi(dtype,'log+') % || |  |   |
    ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
    divline = d .* ratio;
end
if strcmpi(dtype,'log-') % |   |  | ||
    ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
    divline = d .* ratio;
    divline = divline(end:-1:1);
end
if strcmpi(dtype,'log+-') || strcmpi(dtype,'log=') % || |  |   |   |  | ||
    dnum  = dnum * 2;
    ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
    divline = d/2 .* ratio;
    divline = [divline, divline(end:-1:1)];
end
if strcmpi(dtype,'log-+') % |   |  | || |  |   |
    dnum  = dnum * 2;
    ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
    divline = d/2 .* ratio;
    divline = [divline(end:-1:1), divline];
end