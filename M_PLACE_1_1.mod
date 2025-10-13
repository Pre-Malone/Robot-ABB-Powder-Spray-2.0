MODULE M_PLACE_1_1
    
    PROC rPlace1_1()
        
!*** 1. Robot at place standby
        WaitDI DIPLC_Place1_1_Clear,1\Visualize\Header:="Waiting for STATION PLACING 1.1 CLEAR"\Message:="Wait write data Done"\Icon:=iconInfo;
        !MoveL psb_Place, vMainFast, z100, tGrip\WObj:=wobj0;
!*** 2. Robot go to place       
        MoveL offs(pPlace_1_1,0,0,nPrePlace), vMainFast, z50, tGrip\WObj:=WLoadOut1;
        MoveL pPlace_1_1, vMainFast, fine, tGrip\WObj:=WLoadOut1;
!*** 3. Robot to PLC Gripper open        
        SetDO DOPLC_PlaceFinished_1_1,1; 
        WaitDI DIPLC_Place_GripSafe_Comp,1\Visualize\Header:="Waiting for signal"\Message:="Wait write data Done"\Icon:=iconInfo; 
!*** 4. Robot move up    
        MoveL Offs(pPlace_1_1,0,0,nPostPlace), vMainFast, fine, tGrip\WObj:=WLoadOut1;
!*** 5. Robot at place safe standby              
        MoveL psb_Place, vMainFast, fine, tGrip\WObj:=wobj0;
!*** 6. Robot to PLC Gripper safe zone finished         
        PulseDO \PLength:= 0.5,DOPLC_Place_PowPos_Ready; 
        WaitDI DIPLC_Place_Starting,1\Visualize\Header:="Waiting for signal"\Message:="Wait write data Done"\Icon:=iconInfo; 
        SetDO DOPLC_PlaceFinished_1_1,0;        
        PulseDo \PLength:= 0.5,DOPLC_Robot_Acknowlege;
        
    ENDPROC
    
ENDMODULE