MODULE M_PICK
    
     PROC rPick()
!*** 1. Robot request data cam    
     SetDO DOPLC_Pick_Data_Req,1; 
    
!*** 2. Robot at pos take cam        
     MoveL psb_Pick, vMainFast, fine, tGrip\WObj:=wobj0;
     WaitDI DIPLC_Pick_Wr_Data_Finish,1\Visualize\Header:="Waiting for signal"\Message:="Wait write data Done"\Icon:=iconInfo;
     SetDO DOPLC_Pick_Data_Req,0;
     ClkReset clock1;
     ClkStart clock1;
!*** 3. Robot update positine pick
GT_ReadAgain:        
        wLoadin.oframe.trans.x:=0;
        !wLoadin.oframe.trans.y:=0;
        posCAM.x:=AInput(AIPLC_X_Pos);
        posCAM.y:=AInput(AIPLC_y_Pos);
        posCAM.z:=AInput(AIPLC_z_Pos);
               IF  (posCAM.x < 80) THEN     
                TPWrite "Data position from PLC Error";
                GOTO GT_ReadAgain;
               ELSE
                ! TPErase;  
               ENDIF
               IF posCAM.z > 350 THEN
                  posCAM.z := 350; 
               ENDIF
               IF posCAM.x < 110 THEN
                  posCAM.x := 130;
               ENDIF
        wLoadin.oframe.trans.x:=(posCAM.x);
!*** 4. Robot wait PLC order pick       
        TPWrite "X ="\Num:= posCAM.x;
        TPWrite "Y ="\Num:= posCAM.Y;
        TPWrite "Z ="\Num:= posCAM.Z;
        TPWrite "wLoadin ="\Pos:=wLoadin.oframe.trans;
        SetDO DOPLC_Pick_Data_Received,1;       
        WaitDI DIPLC_Pick_RubberPick_Req,1\Visualize\Header:="Waiting for signal"\Message:="Wait write data Done"\Icon:=iconInfo;
        SetDO DOPLC_Pick_Data_Received,0; 
!*** 5. Robot to pick pos              
        MoveL Offs(pPick,0,0,nPrePick),vMedium,z10,tGrip\WObj:=wLoadin;
!*** 6. Robot at pick pos ready
        MoveL Offs (pPick,0,0,0),vMedium,fine,tGrip\WObj:=wLoadin;
        SetDO DOPLC_Pick_Pos_Ready,1; 
!*** 7. wait Clamp completed
        WaitDI DIPLC_Pick_GripVac_Comp,1\Visualize\Header:="Waiting for signal"\Message:="Wait write data Done"\Icon:=iconInfo;
        SetDO DOPLC_Pick_Pos_Ready,0;
        MoveL psb_Pick, vMainFast, fine, tGrip\WObj:=wobj0;
!*** 8. Robot at pick standby         
        PulseDO \PLength:=1,DOPLC_Pick_ZaxisUp_Ready; 
        WaitUntil DIPLC_SPRAY_NO1_2_PLACE_REQ = 1 OR DIPLC_SPRAY_NO1_1_PLACE_REQ = 1;
    ENDPROC
    
ENDMODULE