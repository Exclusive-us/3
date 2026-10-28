#!/usr/bin/env sh
APP_BASE_NAME=`basename "$0"`
# Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
DEFAULT_JVM_OPTS=""
# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
else
    JAVACMD="java"
fi
if [ ! -x "$JAVACMD" ] ; then
    echo "ERROR: JAVA_HOME is not defined and no 'java' command could be found in your PATH." 2>&1
    exit 1
fi
exec "$JAVACMD" $DEFAULT_JVM_OPTS -jar "$(dirname "$0")/gradle/wrapper/gradle-wrapper.jar" "$@"
