classdef cpnode < dlnode
%--------------------------------------------------------------------------
% cpnode — Construct a computation node with properties :
%    + type = 'cpnode'
%    + name
%    +
%    +
% insertAfter — Insert this node after the specified node
% insertBefore — Insert this node before the specified node
%--------------------------------------------------------------------------
   properties
      type = 'cpnode';
   end
   methods
      function n = cpnode(varargin)
         if nargin == 0
            name = '';
         end
         n = n@dlnode(name);
         n.name = name;
      end
   end
end