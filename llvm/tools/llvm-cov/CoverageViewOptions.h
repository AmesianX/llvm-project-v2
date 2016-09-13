//===- CoverageViewOptions.h - Code coverage display options -------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_COV_COVERAGEVIEWOPTIONS_H
#define LLVM_COV_COVERAGEVIEWOPTIONS_H

#include "RenderingSupport.h"
#include <vector>

namespace llvm {

/// \brief The options for displaying the code coverage information.
struct CoverageViewOptions {
  enum class OutputFormat {
    Text,
    HTML
  };

  bool Debug;
  bool Colors;
  bool ShowLineNumbers;
  bool ShowLineStats;
  bool ShowRegionMarkers;
  bool ShowLineStatsOrRegionMarkers;
  bool ShowExpandedRegions;
  bool ShowFunctionInstantiations;
  bool ShowFullFilenames;
  OutputFormat Format;
  std::string ShowOutputDirectory;
  std::vector<std::string> DemanglerOpts;
  uint32_t TabSize;
  std::string ProjectTitle;
  std::string ObjectFilename;
  std::string CreatedTimeStr;

  /// \brief Change the output's stream color if the colors are enabled.
  ColoredRawOstream colored_ostream(raw_ostream &OS,
                                    raw_ostream::Colors Color) const {
    return llvm::colored_ostream(OS, Color, Colors);
  }

  /// \brief Check if an output directory has been specified.
  bool hasOutputDirectory() const { return !ShowOutputDirectory.empty(); }

  /// \brief Check if a demangler has been specified.
  bool hasDemangler() const { return !DemanglerOpts.empty(); }

  /// \brief Check if a project title has been specified.
  bool hasProjectTitle() const { return !ProjectTitle.empty(); }

  /// \brief Check if the created time of the profile data file is available.
  bool hasCreatedTime() const { return !CreatedTimeStr.empty(); }

  /// \brief Get the LLVM version string.
  std::string getLLVMVersionString() const {
    std::string VersionString = "Generated by llvm-cov -- llvm version ";
    VersionString += LLVM_VERSION_STRING;
    return VersionString;
  }
};
}

#endif // LLVM_COV_COVERAGEVIEWOPTIONS_H
