MODULE CameraModule
    
    ! This Module contains all code relating to camera processing
    
    ! Create a record variable called Dice that will store all camera data
    RECORD Dice
        bool dice_detected;
        num number;
        num pos_x;
        num pos_y;
        num orientation_a;
    ENDRECORD
       
    ! Variable def from INSIGHT modules
    CONST string strNULL:="";
    CONST string strOK:="OK";
    CONST string strYES:="YES";
    CONST string strNO:="NO";
    VAR string strFileName:="";

    !**********************************************************
    ! Temporary data / Données temporaires
    VAR clock clockComm;
    VAR bool bStVal;
    VAR bool bStatus;
    VAR string strJobVision:="Nolan_Spindler.job";
    VAR string strValue:="";
    PERS num nErrStatus:=0;
    PERS num nActiveCam:=1;
    PERS string strIP_Camera1:="192.168.125.201";

    

! Camera inititilization module (From Insight module)
    PROC InitCam()
        ! Initializing the camera persistant data / Initialisation des données persistantes de la caméra
        CX_SetupCamera nActiveCam,strIP_Camera1,23,"admin","",-600,600,-600,600,-180,180,50\Timeout:=1;
        ! Initializing communication / Initialisation de la communication
        IF NOT CX_InitComm(nActiveCam,nErrStatus) THEN
            CX_ShowErrStatus nErrStatus;
            RETURN ;
        ENDIF
        !
        ! Checking the "Online" mode status / Vérification de l'état du mode "Online"
        IF CX_GetOnline(nActiveCam,nErrStatus) THEN
            TPErase;
            TPWrite "The vision is already on line";
        ELSE
            ! Requesting the "Online" mode / Demande de passage en mode "Online"
            IF CX_SetOnline(nActiveCam,\On,nErrStatus) THEN
                TPWrite "The vision has been set to on line mode";
            ELSE
                CX_ShowErrStatus nErrStatus;
                RETURN ;
            ENDIF
        ENDIF
        !
        ! Reading the vision program name / Lecture du nom du programme vision
        IF CX_GetFile(nActiveCam,strFileName,nErrStatus) THEN
            TPErase;
            TPWrite "Name of vision program: "+strFileName;
        ELSE
            ! Case execution memory of camera is empty / Cas mémoire exécution caméra vide
            ! Loading demo program from flash memory / Chargement programme de démo de la mémoire flash
            IF strFileName=strNULL THEN
                ! Setting camera offline / Passage caméra hors ligne
                bStatus:=CX_SetOnline(nActiveCam,\Off,nErrStatus);
                ! Loading "job" file / Chargement fichier "job"
                IF NOT CX_LoadFile(nActiveCam,strJobVision,nErrStatus) THEN
                    CX_ShowErrStatus nErrStatus;
                    RETURN ;
                ENDIF
                ! Setting camera on line / Passage caméra en ligne
                bStatus:=CX_SetOnline(nActiveCam,\On,nErrStatus);
            ELSE
                CX_ShowErrStatus nErrStatus;
                RETURN ;
            ENDIF
        ENDIF
    ENDPROC
    

! This function will parse the string data that the Camera program produces and assign relevant Variables
    FUNC Dice get_dicedata_from_string(string data)
        
        ! Variable decleration
        VAR bool success;
        VAR num job_status; 
        VAR num x_pos;
        VAR num y_pos;
        VAR num angle;
        VAR num dice_number;
        VAR Dice o_dice;
        VAR string s;
                                                             
                                                                     
                                                                      
        ! Check string exists and parse data                                    
        IF StrLen(data) > 1 THEN
            s := StrPart(data, 1, 1);
            success := StrToVal("1.0", job_status);
            success := StrToVal(StrPart(data, 1, 1), job_status);
            success := success AND StrToVal(StrPart(data, 3, 10), y_pos);
            success := success AND StrToVal(StrPart(data, 14, 10), x_pos);
            success := success AND StrToVal(StrPart(data, 25, 10), angle);
            success := success AND StrToVal(StrPart(data, 36, 1), dice_number);
            
            
            o_dice.dice_detected := job_status = 1;
            o_dice.pos_x := x_pos;
            o_dice.pos_y := y_pos;
            o_dice.orientation_a := angle;
            o_dice.number := dice_number;
        ELSE
            o_dice.dice_detected := false;
            o_dice.pos_x := 0;
            o_dice.pos_y := 0;
            o_dice.orientation_a := 0;
            o_dice.number := 0;
        ENDIF
        
        RETURN o_dice; ! Return dice variable which will contain the parameters of the dice
    ENDFUNC

    ! Camera function that combines initi function and data parsing function 
    FUNC Dice halloMain()
        VAR Dice o_dice; ! Declare dice variable
        InitCam; ! Init camera 
        WHILE TRUE DO ! Loop all this cool code
            IF CX_GetValue(nActiveCam,"U",87,strValue,nErrStatus) THEN ! If string data is present in U87 cell (This cell depends on camera, you will need to change this probably)
                o_dice := get_dicedata_from_string(strValue); ! Get dice data and parse
                IF NOT o_dice.pos_x = 0 THEN ! If no dice is detected the hallomain will set position to 0, we check for this case
                    RETURN o_dice; ! if position=0 we return dice (Yeah this is a bit hacky but if the dice position is actually 0 we have bigger problems)
                ENDIF
            ELSE
                TPWrite "NOK",\Num:=nErrStatus; ! This will catch any weird edge cases and write NOK to console for debugging
            ENDIF
            WaitTime 0.1; ! Add brief wait so we are not overwhelming console
        ENDWHILE
        
    ENDFUNC

ENDMODULE