#!/bin/bash
# Set JAVA_HOME
JAVA_HOME=/opt/java/openjdk
# Run Java with the correct path
$JAVA_HOME/bin/java -Xms128m -Xmx256m -Djava.awt.headless=true -jar ./PaDEL-Descriptor/PaDEL-Descriptor.jar "$@"
