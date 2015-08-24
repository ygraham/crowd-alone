# crowd-alone
Crowd-sourcing System-level MT Evaluations

Instructions for Crowd-Alone: Crowd-sourcing System-level Evaluations for MT
-----------------------------------------------------------------------------------

Contact: graham.yvette@gmail.com

-----------------------------------------------------------------------------------

The following is a description of how to collect system-level assessments
of translation fluency and adequacy on MTurk using methods described in 
the paper:

    Yvette Graham, Timothy Baldwin, Alistair Moffat and Justin Zobel. 
    "Can Machine Translation be evaluated by the crowd alone?" 
    Journal of Natural Language Engineering, 2015.

The code is intended for use in combination with the MTurk web-based
requester user interface.

How to run:
--------------------

The code for collecting hits on MTurk is divided into two folders, one for
creating the files needed to run HITs and one for post-processing HITs.
To prepare the files for MTurk, go to folder "./prep-hits" and follow
the instructions below.

The following folder contains an example of how set-up expects text files
containing translations and reference translations to be located and named:

    ./data

The following command creates the necessary files for posting hits on MTurk
and places them in the directory "./out". Note that the command takes
approximately 4 minutes per 1000 sentences included due to the creation of
image files. It takes approximately 20 minutes in total to run on the example
data set:

    bash set-up-lang-pair.sh cs en newstest2013

"./out" should now contain the following:

    (1) a directory containing reference translation image files:
    ./out/img/ref/en

    (2) a directory containing image files for the translations to be
    assessed by human judges (files named by randomly generated keys):
    ./out/img/ad/cs-en

    (3) A csv file of hits to be uploaded to MTurk:
    out/ad.hits.set-05.ad.cs-en.csv

The folders containing the created image files should be placed in a
publicly visible folder with permissions changed as necessary to allow
all image files to be visible from the web. You can test this after
relocating the image files to an appropriate place by simply loading one
of the relocated image files in a browser.

Next, edit the MTurk source file:

    ./out/mturk-source

so that the url in the MTurk code matches the urls of the public directory
where your image files are located. The original url looks like this:

    http://scss.tcd.ie/~ygraham/mturk-img

In your MTurk requester account, go to

    "Create",
    "New Project",
    "Other",
    "Create Project".

Give your project a "Project Name", you can edit the other details in later.
Click on the

    "Design Layout" tab.

Click on

    "Source".

Select all of the source code displayed and replace with the MTurk code
in the file:

    ./out/mturk-source

    Click "Source" again.
    Click "Save".
    Click "Preview" - note the images won't display in the MTurk "preview" and
    the javascript click-through of 100 test items won't function properly, just
    ignore that for now.

    Click on "Create" tab to bring you back to a list of all your existing
    projects.

You should go back and edit the project to change the HIT fee payment,
the project description, etc.
When you are ready to post hits to MTurk workers, upload the csv file
by clicking "Publish Batch" beside the name of your project.
You'll be prompted to upload a csv file. Upload the following file:

    out/ad.hits.set-05.ad.cs-en.csv

------------------------------------------------------------------------------
After HIT completion:
------------------------------------------------------------------------------

Go to directory 

    ../proc-hits

Download the batch file of hits from MTurk and place in folder:

    ./batched-hits

The files should be named, e.g.:

    ./batched-hits/Batch_1234_batch_results.csv

Run the following command:

    bash proc-hits-step1.sh > out/step1

This creates some files in fold "./analysis". To find out which
workers have been flagged as possible aggressive optimizers, type
the following:

    grep flag analysis/ad-wrkr-stats.csv

There are 4 ways a worker can be flagged, here's how to interpret:

    flag(scrs) : mean scores for badref / genuine system output / ref items very close
    flag(time) : time taken to complete a hit very short
    flag(seq)  : the worker gave constant ratings for a long sequence of translations at least once in the hit
    flag(rej)  : hits from this worker have previously been rejected

It is ultimately up to the individual researcher to decide which hits to
reject, however.

Next, standardize the scores to iron-out differences in individual worker
scoring strategies:

    bash standardize-scrs.sh cs en > out/step2

When you have collected a minimum of 500 assessments per system,
compute mean scores. To compute mean scores per system:

    bash score-systems.sh cs en > out/step3

This creates two files, one containing mean scores computed for systems
computed from raw scores provided by workers. The other is when scores
are standardized per worker mean and standard deviation of their overall
score distribution:

    ./analysis/ad-raw-system-scores-500.es-en.csv
    ./analysis/ad-stnd-system-scores-500.es-en.csv

... any questions, please contact graham.yvette@gmail.com 
