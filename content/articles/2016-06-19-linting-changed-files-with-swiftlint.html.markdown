---
title: Linting Changed Files With SwiftLint
date: "2016-06-19"
tags: swift
---

[SwiftLint](https://github.com/realm/SwiftLint) is an incredible tool for identifying style issues with Swift codebases, and highlighting them right in Xcode. It’s great for saving time during code reviews, letting reviewers to worry about _important_ issues.

The problem is trying to integrate SwiftLint into an existing codebase which has been worked on by dozens of authors – adding SwiftLint into a work project gave us over _20,000_ warnings. It’s fantastic that SwiftLint caught these, but this drowns out issues which may be really important.

One way around this problem is to only check files which have been modified. Our scripts are kept in a `Scripts` directory, so this was added as a Run Script build phase:

```
${SRCROOT}/Scripts/lint.sh
```

Next, the script itself:

```
SWIFT_LINT=/usr/local/bin/swiftlint

lint() {
  local filename="${1}"
  if [[ "${filename##*.}" == "swift" ]]; then
    ${SWIFT_LINT} lint --path "${filename}"
  fi
}

if [[ -e "${SWIFT_LINT}" ]]; then
  git diff --cached --name-only | while read filename; do lint "${filename}"; done
else
  echo "SwiftLint is not installed."
  exit 0
fi
```

This uses `git` to get the file names of the changed files and check that they’re Swift source files. If so, they get run through `swiftlint` and any warnings are sent to Xcode. Now you can still get warnings for files you’re working on, without the Issues navigator becoming too crowded.
