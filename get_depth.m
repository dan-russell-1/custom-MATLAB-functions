function depth = get_depth(fbus, tbus, n_nodes)
    
    head = 1;

    % build adjacency (sparse, efficient)
    A = sparse([fbus(:); tbus(:)], [tbus(:); fbus(:)], 1, n_nodes, n_nodes);

    % initialize
    depth = -1 * ones(n_nodes,1);
    depth(head) = 0;

    % BFS queue
    q = head;
    while ~isempty(q)
        node = q(1);
        q(1) = [];
        neighbors = find(A(node,:));
        for nb = neighbors
            if depth(nb) == -1
                depth(nb) = depth(node) + 1;
                q(end+1) = nb; %#ok<AGROW>
            end
        end
    end
end