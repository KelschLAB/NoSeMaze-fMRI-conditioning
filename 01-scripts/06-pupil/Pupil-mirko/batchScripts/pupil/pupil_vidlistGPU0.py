"""

Created on 13.06.2020
@author: David Wolf

Modified on 21.07.2020
@author: Mirko Articus
-> takes list of comma separated video fullpaths as input and saves ouput in same dir as video

"""

import os
os.environ["CUDA_VISIBLE_DEVICES"]="0"
import deeplabcut
from shutil import copyfile

# project-name
project = 'Pupil-8point-David-2020-06-17' #'td19_lick-mirko-2020-03-11' #

# shuffle-index
shuffle = 1

# path of project folder
prefix = '/home/mirko.articus/DLC'
#'C:\MirkoDLC' #'//isilon02\zisvlx02_data\dep_psychatrie_psychotherapie\group_entwbio\data\David\Video_Analysis' ##

projectpath = os.path.join(prefix, project)
print('Using DeeplabCut network from: ', projectpath)

#config file created from the path
config = os.path.join(projectpath, 'config.yaml')

# list with directories to videos for analysis
vidlist = (os.path.join(prefix, 'vidList0.txt'))#r'C:\MirkoDLC\vidlist.txt'
vidlist = open(vidlist, mode='r')
vidlist = vidlist.read()
vidlist = vidlist.split(',')
print('Analyzing videos: ', vidlist)

for vid in vidlist:
    output = os.path.split(vid)
    try:
        output_dir = output[0]
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        video_path = [vid]

        # make short video for visual checking
        short_output = os.path.join(output_dir, 'short')
        if not os.path.exists(short_output):
            os.makedirs(short_output)
        short_path = deeplabcut.ShortenVideo(video_path[0], start="00:00:30", stop="00:01:00", outsuffix='short', outpath=short_output)
        short_file = os.path.split(short_path)
        deeplabcut.analyze_videos(config, [short_path], save_as_csv=True, destfolder=short_output)
        deeplabcut.filterpredictions(config, [short_path], filtertype='median', windowlength=5,save_as_csv=True, destfolder=short_output)
        deeplabcut.plot_trajectories(config, [short_path], filtered=True, destfolder=short_output)
        deeplabcut.create_labeled_video(config, [short_path], filtered=True, destfolder=short_output)

        deeplabcut.analyze_videos(config, video_path, save_as_csv=True, destfolder=output_dir)
        deeplabcut.filterpredictions(config, video_path, filtertype='median', windowlength=5,save_as_csv=True, destfolder=output_dir)
        deeplabcut.plot_trajectories(config, video_path, filtered=True, destfolder=output_dir)



    except:
        print('Error')

        '''
                    try:    
                        copyfile(short_path, os.path.join(output_dir, short_file[1]))
                    except:
                        print('Could not copy')


            # second loop over all videos (also shortened)
            for file in os.listdir(subsubfolder):
                if file.endswith(".wmv"):

                    video_path = [os.path.join(os.path.abspath(basepath), subfolder, subsubfolder, file)]
                    print('Analyzing video from: ', file)
                    deeplabcut.analyze_videos(config, video_path, save_as_csv=True, destfolder=output_dir)
                    deeplabcut.filterpredictions(config, video_path[0], filtertype='median', windowlength=5, save_as_csv=True, destfolder=output_dir)
                    deeplabcut.plot_trajectories(config, video_path, filtered=True, destfolder=output_dir)

                    if "short" in file:
                        deeplabcut.create_labeled_video(config, video_path, filtered=True, destfolder=output_dir)


        #except:
         #          print('Error')

        '''


