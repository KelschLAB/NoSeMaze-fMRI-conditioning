function [d] = gng_reord_fun(dd,filepath)
aa={'rew_delay';'licks_bef_od';'licks_aft_od';'drop_or_not';'false_alarm'}
% aa={'rew_delay';'licks_aft_od';'drop_or_not';'false_alarm'}
for i=1:numel(dd), oldnames=fields(dd(i).events); end
for i=1:7, newnames{i,1}=oldnames{i};end
j=0; for i=8:numel(fields(dd(1).events)), j=j+1;newnames{i,1}=aa{j};end
for i=1:numel(dd)
   for j=1:size(dd(i).events,2)
        for z=1:numel(oldnames)
        d(i,1).events(j).(char(newnames(z)))=dd(i).events(j).(char(oldnames(z)));
        end
    end
end

%% adjusting licks
for i=1:numel(d)
   
 
 for j=1:size(d(i).events,2)
     if isempty(d(i).events(j).licks_aft_od)
         d(i).events(j).ant_lick=[]; d(i).events(j).post_lick=[];
     end
        if ~isempty(d(i).events(j).licks_aft_od)
            d(i).events(j).ant_lick=d(i).events(j).licks_aft_od((find(d(i).events(j).licks_aft_od <= d(i).events(j).rew_delay)));
            d(i).events(j).post_lick=d(i).events(j).licks_aft_od((find(d(i).events(j).licks_aft_od > d(i).events(j).rew_delay)));
        end
end
    
 
 for j=1:size(d(i).events,2)
     if isempty(d(i).events(j).licks_aft_od)
         d(i).events(j).ant_lick_count=0; d(i).events(j).post_lick_count=0;
     end
        if ~isempty(d(i).events(j).licks_aft_od)
            d(i).events(j).ant_lick_count=length(find(d(i).events(j).licks_aft_od <= d(i).events(j).rew_delay));
            d(i).events(j).post_lick_count=length(find(d(i).events(j).licks_aft_od > d(i).events(j).rew_delay));
        end
 end
    
    for j=1:size(d(i).events,2)
         if (d(i).events(j).reward==1) & length(d(i).events(j).ant_lick)>=2
             d(i).events(j).trialtype=1;
         elseif (d(i).events(j).reward==1) & length(d(i).events(j).ant_lick)<2
             d(i).events(j).trialtype=2;
         elseif (d(i).events(j).reward==0) & length(d(i).events(j).ant_lick)<2
             d(i).events(j).trialtype=3;
         elseif (d(i).events(j).reward==0) & length(d(i).events(j).ant_lick)>=2
             d(i).events(j).trialtype=4;
         end
     end 
    

end
%%  %% Phase specification
ind=[1 2];
 for i=1:numel(d)
if d(i).events(1).reward==1, o_rew=d(i).events(1).curr_odor_num; o_norew=ind(ind~=o_rew);
elseif d(i).events(1).reward==0, o_norew=d(i).events(1).curr_odor_num; o_rew=ind(ind~=o_norew);
end
    for j=1:size(d(i).events,2)
      
             if (d(i).events(j).curr_odor_num==o_rew) & (d(i).events(j).reward==1)
            aux_chap(j)=1;
            
             elseif (d(i).events(j).curr_odor_num==o_norew) & (d(i).events(j).reward==0)
            aux_chap(j)=1;
        else aux_chap(j)=2;
        end 
        baux_chap(j)=aux_chap(j);
        
    end
    h=0; ph=1;change_ind=[];
    for j=2:size(d(i).events,2)
         if aux_chap(j)~=aux_chap(j-1)
             h=h+1; ph=ph+1;
            change_ind(h)=j; phase(h)=ph;
         end
    end
    if ~isempty(change_ind)
    for k=1:numel(change_ind)-1
    baux_chap(change_ind(k):change_ind(k+1))= phase(k);
    end
    baux_chap(change_ind(end):end)=phase(end);
    else baux_chap=ones(size(d(i).events,2));
    end
    
    for j=1:size(d(i).events,2)
    d(i).events(j).phase=baux_chap(j);
    d(i).events(j).ph_rev=aux_chap(j);
    end
    clear aux_chap baux_chap change_ind phase
 end
 %% save new data
 
 filename='reordData';
 if ~isdir(filepath), mkdir(filepath); end
 save(fullfile(filepath,filename),'d')
end

