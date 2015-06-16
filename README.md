# Kutti Ndk Debugger package

This is a visual android ndk debugger for atom.io

This is an alpha quality release.

The debugger needs a custom ndk-gdb script with --interpreter=mi2 added to the argument list of gdb

To create the custom script follow these steps:
  1. Create a copy of the orinigal script name it ndk-gdb-atom
  2. Replace "$GDBCLIENT -x \`native_path $GDBSETUP\`"  line in ndk-gdb-atom file by  "$GDBCLIENT `-interpreter=mi2` -x \`native_path $GDBSETUP\`" 
  3. Add execute permissions for the newly created script eg. chmod +x ndk-gdb-atom
  
Please mention the path of  `ndk-gdb-atom` and android `adb` in the package settings.


## TO DO

* Add `watch` view to display variable value.
* Add `stack frame` view  
