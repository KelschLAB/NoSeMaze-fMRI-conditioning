function convert_tubetest_data_JR(filepath);

RawData=importdata(filepath);

RawOutput_beast=RawData;

RawOutput_beast=RawOutput_beast(2:end);

num_rows=numel(RawOutput_beast); %get the lengths of the cvs-file

%% Replace IDs for animals with different animal IDs during scan:
% Autonomouse 1: 
replacement_array{1,1} = '0007CB6DE9';
replacement_array{1,2} = '0007CB357C';% new ID
replacement_array{2,1} = '0007CB0EDD';
replacement_array{2,2} = '0007CB330D';% new ID
replacement_array{3,1} = '0007CB6D7C';
replacement_array{3,2} = '0007CB6EA3';% new ID

% Autonomouse 2:
replacement_array{4,1} = '0007CB0FC2';
replacement_array{4,2} = '0007CB6B2C';% new ID

%loop to convert data to mat-file

for row_cur=1:num_rows
    
    RawOutput_beast(row_cur)=replace(RawOutput_beast(row_cur),',','|');
    
    %day
    TubeTestData(row_cur).day=RawOutput_beast{row_cur,1}(39:49);
    
    %Time Stamp
    TubeTestData(row_cur).time=RawOutput_beast{row_cur,1}(50:end);
    
    %Antenna
    TubeTestData(row_cur).antenna=str2num(RawOutput_beast{row_cur,1}(35));
    
    %Animal ID uncorrected
    TubeTestData(row_cur).animal_id_uncorrected=RawOutput_beast{row_cur,1}(1:10);
    
    %Animal ID corrected
    
    % Replace 0007CB6DE9 by 0007CB357C
    replacement_array{1,1}
    
    for ix = 1:length(replacement_array)
        if strcmp(RawOutput_beast{row_cur,1}(1:10),replacement_array{ix,1});
            TubeTestData(row_cur).animal_id = replacement_array{ix,2};
        else
            TubeTestData(row_cur).animal_id = RawOutput_beast{row_cur,1}(1:10);
        end
    end      
        
end
    
[fpath,fname,ext]=fileparts(filepath);
save([fpath filesep 'tubetestdata.mat'],'TubeTestData');
    
    