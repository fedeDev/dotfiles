#!/usr/bin/env python

import fnmatch
import os
import sys
import subprocess
import xml.dom.minidom as dom
import ycm_core
import re

UNWANTED_FLAGS = set(['-Wall', '-O3', '-Wextra', '-Werror'])
def RemoveFlagsThatMakeCompilationSlower(flags):
  new_flags = []
  for flag in flags:
    if flag in UNWANTED_FLAGS:
      continue
    new_flags.append( flag )
  return new_flags

def LoadSystemIncludes():
    regex = re.compile(
            ur'(?:\#include \<...\> search starts here\:)(?P<list>.*?)(?:End of search list)',
            re.DOTALL);
    process = subprocess.Popen(['clang', '-v', '-E', '-x', 'c++', '-'],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE);
    process_out, process_err = process.communicate('');
    output = process_out + process_err;
    includes = [];
    for p in re.search(regex, output).group('list').split('\n'):
        p = p.strip();
        if len(p) > 0 and p.find('(framework directory)') < 0:
            includes.append('-isystem');
            includes.append(p);
    return includes;

def MakeRelativePathsInFlagsAbsolute( flags, working_directory ):
  if not working_directory:
    return list( flags )
  new_flags = []
  make_next_absolute = False
  path_flags = [ '-isystem', '-I', '-iquote', '--sysroot=' ]
  for flag in flags:
    new_flag = flag

    if make_next_absolute:
      make_next_absolute = False
      if not flag.startswith( '/' ):
        new_flag = os.path.join( working_directory, flag )

    for path_flag in path_flags:
      if flag == path_flag:
        make_next_absolute = True
        break

      if flag.startswith( path_flag ):
        path = flag[ len( path_flag ): ]
        new_flag = path_flag + os.path.join( working_directory, path )
        break

    if new_flag:
      new_flags.append( new_flag )
  return new_flags

def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in ['.h', '.hpp']

def GetNode(parent, tagname):
    return [n for n in parent.childNodes if n.nodeType == n.ELEMENT_NODE and n.tagName == tagname][0]

# From the full path to a package.xml file, get its name.
def GetPackageName(filename_path):
    try:
        root = dom.parse(filename_path)
    except Exception as ex:
        raise InvalidPackage('The manifest contains invalid XML:\n%s' % ex)
    name_dom = GetNode(GetNode(root, 'package'), 'name').childNodes[0]
    return str(name_dom.data)

# From the given file path, find the package.xml that owns it. For example, if
# given: /home/fede/redwood_ws/RedwoodInternal/closed/ransac/src, then we will
# return /home/fede/redwood_ws/RedwoodInternal/closed/ransac/package.xml.
def FindPackageFileInverseRecursive(path):
    kMaxSuperfolders = 5
    os.chdir(path)
    path = []
    for i in range(kMaxSuperfolders):
        if os.path.isfile('./package.xml'):
            path = os.getcwd() + '/package.xml'
            break
        os.chdir('..')
    else:
        return None
    return path

# Try to find the database folder (containing compile_commands.json) for the
# given catkin package.
def FindDatabaseFolder(package_name):
    source_space = subprocess.check_output(
            ['git', 'rev-parse', '--show-toplevel'])[:-1]
    workspace_guess = os.path.abspath(os.path.join(source_space, '..'))
    build_dir_candidates = ['./build_linux', './build_linux_debug']
    for build_dir in build_dir_candidates:
        build_dir_guess = os.path.abspath(os.path.join(workspace_guess, build_dir))
        if os.path.isdir(build_dir_guess):
            build_dir_loc = build_dir_guess
            break
    else:
        return None
    package_build_dir = os.path.abspath(os.path.join(build_dir_loc, package_name))
    if not os.path.isdir(package_build_dir):
        raise ValueError('Build folder for current file does not exist yet.')
        return None
    if not os.path.isfile(os.path.abspath(os.path.join(package_build_dir,
        'compile_commands.json'))):
        raise ValueError('No compile commands found. Please enable generation.')
    return package_build_dir

def FindPattern(pattern, path):
  for root, dirs, files in os.walk(path):
    for name in files:
      if fnmatch.fnmatch(name, pattern):
        return os.path.join(root, name)

def GetBestSourceFile(header_file, path_to_package):
  # Try to find the filename.cc. Otherwise we just get the first .cc that we
  # find in the package.
  basename = os.path.splitext( header_file )[ 0 ]
  replacement_file = basename + '.cc'
  package_path = os.path.dirname(os.path.realpath(path_to_package))
  file_cc = FindPattern(os.path.basename(replacement_file), package_path)
  if file_cc:
    return file_cc
  else:
    return FindPattern('*.cc', package_path)

# This is the entry point; this function is called by ycmd to produce flags for
# a file.
def FlagsForFile( filename, **kwargs ):
  # From the filename, get the path and find the most likely package.xml.
  filename_path = os.path.dirname(os.path.realpath(filename))
  path_to_package = FindPackageFileInverseRecursive(filename_path)
  package_name = GetPackageName(path_to_package)
  database_folder = FindDatabaseFolder(package_name)
  database = ycm_core.CompilationDatabase(database_folder)
  # We handle headers differently, since there will be no data from the
  # compilation database.
  if IsHeaderFile(filename):
    new_filename = GetBestSourceFile(filename, path_to_package)
    compilation_info = database.GetCompilationInfoForFile(new_filename)
  else:
    compilation_info = database.GetCompilationInfoForFile( filename )

  final_flags = ['-O0']
  final_flags += ['-Wno-deprecated-register']
  final_flags += MakeRelativePathsInFlagsAbsolute(
    compilation_info.compiler_flags_,
    compilation_info.compiler_working_dir_ )
  final_flags += LoadSystemIncludes()
  final_flags = RemoveFlagsThatMakeCompilationSlower(final_flags)

  return {
    'flags': final_flags,
    'do_cache': True
  }
