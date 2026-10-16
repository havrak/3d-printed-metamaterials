' --- Export Script (No renormalizaiton)
' So CST studios export feature is a little finicky and can stall on large exports.
' And when it stalls, it stalls so bad, that I need to restart entire CST Studio.
' Now this was quite a pain in the ass, and I've lost hundreds of runs of simulations
' trying to figure out how to fix it - until this script got created fix doesn't use
' the broken touchstonen export implementation.
'
' This script implements both custom export to touchstone files without doing any
' normalization. However, port impedance values are stored in the header.

Sub Main()
    Dim exportPath As String
    Dim runIDs As Variant
    Dim S11_obj As Object, S21_obj As Object, S12_obj As Object, S22_obj As Object
    Dim Zc1_obj As Object, Zc2_obj As Object
    Dim fileNum As Integer, nFreqs As Integer, freqIdx As Integer, idIdx As Integer
    Dim lineStr As String, currentRunID As String, safeID As String
    Dim exportCount As Integer

    Dim zc1_val As String, zc2_val As String

    ' Variables for Magnitude/Phase conversion
    Dim s11r As Double, s11i As Double, m11 As Double, p11 As Double
    Dim s21r As Double, s21i As Double, m21 As Double, p21 As Double
    Dim s12r As Double, s12i As Double, m12 As Double, p12 As Double
    Dim s22r As Double, s22i As Double, m22 As Double, p22 As Double

    ' --- Configuration ---
    exportPath = "C:\Users\kryst\Documents\Thesis\export\"
    ' ---------------------

    exportCount = 0
    runIDs = ResultTree.GetResultIDsFromTreeItem("1D Results\S-Parameters\SZmax(1),Zmax(1)")

    If IsEmpty(runIDs) Then
        ReportInformationToWindow "ERROR: GetResultIDsFromTreeItem returned empty."
        Exit Sub
    End If

    For idIdx = LBound(runIDs) To UBound(runIDs)
        currentRunID = runIDs(idIdx)

        If currentRunID <> "3D:RunID:0" Then
            Set S11_obj = ResultTree.GetResultFromTreeItem("1D Results\S-Parameters\SZmax(1),Zmax(1)", currentRunID)
            Set S21_obj = ResultTree.GetResultFromTreeItem("1D Results\S-Parameters\SZmax(2),Zmax(1)", currentRunID)
            Set S12_obj = ResultTree.GetResultFromTreeItem("1D Results\S-Parameters\SZmax(1),Zmax(2)", currentRunID)
            Set S22_obj = ResultTree.GetResultFromTreeItem("1D Results\S-Parameters\SZmax(2),Zmax(2)", currentRunID)

            ' Fetch wave impedance objects
            Set Zc1_obj = ResultTree.GetResultFromTreeItem("1D Results\Port Information\Wave Impedance\Zmax(1)", currentRunID)
            Set Zc2_obj = ResultTree.GetResultFromTreeItem("1D Results\Port Information\Wave Impedance\Zmax(2)", currentRunID)

            If Not S11_obj Is Nothing And Not S22_obj Is Nothing Then
                safeID = Replace(currentRunID, " ", "_")
                safeID = Replace(safeID, ":", "_")

                ' Extract the real part of the wave impedance at the first frequency point for the header
                If Not Zc1_obj Is Nothing Then
                    zc1_val = CStr(Zc1_obj.GetYRe(0))
                Else
                    zc1_val = "376.7303136"
                End If

                If Not Zc2_obj Is Nothing Then
                    zc2_val = CStr(Zc2_obj.GetYRe(0))
                Else
                    zc2_val = "376.7303136"
                End If

                fileNum = FreeFile
                On Error GoTo FileWriteError

                Open exportPath & "Export_Generalized_" & safeID & ".s2p" For Output As #fileNum

                ' Write Touchstone comment lines with the extracted impedance values
                Print #fileNum, "! Wave Impedance Zmax(1) = " & zc1_val & " Ohms"
                Print #fileNum, "! Wave Impedance Zmax(2) = " & zc2_val & " Ohms"
                Print #fileNum, "# GHz S MA R 50.0"

                nFreqs = S11_obj.GetN()
                For freqIdx = 0 To nFreqs - 1
                    ' Fetch Raw Real/Imaginary
                    s11r = S11_obj.GetYRe(freqIdx): s11i = S11_obj.GetYIm(freqIdx)
                    s21r = S21_obj.GetYRe(freqIdx): s21i = S21_obj.GetYIm(freqIdx)
                    s12r = S12_obj.GetYRe(freqIdx): s12i = S12_obj.GetYIm(freqIdx)
                    s22r = S22_obj.GetYRe(freqIdx): s22i = S22_obj.GetYIm(freqIdx)

                    ' Convert directly to Magnitude and Phase
                    m11 = GetMag(s11r, s11i): p11 = GetPhase(s11r, s11i)
                    m21 = GetMag(s21r, s21i): p21 = GetPhase(s21r, s21i)
                    m12 = GetMag(s12r, s12i): p12 = GetPhase(s12r, s12i)
                    m22 = GetMag(s22r, s22i): p22 = GetPhase(s22r, s22i)

                    lineStr = Trim(Str(S11_obj.GetX(freqIdx))) & " " & _
                              Trim(Str(m11)) & " " & Trim(Str(p11)) & " " & _
                              Trim(Str(m21)) & " " & Trim(Str(p21)) & " " & _
                              Trim(Str(m12)) & " " & Trim(Str(p12)) & " " & _
                              Trim(Str(m22)) & " " & Trim(Str(p22))

                    Print #fileNum, lineStr
                Next freqIdx

                Close #fileNum
                On Error GoTo 0
                exportCount = exportCount + 1
            End If

            Set S11_obj = Nothing: Set S21_obj = Nothing
            Set S12_obj = Nothing: Set S22_obj = Nothing
            Set Zc1_obj = Nothing: Set Zc2_obj = Nothing
        End If

        GoTo NextIteration

FileWriteError:
        Err.Clear
        Resume NextIteration
NextIteration:
    Next idIdx

    If exportCount > 0 Then
        ReportInformationToWindow "SUCCESS: Extracted " & CStr(exportCount) & " Generalized MA files with Wave Impedance headers."
    End If
End Sub

Function GetMag(re As Double, im As Double) As Double
    GetMag = Sqr(re * re + im * im)
End Function

Function GetPhase(re As Double, im As Double) As Double
    Dim p As Double
    If re = 0 Then
        If im > 0 Then GetPhase = 90.0 Else If im < 0 Then GetPhase = -90.0 Else GetPhase = 0.0
    Else
        p = Atn(im / re) * 180.0 / 3.141592653589793
        If re < 0 And im >= 0 Then p = p + 180.0
        If re < 0 And im < 0 Then p = p - 180.0
        GetPhase = p
    End If
End Function