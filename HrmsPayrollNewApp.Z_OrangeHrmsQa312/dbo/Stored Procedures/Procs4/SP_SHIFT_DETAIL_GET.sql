



CREATE PROCEDURE [dbo].[SP_SHIFT_DETAIL_GET]
 @emp_Id		numeric
,@Cmp_ID		numeric
,@For_Date		datetime
,@Shift_ID			numeric = null output
,@F_Shift_In_Time		varchar(17) = null output
,@F_Shift_End_Time		varchar(17) = null output
,@S_Shift_in_Time		varchar(17) = null output
,@S_shift_end_Time		varchar(17) = null output
,@T_Shift_In_Time		varchar(17) = null output
,@T_Shift_End_Time		varchar(17) = null output
,@Shift_St_Time			varchar(17) = null output 
,@Shift_end_Time		varchar(17) = null output 
AS
	
        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

		--Added by Nimesh 21 May 2015
		SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation (@Cmp_ID, @emp_Id, @For_Date);

			
		If Isnull(@Shift_ID,0) > 0 
			 select @Shift_ID = es.shift_ID ,
		 			@Shift_st_Time = shift_St_Time,
					@Shift_end_Time = shift_End_Time,
					@F_Shift_In_Time = F_St_Time,
					@F_Shift_end_Time = f_End_Time,
					@S_Shift_in_Time = s_St_Time,
					@S_shift_end_Time = s_end_Time,
					@T_Shift_In_Time = t_St_Time,
					@T_Shift_End_Time = t_end_Time
			  from T0100_emp_shift_Detail es WITH (NOLOCK) inner join 
					T0040_shift_master sm WITH (NOLOCK) on es.Shift_ID =sm.shift_ID 
			  Where Es.Shift_ID = @Shift_Id
		ELSE
				select @Shift_ID = es.shift_ID ,
		 			@Shift_st_Time = shift_St_Time,
					@Shift_end_Time = shift_End_Time,
					@F_Shift_In_Time = F_St_Time,
					@F_Shift_end_Time = f_End_Time,
					@S_Shift_in_Time = s_St_Time,
					@S_shift_end_Time = s_end_Time,
					@T_Shift_In_Time = t_St_Time,
					@T_Shift_End_Time = t_end_Time
			  from T0100_emp_shift_Detail es WITH (NOLOCK) inner join 
			 ( select max(for_Date) For_date ,Emp_ID from T0100_emp_shift_Detail WITH (NOLOCK)
				Where Emp_ID =@Emp_ID and For_Date <=@For_Date group by Emp_ID 
				)q on es.emp_ID =q.emp_ID and es.for_Date =q.for_Date inner join 
					T0040_shift_master sm WITH (NOLOCK) on es.Shift_ID =sm.shift_ID 
 
 

	RETURN 




