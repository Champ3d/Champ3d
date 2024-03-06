%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function node = f_divline(end_point_1,end_point_2,args)
arguments
    end_point_1
    end_point_2
    args.dnum = 1
    args.dtype {mustBeMember(args.dtype,{'lin','log+','log-','log+-','log-+','log='})} = 'lin'
    args.flog = 1.05
end
%--------------------------------------------------------------------------
p1    = end_point_1;
p2    = end_point_2;
dnum  = args.dnum;
dtype = args.dtype;
flog  = args.flog;
%--------------------------------------------------------------------------
with_x = 0;
with_y = 0;
with_z = 0;
switch length(p1)
    case 1
        with_x = 1;
    case 2
        with_x = 1;
        with_y = 1;
    case 3
        with_x = 1;
        with_y = 1;
        with_z = 1;
end
%--------------------------------------------------------------------------
if any(f_strcmpi(dtype,{'log+-','log-+','log='}))
    dnum = dnum * 2;
end
%--------------------------------------------------------------------------
if with_z
    node = zeros(3,dnum + 1);
elseif with_y
    node = zeros(2,dnum + 1);
elseif with_x
    node = zeros(1,dnum + 1);
end
%--------------------------------------------------------------------------
vec = p2 - p1;
len = norm(vec);
vec = f_normalize(f_tocolv(vec));
%--------------------------------------------------------------------------
if strcmpi(dtype,'lin')
    ratio = dnum;
    vlen = len/ratio .* ones(1,ratio);
end
if strcmpi(dtype,'log+') % || |  |   |
    ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
    vlen = len .* ratio;
end
if strcmpi(dtype,'log-') % |   |  | ||
    ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
    vlen = len .* ratio;
    vlen = vlen(end:-1:1);
end
if strcmpi(dtype,'log+-') || strcmpi(dtype,'log=') % || |  |   |   |  | ||
    ratio = logspace(0,flog,dnum/2)./sum(logspace(0,flog,dnum/2));
    vlen = len/2 .* ratio;
    vlen = [vlen, vlen(end:-1:1)];
end
if strcmpi(dtype,'log-+') % |   |  | || |  |   |
    ratio = logspace(0,flog,dnum/2)./sum(logspace(0,flog,dnum/2));
    vlen = len/2 .* ratio;
    vlen = [vlen(end:-1:1), vlen];
end
%--------------------------------------------------------------------------
vlen = [0 cumsum(vlen)];
%--------------------------------------------------------------------------
if with_x
    node(1,:) = p1(1) + vlen .* vec(1);
    % ---
    node(1,1)   = p1(1);
    node(1,end) = p2(1);
end
% ---
if with_y
    node(2,:) = p1(2) + vlen .* vec(2);
    % ---
    node(2,1)   = p1(2);
    node(2,end) = p2(2);
end
% ---
if with_z
    node(3,:) = p1(3) + vlen .* vec(3);
    % ---
    node(3,1)   = p1(3);
    node(3,end) = p2(3);
end
%--------------------------------------------------------------------------