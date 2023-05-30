function draw2d = f_femm_draw_straightrect(draw2d,varargin)

%--------------------------------------------------------------------------
% 'c_angle' : angle of the center (degree)
% 'c_r' : radius of the center
% 'r_size' : interior radius
% 'theta_size' : exterior radius
% 'c_xy' : xy-coordinates of the center
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_draw2d','c_angle','c_r','r_len','theta_len','center','ocenter'};

% --- default input value
r_len      = [];
theta_len  = [];
center     = [];
c_r        = [];
c_angle    = 0;
id_draw2d  = [];
ocenter    = [0 0];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
% -------------------------------------------------------------------------
lendr = length(draw2d);
lendr = lendr + 1;
if isempty(id_draw2d)
    id_draw2d = ['XXDraw2dNo' num2str(lendr)];
end
% -------------------------------------------------------------------------
if ~isempty(c_r) && ~isempty(c_angle)
    center(1) = c_r * cosd(c_angle);
    center(2) = c_r * sind(c_angle);
end
% ---
rsizevec = r_len/2 .* [cosd(c_angle) sind(c_angle)];
tsizevec = theta_len/2 .* [cosd(c_angle+90) sind(c_angle+90)];
diagvec1 = +rsizevec + tsizevec;
diagvec2 = -rsizevec + tsizevec;
% ---
d1 = center - diagvec1 + ocenter;
d2 = center - diagvec2 + ocenter;
d3 = center + diagvec1 + ocenter;
d4 = center + diagvec2 + ocenter;
% ---
mi_drawline(d1(1),d1(2),d2(1),d2(2));
mi_drawline(d2(1),d2(2),d3(1),d3(2));
mi_drawline(d3(1),d3(2),d4(1),d4(2));
mi_drawline(d4(1),d4(2),d1(1),d1(2));
% -------------------------------------------------------------------------
s_factor = 1 - 1e-3;
bottomright = center - diagvec1*s_factor + ocenter;
upperright  = center - diagvec2*s_factor + ocenter;
bottomleft  = center + diagvec1*s_factor + ocenter;
upperleft   = center + diagvec2*s_factor + ocenter;
% -------------------------------------------------------------------------
draw2d(lendr).id_draw2d = id_draw2d;
draw2d(lendr).type = 'straight_rectangle';
draw2d(lendr).c_angle = c_angle;
draw2d(lendr).c_r = c_r;
draw2d(lendr).ocenter = ocenter;
draw2d(lendr).center = center;
draw2d(lendr).r_len = r_len;
draw2d(lendr).theta_len = theta_len;
draw2d(lendr).c_vector = [cosd(c_angle) sind(c_angle)];
draw2d(lendr).bottomright = bottomright;
draw2d(lendr).bottomleft  = bottomleft;
draw2d(lendr).upperright  = upperright;
draw2d(lendr).upperleft   = upperleft;
% -------------------------------------------------------------------------


