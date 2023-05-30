function draw2d = f_femm_draw_circle(draw2d,varargin)

%--------------------------------------------------------------------------
% 'ocenter' : coordinates of the center
% 'r' : radius
% 'max_anglen' : maximal angle of segment (default = 2 deg)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_draw2d','r','max_anglen','ocenter'};

% --- default input value
r = [];
max_anglen = [];
id_draw2d = [];
ocenter = [0 0];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
% -------------------------------------------------------------------------
if isempty(max_anglen)
    max_anglen = 2;
end
% -------------------------------------------------------------------------
lendr = length(draw2d);
lendr = lendr + 1;
if isempty(id_draw2d)
    id_draw2d = ['XXDraw2dNo' num2str(lendr)];
end
% -------------------------------------------------------------------------
x1 = r * cosd(0)   + ocenter(1);
x2 = r * cosd(180) + ocenter(1);
y1 = r * sind(0)   + ocenter(2);
y2 = r * sind(180) + ocenter(2);
mi_drawarc(x1,y1,x2,y2,180,max_anglen);
mi_drawarc(x2,y2,x1,y1,180,max_anglen);
% -------------------------------------------------------------------------
eps_r = r * (1 - 1/1e3);
bottom(1) = eps_r * cosd(-90) + ocenter(1);
bottom(2) = eps_r * sind(-90) + ocenter(2);
upper(1)  = eps_r * cosd(+90) + ocenter(1);
upper(2)  = eps_r * sind(+90) + ocenter(2);
left(1)   = eps_r * cosd(180) + ocenter(1);
left(2)   = eps_r * sind(180) + ocenter(2);
right(1)  = eps_r * cosd(0)   + ocenter(1);
right(2)  = eps_r * sind(0)   + ocenter(2);
center    = ocenter;
% -------------------------------------------------------------------------
draw2d(lendr).id_draw2d = id_draw2d;
draw2d(lendr).type = 'circle';
draw2d(lendr).r = r;
draw2d(lendr).ocenter = ocenter;
draw2d(lendr).center  = center;
draw2d(lendr).bottom  = bottom;
draw2d(lendr).upper   = upper;
draw2d(lendr).left    = left;
draw2d(lendr).right   = right;
draw2d(lendr).max_anglen = max_anglen;
% -------------------------------------------------------------------------




