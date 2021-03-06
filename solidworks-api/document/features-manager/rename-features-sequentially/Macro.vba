Dim swApp As SldWorks.SldWorks
Dim swModel As SldWorks.ModelDoc2

Sub main()

    Set swApp = Application.SldWorks
    
    Set swModel = swApp.ActiveDoc
    
    Dim passedOrigin As Boolean
    passedOrigin = False
    
    If Not swModel Is Nothing Then
    
        Dim featNamesTable As Object
        Dim processedFeats As Collection
        
        Set featNamesTable = CreateObject("Scripting.Dictionary")
        Set processedFeats = New Collection
        
        featNamesTable.CompareMode = vbTextCompare 'case insensitive
        
        Dim swFeat As SldWorks.Feature
        Set swFeat = swModel.FirstFeature
        
        While Not swFeat Is Nothing
            
            If passedOrigin Then
            
                If Not Contains(processedFeats, swFeat) Then
                    processedFeats.Add swFeat
                    RenameFeature swFeat, featNamesTable
                End If
                
                Dim swSubFeat As SldWorks.Feature
                Set swSubFeat = swFeat.GetFirstSubFeature
                
                While Not swSubFeat Is Nothing
                    
                    If Not Contains(processedFeats, swSubFeat) Then
                        processedFeats.Add swSubFeat
                        RenameFeature swSubFeat, featNamesTable
                    End If
                    
                    Set swSubFeat = swSubFeat.GetNextSubFeature
                    
                Wend
            
            End If
            
            If swFeat.GetTypeName2() = "OriginProfileFeature" Then
                passedOrigin = True
            End If
            
            Set swFeat = swFeat.GetNextFeature
        Wend
        
    Else
        MsgBox "Please open model"
    End If

End Sub

Sub RenameFeature(feat As SldWorks.Feature, featNamesTable As Object)

    Dim regEx As Object
    Set regEx = CreateObject("VBScript.RegExp")
    
    regEx.Global = True
    regEx.IgnoreCase = True
    regEx.Pattern = "(.+?)(\d+)$"
    
    Dim regExMatches As Object
    Set regExMatches = regEx.Execute(feat.Name)
    
    If regExMatches.Count = 1 Then
        
        If regExMatches(0).SubMatches.Count = 2 Then
            
            Dim baseFeatName As String
            baseFeatName = regExMatches(0).SubMatches(0)
            
            Dim nextIndex As Integer
            
            If featNamesTable.Exists(baseFeatName) Then
                nextIndex = featNamesTable.item(baseFeatName) + 1
                featNamesTable.item(baseFeatName) = nextIndex
            Else
                nextIndex = 1
                featNamesTable.Add baseFeatName, nextIndex
            End If
            feat.Name = baseFeatName & nextIndex
        End If
    End If

End Sub

Function Contains(coll As Collection, item As Object) As Boolean
    
    Dim i As Integer
    
    For i = 1 To coll.Count
        If coll.item(i) Is item Then
            Contains = True
            Exit Function
        End If
    Next
    
    Contains = False
    
End Function