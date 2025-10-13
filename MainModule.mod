MODULE MainModule
    !***********************************************************
    !
    ! Customer:  IRC Thailand
    !
    ! Description: Project Robot powder spray No.1
    !  
    ! Author: Maiyasit charoenkitsiriwong
    !       : 094-490-4275
    !       : ABB Robotic Thailand
    ! Version: 2.0
    !
    !***********************************************************
   RECORD CamTarget
        num x;
        num y;
        num z;
    ENDRECORD

    PERS CamTarget posCAM:=[309,0,311];
    
    TASK PERS tooldata tGrip:=[TRUE,[[140,0,420],[1,0,0,0]],[60,[-126.3,-49.2,162.6],[1,0,0,0],4.836,5.881,8.477]];
    TASK PERS wobjdata wLoadin:=[FALSE,TRUE,"",[[1350,-465,10.5],[0.707107,0,0,0.707107]],[[0,0,0],[1,0,0,0]]];
    
    VAR Bool FirstCyc:=TRUE;

    PERS num nStCur:=1;
    PERS num nStNext:=8;

    CONST jointtarget jHome:=[[4.02629E-05,-20.9997,23.0036,9.37319E-05,88.0001,-40.3918],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    PERS speeddata vHome:=[500,50,1000,1000];
    PERS speeddata vMainFast:=[7000,500,1000,1000];
    PERS speeddata vMedium := [5000,500,1000,1000];
    PERS speeddata vSlowly := [2000,500,1000,1000];
    PERS speeddata vPlace := [1000,500,1000,1000];
    PERS speeddata vSpray:=[75.9999,50,1000,1000];
    
    VAR clock timer;

    PERS num nPrePick:=250;
    PERS num nPrePlace:=250;
    PERS num nPostPlace:=230;
    PERS num nPreSrpay:=200;
    PERS num nPreoffxPick:=-100;
    PERS num nOffyPlace5:=-30;
    PERS num nOffyPlace6:=80;
    PERS num nCountSpray:=1;
    
    PERS num noffXPick:=70;
     
    VAR intnum ipSpeed;
    PERS num nAcc:=90;
    PERS num nRamp:=90;
    PERS num nRampFine:=80;
    PERS num nTime1:=6.719;
    VAR num nTime2:=14.781;
   
    TASK PERS wobjdata WLoadOut1:=[FALSE,TRUE,"",[[1440.988,-1169.5,10.5],[0.999623496,-0.027438402,0,0]],[[0,0,0],[1,0,0,0]]];
    TASK PERS wobjdata WLoadOut2:=[FALSE,TRUE,"",[[1440.988,350,10.5],[0.998650894,-0.051926801,0,0]],[[0,0,0],[1,0,0,0]]];
    
    PERS robtarget pPick:=[[160,641,46.15],[8.60248E-05,-0.419531,-0.907741,-0.000184235],[-1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pPlace_1_1:=[[245.42,295.13,185.64],[0.00927862,-0.345103,0.938164,0.0258284],[-1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pPlace_1_2:=[[222.83,314.75,214.08],[0.0176767,-0.34479,0.937244,0.0487911],[0,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget psb_Pick:=[[711.24,-90.74,470.01],[0.000105843,0.345223,-0.938521,-3.67389E-05],[-1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget psb_Place:=[[711.24,-90.74,470.01],[0.000105843,0.345224,-0.93852,-3.6739E-05],[-1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pPre_Home:=[[783.66,-91.00,576.64],[0.000467717,0.343868,-0.939018,-0.000184086],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pSafePos1_2:=[[1657.80,676.88,455.55],[0.00175578,0.372043,-0.928208,-0.00318739],[0,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pSafePos1_1:=[[1676.60,-874.00,455.79],[0.00178386,0.372041,-0.928209,-0.00321302],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
   
    
    PROC Initital()
!******* Reset wobj *****************     
        wLoadin.oframe.trans.x:=0;
        wLoadin.oframe.trans.y:=0;
 
!************************************    
        
        SetDO DOPLC_Pick_Data_Received,0;
        SetDO DOPLC_Pick_Data_Req,0;
        SetDO DOPLC_Pick_Pos_Ready,0;
        SetDO DOPLC_Pick_ZaxisUp_Ready,0;
        SetDO DOPLC_Place_GripSafe_Req,0;
        SetDO DOPLC_Place_PowPos_Ready,0;
        SetDO DOPLC_Place_Ready,0;
        SetDO DOPLC_Robot_Acknowlege,0;
        SetDO DOPLC_Place_ZAixUp_Ready,0;
        SetDO DOPLC_PlaceFinished_1_1,0;
        SetDO DOPLC_PlaceFinished_1_2,0;

        SetDO DOPLC_UpdateSpeed_Done,0;
        SetDO DOPLC_Pick_Data_Received,0;
        SetDO DOPLC_Pick_Data_Received,0;
    
    ENDPROC

    PROC GoHome()       
        VAR robtarget pCur;
        TPWrite "Station : Home";
        WaitTime\InPos,0.5;
        pCur:=CRobT(\Tool:=tGrip\WObj:=wobj0);
        WaitTime\InPos,0.5;
        pcur.trans.z:=450;
        MoveL pCur,vHome,fine,tGrip;
        IF DO_WzPlace1_2 = 1 THEN
            MoveL pSafePos1_2,v100,z50,tGrip;
            MoveL Offs(pSafePos1_2,-800,0,0),vHome,z50,tGrip;
            MoveL Offs(pPre_Home,0,0,0),vHome,fine,tGrip;
        ELSEIF DO_WzPlace1_1 = 1 THEN
            MoveL pSafePos1_1,v100,z50,tGrip;
            MoveL Offs(pSafePos1_1,-800,0,0),vHome,z50,tGrip;
            MoveL Offs(pPre_Home,0,0,0),vHome,fine,tGrip;
        ENDIF
        MoveAbsJ jHome\NoEOffs,vHome,fine,tGrip;
        nStCur:=1;      
    ENDPROC

    PROC main()
         IF FirstCyc THEN
            GoHome;
            Initital;
            FirstCyc:=FALSE;
            
            IF DIPLC_Service = 1 THEN
                rService;
            ENDIF
            Stop;
        ENDIF
        AccSet nAcc,nRamp\FinePointRamp:=nRampFine;
         rPick;        
         IF DIPLC_SPRAY_NO1_1_PLACE_REQ = 1 THEN
            rPlace1_1;
            ClkStop clock1;
            nTime2:=ClkRead(clock1);
            TPWrite "Cycle time Robot1.1 = "\Num:=nTime2;
            RETURN;
         ENDIF
         IF DIPLC_SPRAY_NO1_2_PLACE_REQ = 1 THEN
            rPlace1_2;
            ClkStop clock1;
            nTime1:=ClkRead(Clock1);
            TPWrite "Cycle time Robot1.2 = "\Num:=nTime1;
            RETURN;
         ENDIF
    ENDPROC
    PROC rService()
        PulseDO\PLength:=1,DOPLC_Service_Conf;
        MoveL Offs(psb_Pick,0,0,0), vHome, fine, tGrip;
        WaitTime 1;
        EXIT;
	ENDPROC
    
ENDMODULE