MODULE MainModule
    
! Our main module is what the robot will actually run
    
    ! Variable declaration 
    VAR num x;
    VAR num y;
    VAR num theta_dice;
    CONST num k:=0.1;
    CONST num d:=-6.5;
    VAR robtarget pPickup;
    VAR robtarget pPickup_rotated;
    VAR Dice edice;
    VAR dice_tray dice_data;





    PROC Main()

        ! Define inital dice pickup location
        dice_data.pickup_location:=1;
        dice_data.row_number:=0;
        dice_data.tray_state:=FALSE;
        reset_dice(dice_data); ! Set all dice tray data to false
        
        
        MoveAbsJ home,v300,z30,gripper\WObj:=tray; ! Move home
        open_gripper;

        TRAY_Pickup(dice_data); ! Go to pickup dice at inital position 
        DropoffDiceViaHome; ! Drop off dice

        ! Now enter main loop
        WHILE TRUE DO
            MoveJ pWaitingForDice,v1000,z30,gripper\WObj:=conveyor; ! Wait for dice

            ! This code will activate the conveyor and pulse the relevant signals to setup conveyor 
            
            !using CNV1
            ActUnit CNV1;
            ConfL\Off;

            ! Get cam data
            edice:=halloMain();
            dice_data.dice_number:=edice.number;

            !release all objects from queue
            DropWobj wobjCNV1;
            PulseDO\PLength:=0.5,c1RemAllPObj;

            !attaching thing to the moving conveyor
            PulseDO\PLength:=0.5,c1SoftSyncSig;
            WaitWobj wobjCNV1;


            !rotating the tool in the waiting position
            theta_dice:=edice.orientation_a;
            pWaitingForDice_rotated:=rotate_euler_absolute(pWaitingForDice,pWaitingForDice_rotated,135-theta_dice);
            MoveL pWaitingForDice_rotated,v200,z1,gripper\WObj:=conveyor;

            !waiting FOR dice TO EXIT the tower
            WaitTime 3.1;

            !adding offsets and optical fix
            x:=edice.pos_x+14;
            y:=edice.pos_y+11;
            y:=y+k*y+d; ! This is fixing optical skew from the camera
            pPickup_rotated:=rotate_euler_absolute(convhome,pPickup_rotated,135-theta_dice); ! Rotate the robot by the dice rotation
            pPickup:=Offs(pPickup_rotated,x,y,0); ! Define pickup location as rotated position offset by x and y (Dice pos)

            !picking up the dice from the conveyor
            pick_up_dice(pPickup);

            ! Now we will determine what to do with the dice
            
            dice_data:=dice_it_up(dice_data); !Up dice it up to check tray states and determine if we should roll again

        
            IF dice_data.roll_again THEN ! If dropoff place is already occupied roll again
                DropoffDiceViaHome;

            ! Check dice tray state and determine dropoff and pickup location
            ELSEIF dice_data.tray_state=FALSE THEN
                !dropoff place still empty
                dice_data.row_number:=1;
                TRAY_Dropoff(dice_data);
                dice_data.row_number:=0;
                dice_data.pickup_location:=dice_data.pickup_location+1;
                IF dice_data.pickup_location>6 THEN
                    dice_data.pickup_location:=1;
                    dice_data.tray_state:=TRUE;
                    dice_data.row_number := 1;
                    dice_data := reset_dice(dice_data);
                ENDIF
                TRAY_Pickup(dice_data);
                DropoffDiceViaHome;
            ELSEIF dice_data.tray_state=TRUE THEN
                !dropoff place still empty
                dice_data.row_number:=0;
                TRAY_Dropoff(dice_data);
                dice_data.row_number:=1;
                dice_data.pickup_location:=dice_data.pickup_location+1;
                IF dice_data.pickup_location>6 THEN
                    dice_data.pickup_location:=1;
                    dice_data.tray_state:=FALSE;
                    dice_data.row_number := 0;
                    dice_data := reset_dice(dice_data);
                ENDIF
                TRAY_Pickup(dice_data);
                DropoffDiceViaHome;
            ENDIF



        ENDWHILE
    ENDPROC
ENDMODULE