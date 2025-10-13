MODULE M_PLACE_1_2
  
   PROC rPlace1_2()
        
!*** 1. Robot at place standby
        WaitDI DIPLC_Place1_2_Clear,1\Visualize\Header:="Waiting for STATION PLACING 1.2 CLEAR"\Message:="Wait write data Done"\Icon:=iconInfo;
        !MoveL psb_Place, vMainFast, z100, tGrip\WObj:=wobj0;
!*** 2. Robot go to place
        MoveL offs(pPlace_1_2,0,0,nPrePlace), vMainFast, z50, tGrip\WObj:=WLoadOut2;
        MoveL pPlace_1_2, vMainFast, fine, tGrip\WObj:=WLoadOut2;
!*** 3. Robot to PLC Gipper open
        SetDO DOPLC_PlaceFinished_1_2,1; 
        WaitDI DIPLC_Place_GripSafe_Comp,1\Visualize\Header:="Waiting for signal"\Message:="Wait write data Done"\Icon:=iconInfo; 
!*** 4. Robot move up    
        MoveL Offs(pPlace_1_2,0,0,nPostPlace), vMainFast,fine, tGrip\WObj:=WLoadOut2;
!*** 5. Robot at place standby              
        MoveL psb_Place, vMainFast, fine, tGrip\WObj:=wobj0;
!*** 6. Robot to PLC Gipper safe zone finished
        PulseDO \PLength:= 0.5, DOPLC_Place_PowPos_Ready;
        WaitDI DIPLC_Place_Starting,1\Visualize\Header:="Waiting for signal"\Message:="Wait write data Done"\Icon:=iconInfo;
        SetDO DOPLC_PlaceFinished_1_2,0;      
        PulseDo \PLength:= 0.5,DOPLC_Robot_Acknowlege; 
    
    ENDPROC 
    
ENDMODULE