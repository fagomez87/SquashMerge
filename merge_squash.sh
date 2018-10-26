#!/bin/bash
: ${1?Argument 1 "baseBranch" is not present}


baseBranch="$1"
commitMessage="$2"
branchName=$(git rev-parse --abbrev-ref HEAD)
branchForSquash=$branchName"_for_merge_squash";
branchPrefixRegex="[A-Z]+-[0-9]+.*"
prefixForCommitMessageRegex="[A-Z]+-[0-9]+"
isHubInstalled=$(command -v hub)


if ! [[ "$branchName" =~ $branchPrefixRegex ]]; then
    echo "Current branch $branchName is not squasheable"
    exit
fi 

if [[ $branchName =~ $prefixForCommitMessageRegex ]]; then
    prefix=$BASH_REMATCH
    commitMessage="$prefix:$commitMessage"
fi

if [[ -z $commitMessage ]]; then
echo "Argument 2 commitMessage cannot be empty"
exit
fi

echo "Checking if $baseBranch exists in remote repository"
if [[ -z $(git ls-remote --heads origin refs/heads/$baseBranch) ]]; then
echo "Selected branch $baseBranch doesn't exists in remote repository."
exit
fi

echo "Checking if $branchName exists in remote repository"

if [[ -z $(git ls-remote --heads origin refs/heads/$branchName) ]]; then
echo "Selected branch $branchName doesn't exists in remote repository. Push $branchName before continue. Use 'git push origin $branchName'"
exit
fi

if [[ -z "$isHubInstalled" ]] 
	then
	echo "You dont have installed hub. Please install it"
	exit
fi

if ! [[ -z $(git diff origin/$branchName) ]]; then
echo "You have changes uncommited to your remote repository. Use 'git diff origin/$branchName' to see uncommited changes"
exit
fi


if ! [[ -z $(git status --porcelain) ]]; then
echo "You have not tracking files from local repository. Use 'git status' to see not tracking files."
exit
fi




echo "Pulling from $baseBranch"
git pull origin $baseBranch


if ! [[ -z $(git diff --name-only --diff-filter=U) ]]; then
echo "You have merge conflicts. Resolve it before continue with squash merge"
exit
fi


echo "Pushing merge prepare from $baseBranch to $branchName"
git push origin $branchName




echo "Checkout to $baseBranch"
git checkout $baseBranch

echo "Creating $branchForSquash"
git checkout -b $branchForSquash

echo "Squashing commits from $branchName"
git merge --squash $branchName > /dev/null

echo "Commiting squash"
git commit -S -m "$commitMessage" > /dev/null

echo "Pushing to $branchForSquash"
git push origin $branchForSquash

echo "Creating pull request"
hub pull-request -b $baseBranch -h $branchForSquash -m "$commitMessage"


echo "Do you want to delete $branchName branch from repository?"
read -p "y/n? " -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo
	$(git push origin --delete $branchName)
fi


exit
