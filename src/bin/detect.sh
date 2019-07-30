#!/bin/bash

if ls /media 2>&1 > /dev/null; then
    echo "Access to removable media already granted."
else
	echo "You need to run \"snap connect tesscam:removable-media\" grant this snap access to removable media."
fi
