pragma Profile (Ravenscar);

with CAN_Handler;
with Interfaces;

procedure Pneumatics_Controller is

   use type CAN_Handler.CAN_ID;
   use type Interfaces.Unsigned_8;

   CAN_ID_KILL_SWITCH	: Constant CAN_Handler.CAN_ID := 111;
   CAN_ID_SIM_MODE	: Constant CAN_Handler.CAN_ID := 222;

   bKillSwitchFlag	: Boolean := False;
   bSimModeFlag		: Boolean := False;
   canMsg		: CAN_Handler.CAN_Message;

   procedure Dispatch_Kill_Msg(canMsg : CAN_Handler.CAN_Message) is
   begin
      if canMsg.Data(1) = 0 then
         bKillSwitchFlag := True;
      elsif canMsg.Data(1) = 255 then
        bKillSwitchFlag := False;
      else
         null;
      end if;
   end Dispatch_Kill_Msg;

   procedure Dispatch_Sim_Msg(canMsg : CAN_Handler.CAN_Message) is
   begin
      if canMsg.Data(1) = 0 then
         bSimModeFlag := True;
      elsif canMsg.Data(1) = 255 then
         bSimModeFlag := False;
      else
         null;
      end if;
   end Dispatch_Sim_Msg;

   procedure Dispatch_Actuation(canMsg : CAN_Handler.CAN_Message) is
   begin
      case canMsg.Data(1) is
         when 1 =>
            Actuate(PIN_TORPEDO_LEFT, T_TORPEDO_ACTUATION, bSimModeFlag);
         when 2 =>
            Actuate(PIN_TORPEDO_RIGHT, T_TORPEDO_ACTUATION, bSimModeFlag);
         when 3 =>
            Actuate(PIN_MARKER_LEFT, T_MARKER_ACTUATION, bSimModeFlag);
         when 4 =>
            Actuate(PIN_MARKER_RIGHT, T_MARKER_ACTUATION, bSimModeFlag);
         when 5 =>
            Actuate(PIN_GRIPPER_GRAB, True, bSimModeFlag);
         when 6 =>
            Actuate(PIN_GRIPPER_GRAB, False, bSimModeFlag);
         when 7 =>
            Actuate(PIN_GRIPPER_ROTATE, True, bSimModeFlag);
         when 8 =>
            Actuate(PIN_GRIPPER_ROTATE, False, bSimModeFlag);
         when others =>
            null;
      end case;
   end Dispatch_Actuation;

begin

   -- init
   -- TODO: Read msg from can buffer
   -- canMsg = read message

   if canMsg.ID = CAN_ID_KILL_SWITCH then
      Dispatch_Kill_Msg(canMsg);
   elsif canMsg.ID = CAN_ID_SIM_MODE then
      Dispatch_Sim_Msg(canMsg);
   else
      if bKillSwitchFlag = False then
         Dispatch_Actuation(canMsg);
      end if;
   end if;

   -- TODO: Send MSG 'COMPLETED'

end Pneumatics_Controller;
