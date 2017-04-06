Set objShell = CreateObject("WScript.Shell")
Set objFS = CreateObject("Scripting.FileSystemObject")

' Format: "v" + Major + "." + Minor + "." + Patch + "-" + Distance + "-" + Hash
gitRev = "v0.0.0-0-000000"

hasGitResult = objShell.Run("where git", 0, True)
If hasGitResult = 0 Then
  Set gitResult = objShell.Exec("git describe --tags")
  outp = gitResult.StdOut.ReadAll()

  ' Trim leading and trailing whitespaces and newlines (note: Trim function 
  ' would only care about spaces)
  Set regex = New RegExp
  regex.Global = True
  regex.Pattern = "^\s+|\s+$"
  gitRev = regex.Replace(outp, "")
End If

' Let's parse version into sections and extract them
Set ver_re = New RegExp
ver_re.Pattern = "^v(\d+)\.(\d+)\.(\d+)-(\d+)-(\w+)$"
Set matches = ver_re.Execute(gitRev)
ver_major = matches(0).Submatches(0)
ver_minor = matches(0).Submatches(1)
ver_patch = matches(0).Submatches(2)
ver_distance = matches(0).Submatches(3)
ver_hash     = matches(0).Submatches(4)

Set svnrev = objFS.CreateTextFile("svnrev.h")
svnrev.WriteLine("static const char* GIT_REVISION = """ & gitRev & """;")
svnrev.WriteLine("static const char* GIT_DISTANCE = " & ver_distance & ";")
svnrev.WriteLine("static const char* GIT_HASH     = """ & ver_hash & """;")
svnrev.WriteLine("")
svnrev.WriteLine("// Major * 100'000'000 + Minor * 1'000'000 + Patch * 10000 + GitDistance")
svnrev.WriteLine("static const int   SVN_REV      = " & (ver_major * 100000000 + ver_minor * 1000000 + ver_patch * 10000 + ver_distance) & ";")
svnrev.WriteLine("")
svnrev.WriteLine("#include ""starcraftver.h""")
svnrev.WriteLine("")
svnrev.Close()
