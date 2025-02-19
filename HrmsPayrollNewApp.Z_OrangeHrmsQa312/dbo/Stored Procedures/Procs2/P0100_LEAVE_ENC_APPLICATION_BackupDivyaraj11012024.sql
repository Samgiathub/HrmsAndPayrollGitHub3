

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_LEAVE_ENC_APPLICATION_BackupDivyaraj11012024]
		 @Lv_Encash_App_ID numeric output
		,@Cmp_ID numeric
		,@Emp_ID  numeric
		,@Leave_ID numeric
		,@Lv_Encash_App_Date datetime
		,@Lv_Encash_App_Code varchar(20) output
		,@Lv_Encash_App_Days numeric(5, 2)
		,@Lv_Encash_App_Status char(1)		
		,@Lv_Encash_App_Comments varchar(250)
		,@Login_ID numeric 
		,@System_Date datetime
		,@tran_type varchar(1)
		,@Leave_CompOff_dates  varchar(max) = '' -- Added by Gadriwala Muslim 01102014	
		,@Lv_Encash_Balance numeric(18,2) = 0 -- Added by Gadriwala Muslim 01102014	
		,@Lv_Encash_Amount numeric(18,2) = 0 -- Added by Hardik 23/03/2016	
AS			
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Max_No_Of_Application numeric(18, 0)
Declare @L_Enc_Percentage_Of_Current_Balance numeric(18, 2)
Declare @Total_Application numeric(18, 0)
Declare @Enc_Days numeric(18, 2)
Declare @For_Date_Encash datetime
Declare @Encashment_After_Months numeric(18, 2)	
Declare @Date_Of_Join datetime
Declare @Default_Short_Name varchar(25) -- Added by Gadriwala Muslim 01102014
Declare @Min_Leave_Encash numeric(18,2) -- Added by Gadriwala Muslim 01102014
Declare @Max_Leave_Encash numeric(18,2) -- Added by Gadriwala Muslim 01102014
Declare @Bal_After_Encash numeric(18,2) -- Added by Gadriwala Muslim 01102014
declare @setting_Value as tinyint=0
Declare @Year as numeric
Declare @date as varchar(20)

--SET @FROM_DATE='01-JAN-' + CAST(YEAR(@LV_ENCASH_APP_DATE) AS VARCHAR(5))  
--SET @TO_DATE='31-DEC-' + CAST(YEAR(@LV_ENCASH_APP_DATE) AS VARCHAR(5))

	select @setting_Value=isnull(setting_value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@CMP_ID and Setting_Name='Display Leave Detail by Selected Period'
		
	--Select @Max_No_Of_Application=Max_No_Of_Application
	--, @L_Enc_Percentage_Of_Current_Balance=L_Enc_Percentage_Of_Current_Balance 
	--from T0040_LEAVE_MASTER where Leave_ID=@leave_ID  
	Set @Year = YEAR(GETDATE())
	if (@setting_Value=0 or @setting_Value=1)
		Begin			
			Set @date = '01-Jan-'+ convert(varchar(5),@Year)
		End
	Else
		Begin
			IF MONTH(GETDATE()) > 3
			BEGIN
				SET @Year = @Year + 1
			END		
			Set @date = '31-Mar-'+ convert(varchar(5),@Year)
		End
		
		DECLARE @START_YEAR DATETIME;
		DECLARE @END_YEAR DATETIME;
		SET @END_YEAR = CAST(@date AS DATETIME)
		SET @START_YEAR = DATEADD(d, 1,DATEADD(yyyy, -1, @END_YEAR))

	-- Added by Ali 17042014 -- Start
		--Declare @Year as numeric
		--Set @Year = YEAR(GETDATE())
		
		--IF MONTH(GETDATE())> 3
		--BEGIN
		--	SET @Year = @Year + 1
		--END
		
		--Declare @date as varchar(20)  
		--Set @date = '31-Mar-'+ convert(varchar(5),@Year)  
		
		select @Max_No_Of_Application = t.Max_No_Of_Application
		,@L_Enc_Percentage_Of_Current_Balance = t.L_Enc_Percentage_Of_Current_Balance
		,@Encashment_After_Months = t.Encashment_After_Months, @Default_Short_Name = Default_Short_Name,
		@Min_Leave_Encash = Min_Leave_Encash,@Max_Leave_Encash = Max_Leave_Encash,@Bal_After_Encash = Bal_After_Encash from ((select 
		case when ISNULL(temp.Max_No_Of_Application,0)=0 then lm.Max_No_Of_Application else temp.Max_No_Of_Application end as Max_No_Of_Application 
		,case when ISNULL(temp.L_Enc_Percentage_Of_Current_Balance,0)=0 then lm.L_Enc_Percentage_Of_Current_Balance else temp.L_Enc_Percentage_Of_Current_Balance end as L_Enc_Percentage_Of_Current_Balance
		,case when ISNULL(temp.Encash_Appli_After_month,0)=0 then lm.Encashment_After_Months  else temp.Encash_Appli_After_month end as Encashment_After_Months		
		,isnull(Default_Short_Name,'') as Default_Short_Name -- Added by Gadriwala Muslim 01102014
		,case when ISNULL(temp.Min_Leave_Encash,0)=0 then lm.Leave_Min_Encash  else temp.Min_Leave_Encash end as Min_Leave_Encash		
		,case when ISNULL(temp.Max_Leave_Encash,0)=0 then lm.Leave_Max_Encash  else temp.Max_Leave_Encash end as Max_Leave_Encash		
		,case when ISNULL(temp.Bal_After_Encash,0)=0 then lm.Leave_Min_Bal  else temp.Bal_After_Encash end as Bal_After_Encash		
		from T0040_Leave_MASTER LM WITH (NOLOCK) left join 
		(	Select Max_No_Of_Application,L_Enc_Percentage_Of_Current_Balance,Encash_Appli_After_month,Leave_ID, Max_Leave_Encash,Min_Leave_Encash,Bal_After_Encash from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID = @Leave_Id 
			and Cmp_ID = @Cmp_ID  and Grd_ID in (Select I.Grd_ID from   dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
			(SELECT MAX(Increment_Id) AS Increment_Id , Emp_ID FROM dbo.T0095_Increment IM WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
			WHERE Increment_Effective_date <= @date GROUP BY emp_ID ) Qry ON I.Emp_ID = Qry.Emp_ID 
			AND I.Increment_Id = Qry.Increment_Id INNER JOIN
			dbo.T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = Qry.Emp_ID 
			where em.Cmp_ID = @Cmp_Id and em.Emp_ID = @Emp_Id)
		) as temp on LM.leave_id = temp.leave_id 
		where LM.Leave_ID = @Leave_Id and Leave_Type = 'Encashable' )) as t
		
		--Select @Max_No_Of_Application=Max_No_Of_Application
		--,@L_Enc_Percentage_Of_Current_Balance=L_Enc_Percentage_Of_Current_Balance
		--,@Encashment_After_Months=Encashment_After_Months 
		--from T0040_LEAVE_MASTER where Leave_ID=@leave_ID  
	
	-- Added by Ali 17042014 -- End

if @Max_No_Of_Application is null
	set @Max_No_Of_Application = 0
	
if @L_Enc_Percentage_Of_Current_Balance is null
	set @L_Enc_Percentage_Of_Current_Balance = 0 

if @Encashment_After_Months is null
	set @Encashment_After_Months = 0 
if @Min_Leave_Encash is null	-- Added by Gadriwala Muslim 01102014
	set @Min_Leave_Encash = 0 
if @Max_Leave_Encash is null -- Added by Gadriwala Muslim 01102014
	set @Max_Leave_Encash = 0
if @Bal_After_Encash is null	-- Added by Gadriwala Muslim 01102014	
	set @Bal_After_Encash = 0 
	
Declare @ErrorMsg as varchar(100)	

If	@Encashment_After_Months > 0
	Begin
		Select @Date_Of_Join = Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_ID
		If DATEDIFF(d,@Date_Of_Join,getdate()) < DATEDIFF(d,@Date_Of_Join,DATEADD(m,@Encashment_After_Months,@Date_Of_Join))
			Begin
				Raiserror('@@You Cannot Encash Leave As Per Leave Policy@@',16,2)
				return -1
			End
	End
	
If @Min_Leave_Encash > 0
	begin
		If @Min_Leave_Encash > @Lv_Encash_App_Days
			begin
				set @ErrorMsg = '@@you cannot apply Encash Leave Less than '+ cast(@Min_Leave_Encash as varchar(10)) + ' As Per Leave Policy@@'
				RaisError(@ErrorMsg,16,2)
				return -1	
			end
    end
If @Max_Leave_Encash > 0
	begin
		If @Max_Leave_Encash < @Lv_Encash_App_Days
			begin
				set @ErrorMsg = '@@you cannot apply Encash Leave More than '+ cast(@Max_Leave_Encash as varchar(10)) + ' As Per Leave Policy@@'
				RaisError(@ErrorMsg,16,2)
				return -1	
			end
    end	
	
			Select @Total_Application = count(Lv_Encash_Apr_ID) from T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK)
										where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Leave_ID=@leave_ID 
												and Lv_Encash_Apr_Status='A'
												--and Lv_Encash_Apr_Date >=@from_Date  and Lv_Encash_Apr_Date<=@To_date -- Added this condition to count year wise by Sumit on 27122016
												and Lv_Encash_Apr_Date BETWEEN @START_YEAR AND @END_YEAR
		
			If @Default_Short_Name = 'COMP'
			begin
					If @L_Enc_Percentage_Of_Current_Balance > 0
						Begin
									
								set @Enc_DAys =  ((@Lv_Encash_Balance*@L_Enc_Percentage_Of_Current_Balance)/100)
								If @Lv_Encash_App_Days > ISNULL(@Enc_Days,0) and ISNULL(@Enc_Days,0) > 0
								begin
									set @ErrorMsg = '@@you cannot apply Encash Leave More than '+ cast(@Enc_DAys as varchar(10)) + ' As Per Leave Policy@@'
									RaisError(@ErrorMsg,16,2)
									return -1
								end		
						End	
					
					--If @Bal_After_Encash > 0 -- Added by Niraj ask by QA(13122021)
					--begin
					--		--select 123,@Bal_After_Encash, @Lv_Encash_Balance,@Lv_Encash_App_Days
					--		--if @Bal_After_Encash > (@Lv_Encash_Balance- @Lv_Encash_App_Days)
					--		--begin
					--		--	set @ErrorMsg = '@@After Encash, Leave Balance should be remaining '+ cast(@Bal_After_Encash as varchar(10)) + ' As Per Leave Policy@@'
					--		--		RaisError(@ErrorMsg,16,2)
					--		--		return -1
					--		--end
					--end					
			end
		else
			begin
					If @L_Enc_Percentage_Of_Current_Balance > 0
						Begin
								select @For_Date_Encash = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK)  where Emp_ID = @Emp_ID			

		
							SELECT @Enc_Days = ((LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100) FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN      
							(SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE EMP_ID = @Emp_ID AND FOR_DATE <=@For_Date_Encash 
							and Leave_ID=@Leave_id GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE 
							left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
							where Leave_Type='Encashable' --And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= LM.Leave_Min_Bal 
		
				
							If @Lv_Encash_App_Days > isnull(@Enc_Days,0) and isnull(@Enc_Days,0) > 0 
								Begin
									set @Lv_Encash_App_Days = @Enc_Days		
								End
		
							End
							
							--If @Bal_After_Encash > 0
							--begin
							--		--Commented by Hardik 12/01/2018 As Balance is already pass from Parameter
									
							--		--SELECT @Enc_Days = (LT.Leave_Closing - @Lv_Encash_App_Days)  FROM T0140_LEAVE_TRANSACTION LT inner JOIN      
							--		--(SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WHERE EMP_ID = @Emp_ID AND FOR_DATE <=@For_Date_Encash 
							--		--and Leave_ID=@Leave_id GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE 
							--		--left outer JOIN T0040_LEAVE_MASTER LM ON LT.LEAVE_ID = LM.LEAVE_ID 
							--		--where Leave_Type='Encashable' --And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= LM.Leave_Min_Bal 


							--	select 123,@Bal_After_Encash, @Lv_Encash_Balance,@Lv_Encash_App_Days 
							--	--if @Bal_After_Encash > @Enc_Days -- Added by Niraj ask by QA(13122021)
							--	if @Bal_After_Encash > (@Lv_Encash_Balance- @Lv_Encash_App_Days)
							--	begin

							
							--		set @ErrorMsg = '@@After Encash, Leave Balance should be remaining '+ cast(@Bal_After_Encash as varchar(10)) + ' As Per Leave Policy@@'
							--		RaisError(@ErrorMsg,16,2)
							--		return -1
							--	end
							--end	
			end	

		
		
if @tran_type ='I' 
begin			
		declare @Emp_Code as numeric
		declare @str_Emp_Code as varchar(20)
		
		--if exists(select @Lv_Encash_App_ID from dbo.T0100_Leave_Encash_Application Where Emp_ID = @Emp_ID and Application_Date = @Lv_Encash_App_Date and Cmp_id = @cmp_Id )
					--begin
					--set @Lv_Encash_App_ID = 0		
					--	return
					--end								
				
				
		select @Lv_Encash_App_ID = isnull(max(Lv_Encash_App_ID),0) +1 from dbo.T0100_Leave_Encash_Application WITH (NOLOCK)
			
			 --Temporary Comment for error
				/*select @Emp_Code = EMP_CODE From T0080_EMP_MASTER WHERE EMP_ID  = @EMP_ID
				
				
				SELECT @str_Emp_Code =DATA  FROM dbo.F_Format('0000',@Emp_Code) 
				

				select @Lv_Encash_App_Code =   cast(isnull(max(substring(Lv_Encash_App_Code,9,len(Lv_Encash_App_Code))),0) + 1 as varchar)  
						from dbo.T0100_Leave_Encash_Application  where Emp_ID = @Emp_ID
						print(@Lv_Encash_App_Code)
					
				If charindex(':',@Lv_Encash_App_Code) > 0 
					Begin
						Select @Lv_Encash_App_Code = right(@Lv_Encash_App_Code,len(@Lv_Encash_App_Code) - charindex(':',@Lv_Encash_App_Code))
					End
						if @Lv_Encash_App_Code is not null
							begin
								while len(@Lv_Encash_App_Code) <> 4
										begin
												set @Lv_Encash_App_Code = '0' + @Lv_Encash_App_Code
										end
										set @Lv_Encash_App_Code = 'LE'+ @str_Emp_Code +':'+ @Lv_Encash_App_Code  
							end
						else
						Begin
						SET @Lv_Encash_App_Code = 'LE' + @str_Emp_Code + ':' + '0001' 
						End
			
			*/
				
				--	select @Lv_Encash_App_Code= isnull(max(Lv_Encash_App_Code),0) +1 from dbo.T0100_Leave_Encash_Application
		set @Lv_Encash_App_Code = cast(@Lv_Encash_App_ID as Varchar(20))
		
		If @Max_No_Of_Application = 0 or (@Max_No_Of_Application >= ISNULL(@Total_Application,0) and @Max_No_Of_Application > 0)  --Change by Jaina 10-01-2018
			Begin 			
							
				INSERT INTO dbo.T0100_Leave_Encash_Application
						(Lv_Encash_App_ID, Cmp_ID, Emp_ID, Leave_ID, Lv_Encash_App_Date, Lv_Encash_App_Code,Lv_Encash_App_Days, Lv_Encash_App_Status, Lv_Encash_App_Comments, Login_ID, System_Date,Leave_CompOff_Dates,Leave_Encash_Amount)
				                      
				VALUES     (@Lv_Encash_App_ID,@Cmp_ID,@Emp_ID,@Leave_ID,@Lv_Encash_App_Date,@Lv_Encash_App_Code,@Lv_Encash_App_Days,@Lv_Encash_App_Status,@Lv_Encash_App_Comments,@Login_ID,@System_Date,@Leave_CompOff_dates,@Lv_Encash_Amount)
			End
		Else 
			Begin
				set @Lv_Encash_App_ID = 0
				return					
			End
		
	end 
else if @tran_type ='U' 
	Begin		
			Update  dbo.T0100_Leave_Encash_Application Set 			
				 Lv_Encash_App_ID=@Lv_Encash_App_ID
				,Cmp_ID=@Cmp_ID		                     
				,Emp_ID=@Emp_ID
				,Leave_ID=@Leave_ID
				,Lv_Encash_App_Date=@Lv_Encash_App_Date
				,Lv_Encash_App_Code=@Lv_Encash_App_Code
				,Lv_Encash_App_Days=@Lv_Encash_App_Days
				,Lv_Encash_App_Status =@Lv_Encash_App_Status
				,Lv_Encash_App_Comments= @Lv_Encash_App_Comments
				,Login_ID=@Login_ID
				,System_Date= @System_Date
				,Leave_CompOff_Dates = @Leave_CompOff_dates  -- Added by Gadriwala 01102014
				,Leave_Encash_Amount = @Lv_Encash_Amount --hardik 23/03/2016
			where Lv_Encash_App_ID=@Lv_Encash_App_ID
	End
else if @tran_type ='D'
	Begin 		
		DELETE FROM dbo.T0100_Leave_Encash_Application where Lv_Encash_App_ID = @Lv_Encash_App_ID
	End	
	RETURN




