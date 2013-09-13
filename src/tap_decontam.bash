#! /bin/bash

# Tapioca
# Copyright (C) 2013 National Center for Genome Resources - http://ncgr.org
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

_I_AM='tap_decontam.bash'
_VERSION='%BUNDLE_VERSION%'

function print_usage {
  cat <<_TEXT
Usage: $_I_AM [OPTIONS] out_tag infile [id_file1 ...]
Attempts to remove contaminants found in infile, as flagged by id_file1 ...

Options:
-h        Print this help message to stdout and exit.
-v        Print the version information to stdout and exit.
_TEXT
}

# Process the command line options
while getopts ":ht:v" opt; do
  case $opt in
    h )
      print_usage
      exit 0
      ;;
    v )
      echo "$_I_AM $_VERSION"
      exit 0
      ;;
    \? )
      echo "[ERROR] $_I_AM: Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    : )
      echo "[ERROR] $_I_AM: Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Ok do some real work now

out=$1
shift

in=$1
shift

#echo "OUT = $out"
#echo "IN = $in"
#echo "OTHERS = $@"
#exit 1

rm -f "${out}_A.fq"
rm -f "${out}_B.fq"
rm -f "${out}-clean.fq"
rm -f "${out}-contam.fq"
rm -f "${out}-contam.dat"

if [ ! -f "$in" ]; then
  echo "[ERROR] $_I_AM: Cannot find input file \"$in.\"." >&2
  exit 1
fi

# $@ represents all the contam id_files available
gunzip -c "$in" | fqu_splitq --out "$out" $@

#if [ $? ]; then
#  echo "[ERROR] $_I_AM: Processing of \"$in\" failed. Unable to fqu_splitq the input" >&2
#  exit 1
#fi

if [ -f "${out}_A.fq" ] && [ -f "${out}_B.fq" ]; then
  mv "${out}_B.fq" "${out}-clean.fq"
  mv "${out}_A.fq" "${out}-contam.fq"
  # being very cautious
  if [ -f "${out}-clean.fq" ] && [ -f "${out}-contam.fq" ]; then
    sort -u $@ | grep -v '^#' > "${out}-contam.dat"
    exit 0
  fi
fi

# Bad exit ...
rm -f "${out}_A.fq"
rm -f "${out}_B.fq"
rm -f "${out}-clean.fq"
rm -f "${out}-contam.fq"
rm -f "${out}-contam.dat"

echo "[ERROR] $_I_AM: Processing of \"$in\" failed." >&2

exit 1
