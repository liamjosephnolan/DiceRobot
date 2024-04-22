MODULE Tray_Logic

    RECORD dice_tray
        num dice_number;
        num row_number;
        bool goal_1;
        bool goal_2;
        bool goal_3;
        bool goal_4;
        bool goal_5;
        bool goal_6;
        bool roll_again;
        num pickup_location;
        bool tray_state;
    ENDRECORD

    ! Tray INFO
    VAR num y_space:=36;
    VAR num y_offs:=28;
    VAR num x_offs:=18;
    VAR num x_space:=39;
    VAR num z_hover:=20;
    VAR num tray_state:=0;
    VAR num dice_tray_1:=0;
    VAR num dice_tray_2:=0;
    VAR num dice_tray_3:=0;
    VAR num dice_number:=1;

    ! This function determines if the dice tray spot has been filled 
    FUNC dice_tray dice_it_up(dice_tray dice_data)
        IF dice_data.dice_number=1 AND dice_data.goal_1=FALSE THEN
            dice_data.goal_1:=TRUE;
        ELSEIF dice_data.dice_number=2 AND dice_data.goal_2=FALSE THEN
            dice_data.goal_2:=TRUE;
        ELSEIF dice_data.dice_number=3 AND dice_data.goal_3=FALSE THEN
            dice_data.goal_3:=TRUE;
        ELSEIF dice_data.dice_number=4 AND dice_data.goal_4=FALSE THEN
            dice_data.goal_4:=TRUE;
        ELSEIF dice_data.dice_number=5 AND dice_data.goal_5=FALSE THEN
            dice_data.goal_5:=TRUE;
        ELSEIF dice_data.dice_number=6 AND dice_data.goal_6=FALSE THEN
            dice_data.goal_6:=TRUE;
        ELSE
            dice_data.roll_again:=TRUE;
            RETURN dice_data;
        ENDIF

        dice_data.roll_again:=FALSE;
        RETURN dice_data;

    ENDFUNC

    ! Function to pickup dice from tray
    PROC TRAY_Pickup(dice_tray dice_data)
        MoveJ Offs(trayhome,(x_space*dice_data.row_number)+x_offs,y_offs+(y_space*(dice_data.pickup_location-1)),1+z_hover),v1000,fine,gripper\Wobj:=tray;
        MoveL Offs(trayhome,(x_space*dice_data.row_number)+x_offs,y_offs+(y_space*(dice_data.pickup_location-1)),2),v100,fine,gripper\Wobj:=tray;
        WaitTime .1;
        close_gripper;
        WaitTime .1;
        MoveL Offs(trayhome,(x_space*dice_data.row_number)+x_offs,y_offs+(y_space*(dice_data.pickup_location-1)),1+z_hover),v300,fine,gripper\Wobj:=tray;
    ENDPROC

    ! Function to dropoff dice at tray
    PROC TRAY_Dropoff(dice_tray dice_data)
        MoveJ Offs(trayhome,(x_space*dice_data.row_number)+x_offs,y_offs+(y_space*(dice_data.dice_number-1)),4+z_hover),v5000,fine,gripper\Wobj:=tray;
        MoveL Offs(trayhome,(x_space*dice_data.row_number)+x_offs,y_offs+(y_space*(dice_data.dice_number-1)),4),v100,fine,gripper\Wobj:=tray;
        WaitTime .1;
        open_gripper;
        WaitTime .1;
        MoveL Offs(trayhome,(x_space*dice_data.row_number)+x_offs,y_offs+(y_space*(dice_data.dice_number-1)),4+z_hover),v300,fine,gripper\Wobj:=tray;
    ENDPROC
    
    ! FUnction to reset tray goals
    FUNC dice_tray reset_dice(dice_tray dice_data)
        dice_data.goal_1:=FALSE;
        dice_data.goal_2:=FALSE;
        dice_data.goal_3:=FALSE;
        dice_data.goal_4:=FALSE;
        dice_data.goal_5:=FALSE;
        dice_data.goal_6:=FALSE;
        RETURN dice_data;
    ENDFUNC

ENDMODULE