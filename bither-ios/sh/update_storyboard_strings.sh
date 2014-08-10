#!/bin/sh
#
# update_storyboard_strings.sh - automatically extract translatable strings from storyboards and update strings files
# Based on http://forums.macrumors.com/showpost.php?p=16060008&postcount=4 by mikezang

storyboardExt=".storyboard"
stringsExt=".strings"
newStringsExt=".strings.new"
oldStringsExt=".strings.old"
localeDirExt=".lproj"

# Find storyboard file full path inside project folder
for storyboardPath in `find . -name "*$storyboardExt" -print`
do
    # Get Base strings file full path
    baseStringsPath=$(echo "$storyboardPath" | sed "s/$storyboardExt/$stringsExt/")

    # Create base strings file if it doesn't exist
    if ! [ -f $baseStringsPath ]; then
      touch -r $storyboardPath $baseStringsPath
      # Make base strings file older than the storyboard file
      touch -A -01 $baseStringsPath
    fi
    
    # Create strings file only when storyboard file newer
    if find $storyboardPath -prune -newer $baseStringsPath -print | grep -q .; then
        # Get storyboard file name and folder 
        storyboardFile=$(basename "$storyboardPath")
        storyboardDir=$(dirname "$storyboardPath")

        # Get New Base strings file full path and strings file name
        newBaseStringsPath=$(echo "$storyboardPath" | sed "s/$storyboardExt/$newStringsExt/")
        stringsFile=$(basename "$baseStringsPath")
        ibtool --export-strings-file $newBaseStringsPath $storyboardPath
        
        # ibtool sometimes fails for unknown reasons with "Interface Builder could not open 
        # the document XXX because it does not exist."
        # (maybe because Xcode is writing to the file at the same time?)
        # In that case, abort the script.
        if [[ $? -ne 0 ]] ; then
            echo "Exiting due to ibtool error. Please run `killall -9 ibtoold` and try again."
            exit 1
        fi
        
        # Only run iconv if $newBaseStringsPath exists to avoid overwriting existing
        if [ -f $newBaseStringsPath ]; then
          iconv -f UTF-16 -t UTF-8 $newBaseStringsPath > $baseStringsPath
          rm $newBaseStringsPath
        fi

        # Get all locale strings folder 
        for localeStringsDir in `find . -name "*$localeDirExt" -print`
        do
            # Skip Base strings folder
            if [ $localeStringsDir != $storyboardDir ]; then
                localeStringsPath=$localeStringsDir/$stringsFile

                # Just copy base strings file on first time
                if [ ! -e $localeStringsPath ]; then
                    cp $baseStringsPath $localeStringsPath
                else
                    oldLocaleStringsPath=$(echo "$localeStringsPath" | sed "s/$stringsExt/$oldStringsExt/")
                    cp $localeStringsPath $oldLocaleStringsPath

                    # Merge baseStringsPath to localeStringsPath
                    awk 'NR == FNR && /^\/\*/ {x=$0; getline; a[x]=$0; next} /^\/\*/ {x=$0; print; getline; $0=a[x]?a[x]:$0; printf $0"\n\n"}' $oldLocaleStringsPath $baseStringsPath > $localeStringsPath

                    rm $oldLocaleStringsPath
                fi
            fi
        done
    else
        echo "$storyboardPath file not modified."
    fi
done