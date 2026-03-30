%% Script to plot graphs of networks from adjacency matrices of social interaction data
% David Wolf, 08.2023

clear;
data_path = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/06-social_interaction/';

for group = 1:2
    
    network_list = dir(fullfile(data_path,['GJ',num2str(group)],'adjacency_matrix','*resD7*'));
    network_list([network_list.isdir]) = [];

    for nn = 1:numel(network_list)

        % output dir
        save_path = fullfile(data_path,['GJ',num2str(group)],'adjacency_matrix','plots');
        if ~isfolder(save_path); mkdir(save_path); end

        % load and check network input
        cur_network = readtable(fullfile(network_list(nn).folder,network_list(nn).name));
        cur_names = cur_network.Properties.VariableNames;
        cur_names(1)= [];
        cur_names = cellfun(@(x) x(2:end),cur_names,'UniformOutput',0);

        % resort if necessary
        [t1,col_idx] = sort(cur_names');
        [t2,row_idx] = sort(cur_network.Var1);

        cur_network = table2array(cur_network(:,2:end));
        cur_network = cur_network(row_idx,col_idx);
        assert(size(cur_network,1)==size(cur_network,2));
        assert(sum(diag(cur_network))==0);

        data.match_matrix = cur_network;
        try
            f = plot_graph(data,cur_names);
            title(network_list(nn).name,'Interpreter','none');
            saveas(f,fullfile(save_path,[network_list(nn).name(1:end-4),'.png']),'png');
            close all;
        catch
            warning([network_list(nn).name, 'failed']);
        end
    end
end
%%
function f = plot_graph(DS_info,names)
%% original design from Carla Filosa
% DS_info is output of DS_info = compute_DS_from_match_matrix(full_match_matrix);
% names should be in the order of the original match-matrix, not sorted by
% rank!

[win, los]=find(DS_info.match_matrix);
for i=1:length(win)
    weight(i)=DS_info.match_matrix(win(i),los(i));
end

%%%%% Graph plot
G=digraph(win,los,weight);  
LWidths = 3*G.Edges.Weight/max(G.Edges.Weight);
f=figure('name','Graph');
p=plot(G,'LineWidth',LWidths,'NodeLabel',[],'Layout','force');
p.ArrowSize=6; p.EdgeColor='b';p.NodeColor=[.6 .6 .6];
p.NodeLabel=names;
p.NodeFontName = 'Arial';
p.NodeFontSize = 6;
p.MarkerSize = 10;
% color the nodes with rank
% p.NodeCData = 1:numel(names);
% % p.NodeCData = 10:10:100;
% c=colorbar;
% c.Label.String = 'rank';
% set(c, 'YDir', 'reverse' );

set_fonts()
f.Units = 'centimeters';
f.Position = [3 3 12 6];

end