"""

Created on 13.06.2020
@author: David Wolf

"""

import os

import deeplabcut
from shutil import copyfile

def getsubfolders(folder):
    ''' returns list of subfolders '''

    return [os.path.join(folder, p) for p in os.listdir(folder) if os.path.isdir(os.path.join(folder, p))]


# project-name
project = 'Pupil-8point-David-2020-06-17' # 'td19_lick-mirko-2020-03-11' #

# shuffle-index
shuffle = 1

# path of project folder
prefix = '//isilon02\zisvlx02_data\dep_psychatrie_psychotherapie\group_entwbio\data\David\Video_Analysis' #'C:\Mirko DLC' #

projectpath = os.path.join(prefix, project)
print('Using DeeplabCut network from: ', projectpath)

# directory where to copy output
output_path = 'F:\Mirko\Pupil\eightpoint_refined' # '//isilon02\zisvlx02_data\dep_psychatrie_psychotherapie\group_entwbio\data\Jonathan\Test_pupil_ICON' #

#config file created from the path
config = os.path.join(projectpath, 'config.yaml')

# base path with directories to videos for analysis
basepath = '//isilon02\zisvlx02_data\dep_psychatrie_psychotherapie\group_entwbio\data\Mirko\TD19\DATA\VidShortCut2' # '//isilon02\zisvlx02_data\dep_psychatrie_psychotherapie\group_entwbio\data\Jonathan\Test_pupil_ICON'
print('Analyzing videos in: ', basepath)

subfolders = getsubfolders((basepath))
print(subfolders)

for subfolder in subfolders:

    # only right directories of format
    #sub_ident = os.path.split(subfolder)
    #if len(sub_ident[1]) != 8:
     #   continue

    # animal folder in "day"-folder
    subsubfolders = getsubfolders(subfolder)
    for subsubfolder in subsubfolders:
        try:
            for file in os.listdir(subsubfolder):
                if file.endswith(".wmv"):  # pupil videos are .wmv

                    # outputdir
                    for wmv_file in os.listdir(subsubfolder):
                        if ".wmv" in wmv_file:
                            session_ident = wmv_file[0:len(wmv_file) - 4]
                            break
                    dayfolder = os.path.split(subfolder)
                    animalfolder = os.path.split(subsubfolder)
                    output_dir = os.path.join(output_path, dayfolder[1], animalfolder[1])
                    if not os.path.exists(output_dir):
                        os.makedirs(output_dir)

                    video_path = [os.path.join(os.path.abspath(basepath), subfolder, subsubfolder, file)]

                    # make short video for visual checking
                    short_output = os.path.join(output_dir, 'short')
                    if not os.path.exists(short_output):
                        os.makedirs(short_output)
                    short_path = deeplabcut.ShortenVideo(video_path[0], start="00:00:30", stop="00:01:00",
                                                         outsuffix='short', outpath=short_output)
                    short_file = os.path.split(short_path)
                    deeplabcut.analyze_videos(config, [short_path], save_as_csv=True, destfolder=short_output)
                    deeplabcut.filterpredictions(config, [short_path], filtertype='median', windowlength=5,
                                                 save_as_csv=True, destfolder=short_output)
                    deeplabcut.plot_trajectories(config, [short_path], filtered=True, destfolder=short_output)
                    deeplabcut.create_labeled_video(config, [short_path], filtered=True, destfolder=short_output)

                    deeplabcut.analyze_videos(config, video_path, save_as_csv=True, destfolder=output_dir)
                    deeplabcut.filterpredictions(config, video_path, filtertype='median', windowlength=5,
                                                 save_as_csv=True, destfolder=output_dir)
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


