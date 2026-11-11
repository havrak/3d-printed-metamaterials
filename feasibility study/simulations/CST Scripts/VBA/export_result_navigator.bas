' --- Result Navigator export -------------------------------------------------
' Exports the CST result-navigator table (right-click on the Parameter Sweep /
' run folder -> Export -> Save as CSV) directly to the shared export folder.
'
' Writes in CST's native navigator format, which is what csv_add_columns.py,
' MATLAB/load_touchstone_dir.m and surrogate/data processor/metadata.py expect:
'
'     <TAB separated> , every field double quoted, no header line beyond the
'     one CST produces, Run ID carried in the " 3D Run ID" column.
'
' Two things this macro deliberately does NOT do:
'   * it does not add constant columns - that stays in csv_add_columns.py so a
'     single mechanism owns the annotation, and chunked runs behave the same as
'     unsplit runs;
'   * it does not modify the .cst project.
'
' USAGE
'   1. Open the project that has just finished a Parameter Sweep.
'   2. Macro -> Run Macro -> this file.
'   Output:  <exportPath>\result_navigator.csv
'   or, with the optional tag argument:  result_navigator_<tag>.csv
'   Pass a tag when running chunks so the per-chunk navigators do not clobber
'   each other:   Call MainWithTag("chunk_003")
'
' NOTE ON MISSING COLUMNS
'   CST only lists parameters that actually vary between the runs of one
'   sweep. A chunk that happens to hold a single value of some parameter will
'   therefore be missing that column. That is expected; run csv_add_columns.py
'   afterwards (see python/merge_navigators.py for the chunk-aware variant).

Option Explicit

' --- Configuration -----------------------------------------------------------
' Shared output folder. Touchstone files and result_navigator.csv live together
' so that each export directory is self-contained for the data processors.
Private Const EXPORT_PATH As String = _
    "C:\Users\kryst\Documents\Thesis\feasibility study\simulations\data\export\"

' Optional: name of the Parameter Sweep item in the navigation tree.
' Leave empty to auto-detect the first sweep/run folder found.
Private Const SWEEP_TREE_PATH As String = ""
' -----------------------------------------------------------------------------


Sub Main()
    ExportNavigator ""
End Sub


Sub MainWithTag(tag As String)
    ExportNavigator tag
End Sub


' ExportNavigator  Locate the result-navigator table, export it to CSV.
'   tag  optional suffix for the file name ("" -> result_navigator.csv)
Private Sub ExportNavigator(tag As String)

    Dim treePath As String
    Dim outPath As String
    Dim csvLines As Variant

    If Dir(EXPORT_PATH, vbDirectory) = "" Then
        ReportInformationToWindow "ERROR: export folder does not exist: " & EXPORT_PATH
        Exit Sub
    End If

    treePath = ResolveNavigatorTreeItem()
    If treePath = "" Then
        ReportInformationToWindow "ERROR: no Parameter Sweep / run folder with an " & _
                                   "exportable parameter table was found."
        Exit Sub
    End If

    ReportInformationToWindow "Result navigator: reading table of '" & treePath & "'"

    On Error GoTo ExportFailed
    csvLines = ResultTree.GetResultFromTreeItem(treePath, "3D:RunID:0")
    On Error GoTo 0

    If IsEmpty(csvLines) Then
        ' Not every CST version exposes the navigator through Resulttree.
        ' Fall back to the plain table export of the same tree item.
        ReportInformationToWindow "Resulttree returned nothing, falling back to " & _
                                   "ASCII table export."
        outPath = MakeOutPath(tag)
        DeleteIfExists outPath
        SelectTreeItem treePath
        AsciiExport outPath
        ReportInformationToWindow "SUCCESS: wrote " & outPath
        Exit Sub
    End If

    outPath = MakeOutPath(tag)
    DeleteIfExists outPath

    If WriteNavigatorCsv(csvLines, outPath) Then
        ReportInformationToWindow "SUCCESS: wrote " & outPath
    Else
        ReportInformationToWindow "ERROR: could not write " & outPath
    End If
    Exit Sub

ExportFailed:
    ReportInformationToWindow "ERROR: navigator read failed for '" & treePath & _
                               "': " & Err.Description & _
                               " (set SWEEP_TREE_PATH explicitly in this macro)"
End Sub


' ResolveNavigatorTreeItem  Return the tree path holding the parameter table.
'   Preferred: an explicit path from SWEEP_TREE_PATH.
'   Otherwise: the sweep/run folder; CST stores the navigator on the folder that
'   owns the parameter runs, which is what right-click -> Export uses.
Private Function ResolveNavigatorTreeItem() As String

    Dim sweeps As Variant
    Dim k As Long

    If Len(SWEEP_TREE_PATH) > 0 Then
        If Trim(SWEEP_TREE_PATH) <> "" Then
            ResolveNavigatorTreeItem = SWEEP_TREE_PATH
            Exit Function
        End If
    End If

    ' Ask CST for the parameter sweeps it knows about, newest first.
    On Error Resume Next
    sweeps = Solver.GetParameterSweeps()
    On Error GoTo 0

    If Not IsEmpty(sweeps) Then
        For k = LBound(sweeps) To UBound(sweeps)
            If Len(CStr(sweeps(k))) > 0 Then
                ResolveNavigatorTreeItem = "Solver\" & CStr(sweeps(k))
                Exit Function
            End If
        Next k
    End If

    ' Last resort: the default single-sweep name.
    ResolveNavigatorTreeItem = "Solver\Sweep1"
End Function


' MakeOutPath  Build the output file name, honouring the optional tag.
Private Function MakeOutPath(tag As String) As String
    Dim safeTag As String
    safeTag = Trim(tag)
    If Len(safeTag) = 0 Then
        MakeOutPath = EXPORT_PATH & "result_navigator.csv"
    Else
        MakeOutPath = EXPORT_PATH & "result_navigator_" & SanitizeName(safeTag) & ".csv"
    End If
End Function


' SanitizeName  Strip characters that are illegal in Windows file names.
Private Function SanitizeName(s As String) As String
    Dim bad As Variant, k As Long
    bad = Array("\", "/", ":", "*", "?", """", "<", ">", "|", " ")
    For k = LBound(bad) To UBound(bad)
        s = Replace(s, CStr(bad(k)), "_")
    Next k
    SanitizeName = s
End Function


Private Sub DeleteIfExists(path As String)
    On Error Resume Next
    If Len(Dir(path)) > 0 Then Kill path
    On Error GoTo 0
End Sub


' WriteNavigatorCsv  Write the two-dimensional table CST hands back.
'   CST returns a 0-based 2D array of Strings. We write it as TAB separated,
'   every field double quoted, matching the native navigator export so the
'   downstream parsers keep working unchanged.
Private Function WriteNavigatorCsv(table As Variant, path As String) As Boolean

    Dim f As Integer
    Dim r As Long, c As Long
    Dim nRows As Long, nCols As Long
    Dim rowStr As String
    Dim field As String

    On Error GoTo Failed

    nRows = UBound(table, 1) - LBound(table, 1) + 1
    nCols = UBound(table, 2) - LBound(table, 2) + 1

    If nRows < 2 Or nCols < 1 Then
        WriteNavigatorCsv = False
        Exit Function
    End If

    f = FreeFile
    Open path For Output As #f

    For r = LBound(table, 1) To UBound(table, 1)
        rowStr = ""
        For c = LBound(table, 2) To UBound(table, 2)
            field = CStr(table(r, c))
            field = Replace(field, """", "")
            If c > LBound(table, 2) Then rowStr = rowStr & vbTab
            rowStr = rowStr & """" & field & """"
        Next c
        Print #f, rowStr
    Next r

    Close #f
    WriteNavigatorCsv = True
    Exit Function

Failed:
    On Error Resume Next
    Close #f
    On Error GoTo 0
    WriteNavigatorCsv = False
End Function


' -----------------------------------------------------------------------------
' Control plane for the Python driver.
'
' The driver rewrites the two marker lines below before each launch, so the
' same .bas file can serve every chunk. Do not reorder the markers.
' --- DRIVER_CONTROL_BEGIN ---
' EXPORT_PATH and SWEEP_TREE_PATH are set above; the driver substitutes the
' literal strings between the INJECT markers of the wrapper macro instead.
' --- DRIVER_CONTROL_END ---
