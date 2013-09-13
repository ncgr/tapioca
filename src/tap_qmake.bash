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

export PATH=/opt/gridengine/bin/lx26-amd64:${PATH}
export PATH=/sw/compbio/bowtie2/cv/bin:$PATH
export PATH=/sw/compbio/tapioca/agr-dev:$PATH
export PATH=/sw/compbio/fqutils/cv/bin:$PATH
export PATH=/sw/perl/bin:${PATH}

# Use -inherit since we're running qmake in batch mode
# http://docs.oracle.com/cd/E19957-01/820-0699/chp4-28/index.html

qmake -inherit -v PATH -cwd -- all

