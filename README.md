Tapioca
=======
Tapioca is a pipeline for Illumina Casava 1.8 genome analyzer/hiseq data. Main features:
* contaminant filtering
* fastq statistical summary
* collating/binning of casava chunks

(why tapioca? "In Brazil, the plant (cassava) is named "mandioca", while its starch is called "tapioca" https://en.wikipedia.org/wiki/Tapioca )

Depends on
---
* Casava 1.8 http://support.illumina.com/sequencing/sequencing_software/casava.ilmn
* Bowtie2 http://bowtie-bio.sourceforge.net/bowtie2/
* fqutils https://github.com/crowja/fqutils
* tpipe http://www.eurogaran.com/index.php/es/component/remository/tpipe/ (also see Unix Power Tools http://shop.oreilly.com/product/9780596003302.do)
* Make, gzip, just standard Linux utilties
* Perl5 http://perl.org
* Perl modules (many of which are already in your perl distro) 
Bio::SeqReader::Fastq;
Cwd;
File::Basename;
File::Path;
File::Spec;
File::Which;
Getopt::Long;
IO::File;
IO::Uncompress::AnyUncompress;
IO::Uncompress::Gunzip
Readonly;
Term::ANSIColor;
XML::Simple;

Setup
---
In addition to the software dependencies, you'll need
* A directory containing your Illumina sequencing instrument output.
* Two bowtie libraries for contaminant filtering. We created one called phix and
 one called 'other' for adapters and primers.

Walkthrough
---
* Make a new directory for the Casava & Tapioca output. Dont work in the instrument's output directory.

```bash
mkdir tap-work
cd tap-work
```
* Create file samplesheet.csv. Either using Illumina's experiment manager
software, or by a script to pull data from your internal LIMS. The
samplesheet.csv format is described in Illumina's documentation.
* Run Casava 1.8 to generate an Unaligned/ directory and makefile. Example:

```bash
configureBclToFastq.pl \
 --input-dir /your/instrument/output/run_flowcell/Data/Intensities/BaseCalls/ \
 --output-dir ./Unaligned \
 --sample-sheet samplesheet.csv \
 --with-failed-reads
 ```
note: It is recommended to use option --with-failed-reads, then tapioca will later
separate failed chastity reads into a separate file.  See Casava user's guide
for other options, e.g. --use-bases-mask  etc.
* Start Casava by cd into Unaligned and running make.

```bash
cd Unaligned
make
```
* configure Tapioca after Casava finishes. Like Casava, Tapioca uses Make for dependency tracking
and job parallelism. Run the tap_configure_postprocessing script. The last parameter is the
Unaligned directory created by Casava 1.8.

```bash
tap_configure_postprocessing \
 --contam-phix-index /your/contam_libs/tapioca_phix_contam \
 --contam-phix-pct 80 \
 --contam-other-index /your/contam_libs/tapioca_other_contam \
 --contam-other-pct 20 \
 --deployed /your/deployed/dir \
 ./Unaligned
```
the makefile was created.
* First run the precheck target; it does some sanity checking on the casava run
and will output some warnings if it notices anything wrong off the bat.

```bash
make precheck
```
* making the 'all' target will perform the contaminant filtering and summary
reporting. Technically it is not 'all' because the deploy step is a separate
target.

```bash
make -j 16 all
```
The -j 16 will use 16 cores. Alternately, the qmake script could be submitted to
a SGE cluster if more parallelism is required. Qmake job submission has not been tested.
Now check results as necessary, in the various ./Project directories.
* Run make deploy when ready

```bash
make deploy
```
The deploy target collates all the chunks of data from the casava output into
the --deployed directory. You could add more targets to the makefile to
perform additional processing after the deploy is finished.

Output
---
Look in the Deployed directory. It should be pretty self explanatory how things are organized by 
subdirectory. Sorry this is not better documented


Cleanup
---
There is no 'make clean' target, and please be aware the intermediate Project
directories created by tapioca have uncompressed fastq files in them, and so
should not be left on disk long term. Delete the directories yourself.

Authors
---
John Crow  https://github.com/crowja , 
Alex Rice (agr@ncgr.org)

