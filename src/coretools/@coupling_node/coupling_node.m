classdef coupling_node < handle
   % coupling_node A class to represent a doubly-linked list node.
   % Link multiple coupling_node objects together to create linked lists.
   
properties
    what
end

properties(SetAccess = private)
    next = coupling_node.empty;
    prev = coupling_node.empty;
end

methods
    function node = coupling_node(what)
        % Construct a coupling_node object.
        if nargin > 0
            node.what = what;
        else
            node.what = '';
        end
    end

    function insertAfter(newNode, nodeBefore)
        % Insert newNode after nodeBefore.
        removeNode(newNode);
        newNode.next = nodeBefore.next;
        newNode.prev = nodeBefore;
        if ~isempty(nodeBefore.next)
            nodeBefore.next.prev = newNode;
        end
        nodeBefore.next = newNode;
    end

    function insertBefore(newNode, nodeAfter)
        % Insert newNode before nodeAfter.
        removeNode(newNode);
        newNode.next = nodeAfter;
        newNode.prev = nodeAfter.prev;
        if ~isempty(nodeAfter.prev)
            nodeAfter.prev.next = newNode;
        end
        nodeAfter.prev = newNode;
    end

    function removeNode(node)
        % Remove a node from a linked list.
        if ~isscalar(node)
            error('Input must be scalar')
        end
        prevNode = node.prev;
        nextNode = node.next;
        if ~isempty(prevNode)
            prevNode.next = nextNode;
        end
        if ~isempty(nextNode)
            nextNode.prev = prevNode;
        end
        node.next = coupling_node.empty;
        node.prev = coupling_node.empty;
    end

    function clearList(node)
        % Clear the list before
        % clearing list variable
        prev = node.prev;
        next = node.next;
        removeNode(node)
        while ~isempty(next)
            node = next;
            next = node.next;
            removeNode(node);
        end
        while ~isempty(prev)
            node = prev;
            prev = node.prev;
            removeNode(node)
        end
    end
  
end % methods


methods (Access = private)
    function delete(node)
        % Delete all nodes
        clearList(node)
    end
end % private methods


end % classdef









