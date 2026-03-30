function pupil_compare_filters(d)
idx =207;
f = figure;
ax=gca;
ax.Position =[1 1 50 25];

raw = plot(d.pupil(idx).raw_trace);
hold on;
samplerate = d.pupil(idx).info.samplerate;
bars =0;
ms = 20;
events = d.events{idx};    
for tr =1:numel(events)
       OC = [events(tr).fv_on_odorcue events(tr).fv_off_odorcue]*samplerate;
       OCdiameter = [d.pupil(idx).lp_trace(round(OC(1))) d.pupil(idx).lp_trace(round(OC(2)))]; 
              
       RC = [events(tr).fv_on_rewcue events(tr).fv_off_rewcue]*samplerate;
       RCdiameter = [d.pupil(idx).lp_trace(round(RC(1))) d.pupil(idx).lp_trace(round(RC(2)))]; 
       
       if events(tr).drop_or_not
       REW = events(tr).reward_time*samplerate;
       REWdiameter = d.pupil(idx).lp_trace(round(REW));
       end
       
       [oc_color,rc_color] = get_marker_color(events(tr).curr_odorcue_odor_num,events(tr).curr_rewardcue_odor_num);
       
       OCon = plot(OC(1),OCdiameter(1),[oc_color '.'],'MarkerSize',ms);
       OCoff = plot(OC(2),OCdiameter(2),[oc_color '.'],'MarkerSize',ms);
       if bars
           OConBar = plot([OC(1) OC(1)],[mindia+pup_range maxdia+pup_range],'k');
           OCoffBar = plot([OC(2) OC(2)],[mindia+pup_range maxdia+pup_range],'k');       
       end
       
       RCon = plot(RC(1),RCdiameter(1),[rc_color '.'],'MarkerSize',ms);
       RCoff = plot(RC(2),RCdiameter(2),[rc_color '.'],'MarkerSize',ms);
       if bars
           RConBar = plot([RC(1) RC(1)],[mindia+pup_range maxdia+pup_range],'b');
           RCoffBar = plot([RC(2) RC(2)],[mindia+pup_range maxdia+pup_range],'b');
       end
       
       if ~isempty(REW)
           REWtime = plot(REW,REWdiameter,'r.','MarkerSize',ms);       
           if bars
               REWtimeBar = plot([REW REW],[mindia+pup_range maxdia+pup_range],'r');       
           end
       end
end

% 
% lp = plot(d.pupil(idx).lp_trace-25);
% lp2 = plot(d.pupil(idx).lp2_trace-50);
% lp3 = plot(d.pupil(idx).lp3_trace-75);
% bp = plot(d.pupil(idx).bp_trace-10);
% bp2 = plot(d.pupil(idx).bp2_trace-30);
bp3 = plot(d.pupil(idx).bp3_trace+10);
bp4 = plot(d.pupil(idx).bp4_trace+20);
bp5 = plot(d.pupil(idx).bp5_trace+30);
bp6 = plot(d.pupil(idx).bp6_trace+50);


lp_par = d.pupil(idx).info.LP_params;
lp2_par = d.pupil(idx).info.LP2_params;
lp3_par = d.pupil(idx).info.LP3_params;
bp_par = d.pupil(idx).info.BP_params;
bp2_par = d.pupil(idx).info.BP2_params;
bp3_par = d.pupil(idx).info.BP3_params;
bp4_par = d.pupil(idx).info.bp4_params;
bp5_par = d.pupil(idx).info.BP5_params;
bp6_par = d.pupil(idx).info.BP6_params;


legend([OCon RCon REWtime raw bp6 bp5 bp4 bp3],{'OC','RC','REW','raw',bp6_par,bp5_par,bp4_par,bp3_par},'Location','northwest');

% legend([OCon RCon REWtime raw lp lp2 lp3 bp bp2 bp3],{'OC','RC','REW','raw',lp_par,lp2_par,lp3_par,bp_par,bp2_par,bp3_par},'Location','northwest');
title(d.info(idx).ID);
end


function [oc_color,rc_color] = get_marker_color(oc_num,rc_num)
switch oc_num
    case 5
        oc_color = 'g';
    case 6
        oc_color = 'b';
end
switch rc_num
    case 7
        rc_color = 'y';
    case 8
        rc_color = 'k';
end
end
