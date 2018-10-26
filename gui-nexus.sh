	#!/bin/bash

	#nexusSearchByGroupId=$(curl -s -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://nexus.despegar.it/nexus/service/local/lucene/search?g=com.despegar.cfa.*&collapseresults=true)
	#groupIds=$(cat <<< $nexusSearchByGroupId | jq '.data[].groupId' | tr ' ' '\n' | sort -u | tr '\n' ' ')
	groupIds=("com.despegar.cfa.pigeon com.despegar.cfa.mercurio com.despegar.cfa.tinder com.despegar.cfa.ladon com.despegar.cfa.myo com.despegar.cfa.dove")
	   
	IFS=' ' read -r -a groupArray <<< "$groupIds"
	echo Grupos  "${groupArray[*]}"

	menuLength=${#groupArray[@]}


	groupMenuNumber=$(whiptail --title "Nexus Cleaner" --menu "Selecciona un grupo" 30 80 15 $(for (( i=1; i<${menuLength}+1; i++ ));
	do
		echo "$i" "${groupArray[$i-1]}"
	done
	) 3>&1 1>&2 2>&3
	)
	 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
	    echo "Has seleccionado la opcion:" $groupMenuNumber
	else
	    echo "Seleccionaste Cancelar."
	    exit;
	fi 

	selectedGroup=${groupArray[groupMenuNumber-1]};

	echo Ha seleccionado el grupo $selectedGroup

	nexusSearchByArtifactResponse=$(curl -s -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://nexus.despegar.it/nexus/service/local/lucene/search?g=$(echo $selectedGroup | tr -d '"'})&collapseresults=true&versionexpand=true)



	versions=$(cat <<< $nexusSearchByArtifactResponse | jq '.data[].version' | tr ' ' '\n' | sort -u | tr '\n' ' ')
	IFS=' ' read -r -a versionsArray <<< "$versions"
	versionsLength=${#versionsArray[@]}
	echo Versions:  "${versionsArray[*]}"



	artifactsIds=$(cat <<< $nexusSearchByArtifactResponse | jq '.data[].artifactId' | tr ' ' '\n' | sort -u | tr '\n' ' ')
	IFS=' ' read -r -a artifactArray <<< "$artifactsIds"
	artifactsLength=${#artifactArray[@]}
	echo Artifacts:  "${artifactArray[*]}"


	deleteModeMenu=$(whiptail --title "Nexus Cleaner" --menu "Seleccione las versiones a eliminar" 30 80 15  1 "Check"  2 "Rangos" 3>&1 1>&2 2>&3)

	exitstatus=$?

	if [ $deleteModeMenu = 1 ]; then

		checkedVersionsToDelete=$(whiptail --title "Nexus Cleaner" --checklist "Seleccione las versiones a borrar" 30 80 20 $(for (( i=1; i<${versionsLength}+1; i++ ));
			do
			echo  "$i" "${versionsArray[$i-1]}" OFF
			done
		) 3>&1 1>&2 2>&3
		)

		exitstatus=$?
		if [ $exitstatus = 0 ]; then

			IFS=' ' read -r -a versionsSelectedForDelete <<< "$checkedVersionsToDelete"
			selectedVersionsLength=${#versionsSelectedForDelete[@]}

		else	
	   	 echo "Seleccionaste Cancelar."
	   	 exit;
		fi 
		 	
	elif [ $deleteModeMenu = 2 ]; then

		description=""

	for (( i=1; i<${versionsLength}+1; i++ ));
			do
			description="$description $i ${versionsArray[$i-1]}"$'\n'
			done
		selectedRangesFromDelete=$(whiptail --title "Seleccione el indice de las versiones a borrar" --inputbox --scrolltext "${description}" 40 60 "Ej: 1-10,13,15-19" 3>&1 1>&2 2>&3)
		 
		exitstatus=$?
		if [ $exitstatus = 0 ]; then


			echo "Los rangos seleccionados son:" $selectedRangesFromDelete
			IFS=',' read -r -a selectedRangesArray <<< "$selectedRangesFromDelete"
			selectedRangesLength=${#selectedRangesArray[@]}

			regex="((^|)([0-9]+-[0-9]+)|[0-9]+)/g"

			for (( i=0; i<${selectedRangesLength}+1; i++ ));
			do
				if [[ $selectedRangesArray[$i] =~ $regex ]]; then
					whiptail --title "Nexus Cleaner" --msgbox "Los rangos especificados no cumple con la regex $regex" 8 78
					exit;
				fi
			done
			selectedRangesLength=${#selectedRangesArray[@]}
			echo length $selectedRangesLength
			versionsSelectedFromRange=""
			for (( i=0; i<${selectedRangesLength}+1; i++ ));
			do
				echo indice del array selected $i
				echo ${selectedRangesArray[i]}
				
				if [ $(grep "-" <<< ${selectedRangesArray[i]}) ];	then

					echo Es un rango

					IFS='-' read -r -a currentRange <<< ${selectedRangesArray[i]}

					echo Rango actual: ${currentRange[@]}

					echo ${currentRange[0]}
					echo ${currentRange[1]}

					
					for (( j=${currentRange[0]}; j<${currentRange[1]}+1; j++ ));
					do
						echo ${j}
						versionsSelectedFromRange="$versionsSelectedFromRange $j"
					done



				else
					echo Es un indice
					echo ${selectedRangesArray[i]}
					versionsSelectedFromRange="$versionsSelectedFromRange ${selectedRangesArray[i]}"



				fi
				IFS=' ' read -r -a versionsSelectedForDelete <<< "$versionsSelectedFromRange"
				selectedVersionsLength=${#versionsSelectedForDelete[@]}
				echo ${versionsSelectedForDelete[@]}

			done


		else
		    echo "Seleccionaste cancelar."
		fi
	fi







	for (( i=0; i<${selectedVersionsLength}; i++ ));
	do
			indice=$(echo ${versionsSelectedForDelete[i]} | tr -d '"')
			version=$(echo ${versionsArray[indice-1]} | tr -d '"')
			
			groupPath=$(echo ${selectedGroup//.//} | tr -d '"')

			echo Eliminando version: $version
			echo indice $indice


			for (( j=0; j<${artifactsLength}; j++ ));
			do

				artifactId=$(echo ${artifactArray[j]} | tr -d '"')
				echo http://nexus.despegar.it/nexus/service/local/repositories/releases/content/${groupPath}/${artifactId}/${version}/${artifactId}-${version}.jar

				#curl -X "DELETE" -s -o /dev/null http://nexus.despegar.it/nexus/service/local/repositories/releases/content/${groupPath}/${artifactId}/${version}/${artifactId}-${version}.jar
				#curl -X "DELETE" -s -o /dev/null http://nexus.despegar.it/nexus/service/local/repositories/releases/content/${groupPath}/${artifactId}/${version}/${artifactId}-${version}-sources.jar
				#curl -X "DELETE" -s -o /dev/null http://nexus.despegar.it/nexus/service/local/repositories/releases/content/${groupPath}/${artifactId}/${version}/${artifactId}-${version}.pom
			
			done
	done   