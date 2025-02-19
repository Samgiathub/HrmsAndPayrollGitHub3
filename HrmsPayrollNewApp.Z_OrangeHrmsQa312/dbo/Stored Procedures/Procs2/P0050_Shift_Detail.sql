



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Shift_Detail]
		 @Shift_Tran_ID		numeric(18,0) output
		,@Shift_ID			numeric(18,0) 
		,@Cmp_ID			numeric(18,0)
		,@From_Hour			numeric(5, 2)
		,@To_Hour			numeric(5, 2)
		,@Minimum_Hour		numeric(5, 2)
		,@Calculate_Days	numeric(5, 2)
		,@OT_Applicable		numeric(1, 0)
		,@Fix_OT_Hours		numeric(5,2)
		,@tran_type			varchar(1)
		,@Fix_W_Hours		numeric(5,2) = 0
		,@OT_Start_Time     Tinyint=0
		,@Rate				numeric(5,2) = 0 
		,@OT_End_Time     Tinyint=0	--Ankit 12112013
		,@Working_Hrs_End_Time tinyint=0 --Hardik 03/02/2014
		,@Working_Hrs_St_Time tinyint=0 --Hardik 14/02/2014
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    if @Fix_OT_Hours = 0 
           set @Fix_OT_Hours =0
      
		if @tran_type ='I' 
			begin
					If Exists(select Shift_Tran_ID From T0050_Shift_Detail WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and  Shift_ID=@Shift_ID and Calculate_Days = @Calculate_Days)
							Begin
								set @Shift_Tran_ID = 0
								return 0
							End
			
					
			
					select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0050_Shift_Detail WITH (NOLOCK)
					
					INSERT INTO T0050_Shift_Detail
						(Shift_Tran_ID,Shift_ID, Cmp_ID,From_Hour,To_Hour,Minimum_Hour,Calculate_Days,OT_Applicable,Fix_OT_Hours,Fix_W_Hours,OT_Start_Time,Rate,OT_End_Time,Working_Hrs_End_Time,Working_Hrs_St_Time)
					VALUES     (@Shift_Tran_ID,@Shift_ID,@Cmp_ID,@From_Hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Fix_W_Hours,@OT_Start_Time,@Rate,@OT_End_Time,@Working_Hrs_End_Time,@Working_Hrs_St_Time)
				end 
	else if @tran_type ='U' 
				begin
					If Exists(select Shift_Tran_ID From T0050_Shift_Detail WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and  Shift_ID=@Shift_ID and Calculate_Days = @Calculate_Days And Shift_Tran_ID <> @Shift_Tran_ID)
							Begin
								set @Shift_Tran_ID = 0
								return 0
							End

					UPDATE    T0050_Shift_Detail
					SET       Shift_Tran_ID =@Shift_Tran_ID
					         ,Shift_ID=@Shift_ID
					         , Cmp_ID=@Cmp_ID
					         ,From_Hour=@From_Hour
					         ,To_Hour=@To_Hour
					         ,Minimum_Hour=@Minimum_Hour
					         ,Calculate_Days=@Calculate_Days
					         ,OT_Applicable=@OT_Applicable
					         ,Fix_OT_Hours =@Fix_OT_Hours
					         ,Fix_W_Hours = @Fix_W_Hours
					         ,OT_Start_Time=@OT_Start_Time
					         ,Rate =@Rate
					         ,OT_End_Time = @OT_End_Time
					         ,Working_Hrs_End_Time = @Working_Hrs_End_Time
					         ,Working_Hrs_St_Time = @Working_Hrs_St_Time
					WHERE     Shift_Tran_ID = @Shift_Tran_ID
				end
	else if @tran_type ='D' 
		begin
			DELETE FROM T0050_Shift_Detail 	WHERE Shift_Tran_ID = @Shift_Tran_ID	
		end
		
	RETURN

