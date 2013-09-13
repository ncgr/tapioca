Tapioca
=======

Tapioca is a pipeline for Illumina Casava 1.8 next-gen sequencing data.

Dependencies
------------
Casava 1.8 http://support.illumina.com/sequencing/sequencing_software/casava.ilmn
Bowtie2 http://bowtie-bio.sourceforge.net/bowtie2/
fqutils https://github.com/crowja/fqutils
tpipe http://www.eurogaran.com/index.php/es/component/remository/tpipe/ (also see Unix Power Tools http://shop.oreilly.com/product/9780596003302.do)
Make, gzip, just standard Linux utilties
Perl5 http://perl.org
Perl modules (many of which are already in your perl distro) 
```perl
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
```

Setup
-----
In addition to the software dependencies, you'll ned

* A results directory from your Illumina sequencing instrument output.

* Two bowtie libraries for contaminant filtering. We use one called phix and
* one called 'other' for adapters and primers.

Walkthrough
-----------
Assuming you hav, then 

* Make a directory for the Casvaa & Tapioca output.
```bash
mkdir tap-work
cd tap-work
```

* Create file samplesheet.csv. Either using Illumina's experiment manager
software, or by a script to pull data from your internal LIMS. The
samplesheet.csv format is described in Illumina's documentation.

* Run Casava 1.8 to generate an Unaligned/ directory. Example:

```bash
configureBclToFastq.pl \
 --input-dir /your/instrument/output/run_flowcell/Data/Intensities/BaseCalls/ \
 --output-dir ./Unaligned \
 --sample-sheet samplesheet.csv \
 --with-failed-reads
 ```

note: if you give it the option with-failed-reads, then tapioca will later
separate failed chastity reads into a separate file.  See Casava user's guide
for other options, e.g. --use-bases-mask  etc.

* run Casava 
```bash
cd Unaligned
make
```

* configure Tapioca. Like Casava, Tapioca uses Make for dependency tracking
and job parallelism. Run the configure script. The last parameter is the
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

* making the 'all' target will perform the contaminant filtering and  summary
reporting. Technically it is not 'all' because the deploy step is   a separate
target.
```bash
make -j 16 all
```
The -j 16 is for 16 cores. alternately, the qmake script could be submitted to
a SGE cluster if more parallelism is required. qmake has note been tested.

Now check results as necessary, in the various ./Project directories.

* Run make deploy when ready:
```bash
make deploy
```

The deploy target collates all the chunks of data from the casava output into
the --deployed directory. You could add more targets to the makefile to
perform additional processing after the deploy is finished.

Cleanup
-------
There is no 'make clean' target, and please be aware the intermediate Project
directories created by tapioca have uncompressed fastq files in them, and so
should not be left on disk long term. Delete the directories yourself.



