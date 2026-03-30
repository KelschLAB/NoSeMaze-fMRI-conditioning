function TubeTestData = Convert_TubeTest_Data_JR(filepath);

% RawData=readtable(filepath,'Delimiter',';');
RawData=readtable(filepath);

num_rows=height(RawData); %get the lengths of the cvs-file

%% Replace IDs for animals with different animal IDs during scan:
% Autonomouse 1: 
replacement_array{1,1} = '0007CB6DE9';
replacement_array{1,2} = '0007CB357C';% new ID
replacement_array{2,1} = '0007CB0EDD';
replacement_array{2,2} = '0007CB330D';% new ID
replacement_array{3,1} = '0007CB6D7C';
replacement_array{3,2} = '0007CB6EA3';% new ID
replacement_array{4,1} = '0007CB0EAF';
replacement_array{4,2} = '0007CB0F95';% new ID

% Autonomouse 2:
replacement_array{4,1} = '0007CB0FC2';
replacement_array{4,2} = '0007CB6B2C';% new ID
replacement_array{5,1} = '0007CB6FE7';
replacement_array{5,2} = '0007CB2144';% new ID 

%loop to convert data to mat-file

for row_cur=1:num_rows
    row_cur
    date_time = table2array(RawData(row_cur,'Date_time'),'Format','yyyy-MM-dd');
    date_time.Format = 'yyyy-MM-dd';
    daychar = char(date_time);  
    date_time.Format = 'HH:mm:ss.SSS';
    timechar = char(date_time);  

    %day
    TubeTestData(row_cur).day=daychar;
    
    %Time Stamp
    TubeTestData(row_cur).time=timechar;
    
    %Antenna
    TubeTestData(row_cur).antenna=table2array(RawData(row_cur,'UnitNumber'));
    
    %Animal ID uncorrected
    TubeTestData(row_cur).animal_id_uncorrected=char(table2array(RawData(row_cur,'TransponderCode')));
    
    %Animal ID corrected
    TubeTestData(row_cur).animal_id=char(table2array(RawData(row_cur,'TransponderCode')));        
end
   
% Replacement of IDs
for ix = 1:length(replacement_array)
    clear logical_replacement_array
    clear number_replacement_array
    
    logical_replacement_array = all(ismember(vertcat(TubeTestData.animal_id_uncorrected),replacement_array{ix,1}),2);
    number_replacement_array=find(logical_replacement_array);
    for kx = 1:length(number_replacement_array);
        TubeTestData(number_replacement_array(kx)).animal_id = replacement_array{ix,2};
    end
    
end

    