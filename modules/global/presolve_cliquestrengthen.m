function p = presolve_cliquestrengthen(p)

% Currently assumes purely binary
if any(p.cliques.table)
    % Start by computing conflict graph from cliques
    n_strengthened = 0;
    degrees = [];
    neighbours = cell(1,length(p.c));
    for i = 1:length(p.c)
        c = find(p.cliques.table(i,:));
        if any(c)
            S = p.cliques.table(:,c);
            S(i,:) = 0;
            s = any(S,2);
            n = nnz(s);
            degrees = [degrees n];
            neighbours{i} = find(s);
        else
            degrees = [degrees 0];
        end
    end
    
    % Now go through all clique constraints in original model
    % and try to extend based on the conflict graph
    % Code based on
    % Preprocessing and Cutting Planes with Conflict Graphs
    % Samuel Souza Britoa Haroldo Gambini Santosa
    % Very brute force now
    top = p.K.f;
    for i = find(p.rowtype == 3)%isclique)        
        row = p.F_struc(top+i,2:end);
        C =  find(row);
        C_ = C;       
        [~,idx] = min(degrees(C));
        d = C(idx(1));
        L = setdiff(neighbours{d},C);
        while ~isempty(L)
            [~,idx] = max(L);
            l = L(idx);
            L = setdiff(L,l);
            ok = 1;
            for k = C_
                if ~ismember(l,neighbours{k})                	
                    ok = 0;
                    break
                end
            end
            if ok
                C_ = union(C_,l);
            end
        end
        % Update clique if it was extended
        if nnz(C_)>nnz(C)
            n_strengthened = n_strengthened + 1;
            p.F_struc(top+i,1+C_) = -1;
        end
    end
    n = p.K.l;
    p = presolve_remove_repeatedrows(p);
    n = n-p.K.l;
    if p.options.bnb.verbose
        if n_strengthened>0
            disp(['* ' num2str(n_strengthened) ' cliques strengthened']);
        end
        if n>0
            disp(['* ' num2str(n) ' cliques removed after strenghtening']);
        end
    end
end