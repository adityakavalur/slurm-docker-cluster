import grp
import pwd
import os
import json
import fnmatch

from glob import glob
org_dir="/data/xalt2_json"
reloc_dir="/data/xalt2_json_moved"
xalt_dir=glob(org_dir+"/*")

user=pwd.getpwuid(os.getuid()).pw_uid

#move dir at the end of the run
for slurmjobs in xalt_dir:
   stat_info = os.stat(slurmjobs)
   uid = stat_info.st_uid
   if (uid == user):
      slurmjobs2=slurmjobs+"/*"
      xalt2list=glob(slurmjobs2)
      for job2 in xalt2list:
         movefile = False
         with open(job2) as json_file:
            data = json.load(json_file)
            if 'userT' in data:
               if data["userT"]["job_id"] == os.environ.get('SLURM_JOBID') :
                  movefile = True
         if (movefile):
            xaltnum=slurmjobs
            xaltnum=slurmjobs.replace(org_dir,'')
            if not os.path.exists(reloc_dir+xaltnum):
               os.makedirs(reloc_dir+xaltnum)
            moveddir = job2.replace(org_dir,reloc_dir)
            os.replace(job2,moveddir)

#This needs to be done elsewhere
##delete empty folders
#for slurmjobs in xalt_dir:
#   print(len(fnmatch.filter(os.listdir(slurmjobs), '*.json')))
                  
