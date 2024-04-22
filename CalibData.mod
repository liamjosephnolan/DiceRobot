MODULE CalibData

    ! This Module contains tooldata, workobjects, and robot targets referenced by the program
    
    PERS tooldata needle:=[TRUE,[[109.957,0.402156,127.769],[1,0,0,0]],[0.2,[50,0,50],[1,0,0,0],0,0,0]]; ! Needle tool
    PERS tooldata gripper:=[TRUE,[[85.9719,0.555112,165.888],[1,0,0,0]],[0.5,[50,0,50],[1,0,0,0],0,0,0]]; ! Dice Gripping tool
    
    
    PERS wobjdata tray:=[FALSE,TRUE,"",[[257.89,311.38,187.86],[0.704513,0.00373501,-0.00175316,0.709679]],[[0,0,0],[1,0,0,0]]]; ! Tray
    PERS wobjdata conveyor:=[FALSE,TRUE,"",[[576.19,-234.78,305.27],[0.704296,0.00893523,0.0169069,0.709649]],[[0,0,0],[1,0,0,0]]]; ! Static Conveyor
    TASK PERS wobjdata wobjCNV1:=[FALSE,FALSE,"CNV1",[[576.19,-234.78,305.27],[0.704296,0.00893523,0.0169069,0.709649]],[[0,0,0],[1,0,0,0]]]; ! Moving Conveyor
    
    
    CONST jointtarget home:=[[0,-50,40,0,30,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]]; ! Home Position
    CONST robtarget Dropoff:=[[-199.04,64.98,39.94],[0.298369,0.624639,0.515993,-0.504532],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]]; ! Dice Dropoff Target
    CONST robtarget pTarget:=[[0,0,50],[1,0,0,0],[-1,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pTarget10:=[[35.07,53.06,43.06],[0.417701,0.576307,0.567299,-0.414208],[-1,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,0]];
    CONST robtarget leaveConv:=[[573.41,162.60,83.74],[0.417885,0.576127,0.567226,-0.414371],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,10632.4]]; ! Target for leaving conveyor
    CONST robtarget trayhome:=[[0,0,0],[0.484608,0.328872,0.783622,-0.207206],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget convhome:=[[-0.66,1.40,-0.37],[0.366617,0.610941,0.597739,-0.367493],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,0]];
    CONST robtarget pWaitingForDice:=[[307.67,158.75,63.17],[0.372308,0.610577,0.599026,-0.360208],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,0]];
    VAR robtarget pWaitingForDice_rotated:=[[307.67,158.75,63.17],[0.372308,0.610577,0.599026,-0.360208],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,0]];
  


ENDMODULE