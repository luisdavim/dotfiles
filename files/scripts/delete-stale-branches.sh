#!/usr/bin/env bash
while getopts "d" opt; do
  case $opt in
    d) dryRunOpt="--dry-run" ;;
  esac
done

# prune local "cache" of remote branches first:
git fetch --prune origin
# delete merged to master branches:
mergedBranches=$(git branch -r --merged origin/master | grep "^  origin/" | cut -d/ -f2- | grep -v -e "^master$" -e "^HEAD -> origin/master$")
if [ -n "${mergedBranches}" ]; then
  echo -e "\033[0;32mDeleting merged branches...\033[0m"
  git push $dryRunOpt --delete origin ${mergedBranches}
fi
# delete branches with last (cherry picked) commit older than 5 months:
echo -e "\033[0;32mSearching for stale branches...\033[0m"
staleTimestamp=$(date -d "now - 5 months" +"%s")
maybeStaleTimestamp=$(date -d "now - 2 weeks" +"%s")
notMergedBranches=$(git branch -r --no-merged origin/master | grep "^  origin/")
branchesToDelete=""
branchesToReview=""
for branch in ${notMergedBranches}; do
  lastCommitInfo=$(git cherry origin/master ${branch} | grep -v "^-" | cut -d" " -f2 | xargs git show --format="%H|%ct|%cr|%an" --quiet | grep -v "^$(git rev-parse HEAD)" | tail -1)
  lastCommitTimestamp=$(echo "${lastCommitInfo}" | cut -d"|" -f2)
  if [ -z "${lastCommitTimestamp}" ] || [ ${lastCommitTimestamp} -lt ${staleTimestamp} ]; then
    branchesToDelete+=" ${branch#origin/}"
  elif [ ${lastCommitTimestamp} -lt ${maybeStaleTimestamp} ]; then
    branchesToReview+="${branch#origin/}|${lastCommitInfo}"$'\n'
  fi
  echo -n .
done
echo # for new line after dots
if [ -n "${branchesToDelete}" ]; then
  echo -e "\033[0;32mDeleting stale branches...\033[0m"
  git push $dryRunOpt --delete origin ${branchesToDelete}
else
  echo -e "\033[0;32mNo stale branches...\033[0m"
fi
echo -e "\033[1;33mBranches to review (may be stale):\033[0m"
echo "${branchesToReview}" | sort -t"|" -k5 | awk -F"|" 'NF {print $5 " changed branch \"" $1 "\" in project \"'${PWD##*/}'\" " $4}'
