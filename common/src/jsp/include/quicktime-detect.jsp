<script type="text/javascript" src="../include/AC_QuickTime.js"></script>

<script type="text/javascript">
     var haveqt = false;
</script>

<script type="text/vbscript">
On Error Resume Next
Set theObject = CreateObject("QuickTimeCheckObject.QuickTimeCheck.1")
On Error goto 0

If IsObject(theObject) Then
     If theObject.IsQuickTimeAvailable(0) Then
          haveqt = true
     End If
End If
</script>

<script type="text/javascript">
     if (navigator.plugins) {
          for (i=0; i < navigator.plugins.length; i++ ) {
               if (navigator.plugins[i].name.indexOf("QuickTime") >= 0)
                    { haveqt = true; }
            }
        }
</script>