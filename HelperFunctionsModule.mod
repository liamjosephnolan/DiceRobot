MODULE HelperFunctionsModule
    PROC open_gripper()
        SetDO DO_07,0;
        SetDO DO_08,1;
    ENDPROC
    
    PROC close_gripper()
        SetDO DO_07,1;
        SetDO DO_08,0;
    ENDPROC
    
    PROC rotate()
        VAR num anglex;
        MoveJ rotPoint10,v10,z1,gripper\WObj:=tray;
        MoveJ RelTool(rotPoint10,0,0,0\Rx:=45),v10,z1,gripper\WObj:=tray;
    ENDPROC
    
    
    FUNC robtarget rotate_euler(robtarget old_target,robtarget rotated_target,num angle)
        VAR num anglex;
        VAR num angley;
        VAR num anglez;
        VAR orient angles;

        anglex:=EulerZYX(\X,old_target.rot);
        angley:=EulerZYX(\Y,old_target.rot);
        anglez:=EulerZYX(\Z,old_target.rot);


        anglez:=anglez+angle;
        rotated_target.rot:=OrientZYX(anglez,angley,anglex);
        RETURN rotated_target;
    ENDFUNC
    
    FUNC robtarget rotate_euler_absolute(robtarget old_target,robtarget rotated_target,num angle)
        VAR num anglex;
        VAR num angley;
        VAR num anglez;
        VAR orient angles;

        anglex:=EulerZYX(\X,old_target.rot);
        angley:=EulerZYX(\Y,old_target.rot);
        anglez:=EulerZYX(\Z,old_target.rot);


        anglez:=angle;
        rotated_target.rot:=OrientZYX(anglez,angley,anglex);
        RETURN rotated_target;
    ENDFUNC
    

    PROC print_euler_angles(robtarget target)
        VAR num anglex;
        VAR num angley;
        VAR num anglez;
        VAR orient angles;
        anglex:=EulerZYX(\X,target.rot);
        angley:=EulerZYX(\Y,target.rot);
        anglez:=EulerZYX(\Z,target.rot);

        TPWrite "X="\Num:=anglex;
        TPWrite "Y="\Num:=angley;
        TPWrite "Z="\Num:=anglez;
    ENDPROC

    PROC euler_print_test()
        !Moving home, then to pickup and then printing angles
        MoveAbsJ home,v300,z30,gripper\WObj:=tray;
        MoveJ pWaitingForDice,v300,z30,gripper\WObj:=conveyor;
        print_euler_angles(pWaitingForDice);
        
        !rotating
        pWaitingForDice_rotated := rotate_euler(pWaitingForDice, pWaitingForDice_rotated, 30);
        MoveL pWaitingForDice_rotated,v50,z10,gripper\WObj:=conveyor;
        print_euler_angles(pWaitingForDice_rotated);
        
        MoveAbsJ home,v300,z30,gripper\WObj:=tray;
    ENDPROC

    PROC read_and_print_cognex_angle()
        VAR Dice edice;
        edice := halloMain();
        TPWrite NumToStr(edice.orientation_a, 2);
    ENDPROC
        
    PROC follow_dice_rotation()
        VAR Dice edice;
        VAR Num theta := 0;
        MoveAbsJ home,v300,z30,gripper\WObj:=tray;
        MoveJ pWaitingForDice,v300,z30,gripper\WObj:=conveyor;
        WHILE TRUE DO 
            edice := halloMain();
            TPWrite NumToStr(edice.orientation_a, 2);
            theta := edice.orientation_a;
            pWaitingForDice_rotated := rotate_euler_absolute(pWaitingForDice, pWaitingForDice_rotated, 125-theta);
            MoveL pWaitingForDice_rotated,v50,z10,gripper\WObj:=conveyor;
        ENDWHILE
    ENDPROC
    
    ! Function to drop off dice while passing home point
    PROC DropoffDiceViaHome()
            MoveAbsJ home,v1000,z50,gripper\WObj:=conveyor;
            MoveJ Offs(Dropoff,0,300,100),v1000,z150,gripper\WObj:=conveyor;
            MoveJ Dropoff,v300,fine,gripper\WObj:=conveyor;
            open_gripper;
            WaitTime 0.2;
            MoveJ Offs(Dropoff,0,300,100),v1000,z150,gripper\WObj:=conveyor;
            MoveAbsJ home,v1000,z50,gripper\WObj:=tray;
    ENDPROC
    
    ! Function to pickup dice off of conveyor 
    PROC pick_up_dice(robtarget pPickupTarget)
        
        ! Define follow time variables
        VAR stoppointdata my_followtime_1:=[3,TRUE,[0,0,0,0],0,1,"",0,0];
        VAR stoppointdata my_followtime_05:=[3,TRUE,[0,0,0,0],0,.5,"",0,0];
        VAR stoppointdata my_followtime_025:=[3,TRUE,[0,0,0,0],0,.25,"",0,0];
        VAR stoppointdata my_followtime_01:=[3,TRUE,[0,0,0,0],0,0.1,"",0,0];

        !moving to position above the conveyor whilst tracking it
        MoveL Offs(pPickupTarget,0,0,30),v300,z10,gripper\wobj:=wobjCNV1;

        !moving down with the conveyor and also closing the gripper
        MoveL pPickupTarget,v150,z0,gripper\wobj:=wobjCNV1;
        ! go to target with zone 0
        MoveL pPickupTarget,v300,z10\Inpos:=my_followtime_025,gripper\wobj:=wobjCNV1;
        WaitTime .1;
        close_gripper;

        !moving up whilst following and removing the first object from the queue, as we picked it up
        !MoveL Offs(pPickupTarget,0,0,50),v300,z10\Inpos:=my_followtime_01,gripper\wobj:=wobjCNV1;
        PulseDO\PLength:=0.5,c1Rem1PObj;
        


        !leaving the conveyor - not tracking anymore
        MoveL leaveConv,v500,z100,gripper\WObj:=conveyor;
 
        !dropping the conveyor wobj
        WaitTime .2;
        DropWobj wobjCNV1;
        DeactUnit CNV1;
        WaitTime .2;

    ENDPROC
    
ENDMODULE