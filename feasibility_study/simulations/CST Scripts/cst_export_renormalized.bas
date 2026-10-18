' --- Export Script (With renormalizaiton)
' So CST studios export feature is a little finicky and can stall on large exports.
' And when it stalls, it stalls so bad, that I need to restart entire CST Studio.
' Now this was quite a pain in the ass, and I've lost hundreds of runs of simulations
' trying to figure out how to fix it - until this script got created fix doesn't use
' the broken touchstonen export implementation.
'
' This script implements both custom export to touchstone files and normalization of the
' floquet port to free space impedance (in case CST did something weird and didn't use 
' the free space impedance by default).

Sub Main()
    Dim exportPath As String
    Dim runIDs As Variant
    Dim S11_obj As Object, S21_obj As Object, S12_obj As Object, S22_obj As Object
    Dim Zc1_obj As Object, Zc2_obj As Object
    Dim fileNum As Integer, nFreqs As Integer, freqIdx As Integer, idIdx As Integer
    Dim lineStr As String, currentRunID As String, safeID As String
    Dim exportCount As Integer

    ' Complex variables
    Dim s11r As Double, s11i As Double, s21r As Double, s21i As Double
    Dim s12r As Double, s12i As Double, s22r As Double, s22i As Double
    Dim zc1r As Double, zc1i As Double, zc2r As Double, zc2i As Double

    Dim d11r As Double, d11i As Double, d22r As Double, d22i As Double
    Dim t1r As Double, t1i As Double, t2r As Double, t2i As Double
    Dim detSr As Double, detSi As Double
    Dim p11r As Double, p11i As Double, n11r As Double, n11i As Double
    Dim z11r As Double, z11i As Double
    Dim p22r As Double, p22i As Double, n22r As Double, n22i As Double
    Dim z22r As Double, z22i As Double

    Dim zc_geom As Double, num12r As Double, num12i As Double, z12r As Double, z12i As Double
    Dim num21r As Double, num21i As Double, z21r As Double, z21i As Double

    Dim zref As Double
    Dim z11pr As Double, z11pi As Double, z22pr As Double, z22pi As Double
    Dim tz1r As Double, tz1i As Double, tz2r As Double, tz2i As Double
    Dim detZr As Double, detZi As Double
    Dim z11mr As Double, z11mi As Double, ns11r As Double, ns11i As Double
    Dim s11_50r As Double, s11_50i As Double
    Dim z22mr As Double, z22mi As Double, ns22r As Double, ns22i As Double
    Dim s22_50r As Double, s22_50i As Double
    Dim ns12r As Double, ns12i As Double, s12_50r As Double, s12_50i As Double
    Dim ns21r As Double, ns21i As Double, s21_50r As Double, s21_50i As Double

    Dim m11 As Double, p11 As Double, m21 As Double, p21 As Double
    Dim m12 As Double, p12 As Double, m22 As Double, p22 As Double


    zref = 376.7303136

    ' --- Configuration ---
    exportPath = "C:\Users\kryst\Documents\Thesis\Data\Export\"
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

            ' Fetch wave impedance; falls back to free space impedance if CST did not save the Port Impedance tree node
            Set Zc1_obj = ResultTree.GetResultFromTreeItem("1D Results\Port Information\Wave Impedance\Zmax(1)", currentRunID)
            Set Zc2_obj = ResultTree.GetResultFromTreeItem("1D Results\Port Information\Wave Impedance\Zmax(2)", currentRunID)

            If Not S11_obj Is Nothing And Not S22_obj Is Nothing Then
                safeID = Replace(currentRunID, " ", "_")
                safeID = Replace(safeID, ":", "_")

                fileNum = FreeFile
                On Error GoTo FileWriteError
                Open exportPath & "Export_" & safeID & ".s2p" For Output As #fileNum
                Print #fileNum, "# GHz S MA R 50.0"

                nFreqs = S11_obj.GetN()
                For freqIdx = 0 To nFreqs - 1
                    s11r = S11_obj.GetYRe(freqIdx): s11i = S11_obj.GetYIm(freqIdx)
                    s21r = S21_obj.GetYRe(freqIdx): s21i = S21_obj.GetYIm(freqIdx)
                    s12r = S12_obj.GetYRe(freqIdx): s12i = S12_obj.GetYIm(freqIdx)
                    s22r = S22_obj.GetYRe(freqIdx): s22i = S22_obj.GetYIm(freqIdx)

                    If Not Zc1_obj Is Nothing Then
                        zc1r = Zc1_obj.GetYRe(freqIdx): zc1i = Zc1_obj.GetYIm(freqIdx)
                    Else
                        zc1r = 376.7303136: zc1i = 0
                    End If

                    If Not Zc2_obj Is Nothing Then
                        zc2r = Zc2_obj.GetYRe(freqIdx): zc2i = Zc2_obj.GetYIm(freqIdx)
                    Else
                        zc2r = 376.7303136: zc2i = 0
                    End If

                    ' 1. Convert Generalized S-matrix to Z-matrix
                    CSub 1, 0, s11r, s11i, d11r, d11i
                    CSub 1, 0, s22r, s22i, d22r, d22i
                    CMult d11r, d11i, d22r, d22i, t1r, t1i
                    CMult s12r, s12i, s21r, s21i, t2r, t2i
                    CSub t1r, t1i, t2r, t2i, detSr, detSi

                    CAdd 1, 0, s11r, s11i, p11r, p11i
                    CMult p11r, p11i, d22r, d22i, n11r, n11i
                    CAdd n11r, n11i, t2r, t2i, n11r, n11i
                    CMult zc1r, zc1i, n11r, n11i, n11r, n11i
                    CDiv n11r, n11i, detSr, detSi, z11r, z11i

                    CAdd 1, 0, s22r, s22i, p22r, p22i
                    CMult d11r, d11i, p22r, p22i, n22r, n22i
                    CAdd n22r, n22i, t2r, t2i, n22r, n22i
                    CMult zc2r, zc2i, n22r, n22i, n22r, n22i
                    CDiv n22r, n22i, detSr, detSi, z22r, z22i

                    zc_geom = Sqr(Sqr(zc1r * zc1r + zc1i * zc1i) * Sqr(zc2r * zc2r + zc2i * zc2i))

                    CMult 2 * zc_geom, 0, s12r, s12i, num12r, num12i
                    CDiv num12r, num12i, detSr, detSi, z12r, z12i

                    CMult 2 * zc_geom, 0, s21r, s21i, num21r, num21i
                    CDiv num21r, num21i, detSr, detSi, z21r, z21i

                    ' 2. Convert Z-matrix to Renormalized 50 Ohm S-matrix
                    CAdd z11r, z11i, zref, 0, z11pr, z11pi
                    CAdd z22r, z22i, zref, 0, z22pr, z22pi
                    CMult z11pr, z11pi, z22pr, z22pi, tz1r, tz1i
                    CMult z12r, z12i, z21r, z21i, tz2r, tz2i
                    CSub tz1r, tz1i, tz2r, tz2i, detZr, detZi

                    CSub z11r, z11i, zref, 0, z11mr, z11mi
                    CMult z11mr, z11mi, z22pr, z22pi, ns11r, ns11i
                    CSub ns11r, ns11i, tz2r, tz2i, ns11r, ns11i
                    CDiv ns11r, ns11i, detZr, detZi, s11_50r, s11_50i

                    CSub z22r, z22i, zref, 0, z22mr, z22mi
                    CMult z11pr, z11pi, z22mr, z22mi, ns22r, ns22i
                    CSub ns22r, ns22i, tz2r, tz2i, ns22r, ns22i
                    CDiv ns22r, ns22i, detZr, detZi, s22_50r, s22_50i

                    CMult 2 * zref, 0, z12r, z12i, ns12r, ns12i
                    CDiv ns12r, ns12i, detZr, detZi, s12_50r, s12_50i

                    CMult 2 * zref, 0, z21r, z21i, ns21r, ns21i
                    CDiv ns21r, ns21i, detZr, detZi, s21_50r, s21_50i

                    ' 3. Calculate final Magnitude and Phase
                    m11 = GetMag(s11_50r, s11_50i): p11 = GetPhase(s11_50r, s11_50i)
                    m21 = GetMag(s21_50r, s21_50i): p21 = GetPhase(s21_50r, s21_50i)
                    m12 = GetMag(s12_50r, s12_50i): p12 = GetPhase(s12_50r, s12_50i)
                    m22 = GetMag(s22_50r, s22_50i): p22 = GetPhase(s22_50r, s22_50i)

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
        ReportInformationToWindow "SUCCESS: Extracted " & CStr(exportCount) & " Renormalized 50 Ohm files."
    End If
End Sub

' Complex Math Operations
Sub CAdd(r1 As Double, i1 As Double, r2 As Double, i2 As Double, ByRef ro As Double, ByRef io As Double)
    ro = r1 + r2
    io = i1 + i2
End Sub
Sub CSub(r1 As Double, i1 As Double, r2 As Double, i2 As Double, ByRef ro As Double, ByRef io As Double)
    ro = r1 - r2
    io = i1 - i2
End Sub
Sub CMult(r1 As Double, i1 As Double, r2 As Double, i2 As Double, ByRef ro As Double, ByRef io As Double)
    ro = r1 * r2 - i1 * i2
    io = r1 * i2 + i1 * r2
End Sub
Sub CDiv(r1 As Double, i1 As Double, r2 As Double, i2 As Double, ByRef ro As Double, ByRef io As Double)
    Dim den As Double
    den = r2 * r2 + i2 * i2
    If den = 0 Then den = 1e-20
    ro = (r1 * r2 + i1 * i2) / den
    io = (i1 * r2 - r1 * i2) / den
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