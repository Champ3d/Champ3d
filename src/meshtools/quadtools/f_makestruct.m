function s = f_makestruct(varargin)
% --- valid argument list (to be updated each time modifying function)
% none
% --- default input value
% none


if mod(nargin,2) ~= 0
    error([mfilename ': number of arguments should be even !']);
end

for i = 1:(nargin/2)
    s.(varargin{2*i-1}) = varargin{2*i};
end

if ~isfield(s,'lt')
    s.lt = 'regular';
end



