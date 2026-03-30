function P= read_t2s(fname)
if nargin==0;
  if strmatch(spm('ver'),'SPM5')
    fname=spm_select(1,'any','Select Text-File');
  else
    fname=spm_get(1,'*.txt','Select Text-File');
  end
  end
  fid=fopen(fname);
  if fid
    P='';
    while~feof(fid)
      line=fgetl(fid);
      P=strvcat(P,line);
    end
    fclose(fid);
  else
    return
  end
  
