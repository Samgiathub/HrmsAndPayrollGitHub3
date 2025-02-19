
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0050_CF_EMP_TYPE_DETAIL]
	 @Setting_ID		numeric(18, 0)
	,@Cmp_ID		numeric(18, 0)
	,@Effective_Date datetime
	,@Type_ID		numeric(18, 0)
	,@Leave_ID		numeric(18, 0)
	,@CF_Type_ID	numeric(18, 0)
	,@Reset_Months	numeric(18, 0)
	,@Duration		varchar(50)
	,@CF_Months		nvarchar(50)
	,@Release_Month	numeric(18, 0)	
	,@Reset_Month_String nvarchar(50)='' --Uncomment by Jaina 10-11-2017
	,@Laps_After_Release tinyint = 0 --Added By Jimit 18042019
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Reset_Months_Str	nvarchar(max)
	Declare @tmp_month			numeric(18, 0)
	Declare @i	int
	
	set @Reset_Months_Str = 0
	set @tmp_month = 0
	set @i = 1
	
	--Commented by Hardik 21/09/2012
	--If @Reset_Months > 0
	--	Begin
	--		if @Reset_Months <= 12
	--			begin
	--				while @i <= 12/@Reset_Months
	--					begin
	--						if (@Release_Month + @i * @Reset_Months) % 12 = 0
	--							begin
	--								set @Reset_Months_Str = @Reset_Months_Str + cast((@Release_Month + @i * @Reset_Months) as varchar) + '#'						
	--							end
	--						else
	--							begin
	--								set @Reset_Months_Str = @Reset_Months_Str + cast((@Release_Month + @i * @Reset_Months) % 12 as varchar) + '#'						
	--							end
												
	--						set @i = @i + 1
	--					end			
	--			end
	--		else
	--			begin
	--				set @Reset_Months_Str = cast((@Release_Month + @Reset_Months) % 12 as varchar) 
	--			end 
			
	--	End	
	--Else
	--	Begin
	--		set @Reset_Months_Str = ''
	--	End

	--Set @Reset_Months_Str = @Release_Month  --Comment by Jaina 10-11-2017
	
	Select @Setting_ID = ISNULL(max(Setting_ID),0)+1 from T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK)

	Insert Into T0050_CF_EMP_TYPE_DETAIL
--	Values(@Setting_ID,@Cmp_ID,@Effective_Date,@Type_ID,@Leave_ID,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,@Release_Month,@Reset_Months_Str)	
	Values(@Setting_ID,@Cmp_ID,@Effective_Date,@Type_ID,@Leave_ID,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,@Release_Month,@Reset_Month_String,@Laps_After_Release)	
	
	
	    
END



