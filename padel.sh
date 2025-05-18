#!/bin/bash
# Use JAVA_HOME set by set_java_home.sh
$JAVA_HOME/bin/java -Xms128m -Xmx256m -Djava.awt.headless=true -jar ./PaDEL-Descriptor/PaDEL-Descriptor.jar "$@"
