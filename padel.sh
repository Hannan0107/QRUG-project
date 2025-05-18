#!/bin/bash
# Use JAVA_HOME from the sourced script
$JAVA_HOME/bin/java -Xms128m -Xmx256m -Djava.awt.headless=true -jar ./PaDEL-Descriptor/PaDEL-Descriptor.jar "$@"
