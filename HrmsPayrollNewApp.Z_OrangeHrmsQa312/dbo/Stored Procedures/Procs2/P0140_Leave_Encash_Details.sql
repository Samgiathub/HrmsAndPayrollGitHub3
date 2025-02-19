

CREATE PROCEDURE  [dbo].[P0140_Leave_Encash_Details]
	 @CMP_ID		NUMERIC 
	,@EMP_ID		NUMERIC
	,@Leave_ID	Numeric
	,@Upto_date datetime = null --Added by Jaina 21-07-2017
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	
	declare @For_Date as datetime
	
	Declare @Max_No_Of_Application numeric(18, 0)
	Declare @L_Enc_Percentage_Of_Current_Balance numeric(18, 2)
	Declare @Total_Application numeric(18, 0)
	
	-- Added by Ali 22042014 -- Start
	Declare @Encashment_After_Months numeric(18,2)	
	Declare @Leave_Min_Bal numeric(18,2)
	Declare @Leave_Min_Encash numeric(18,2)
	Declare @Leave_Max_Encash numeric(18,2)
	
		Declare @First_Min_Bal_then_Percent_Curr_Balance tinyint
		Set @First_Min_Bal_then_Percent_Curr_Balance = 0
	--Select @Max_No_Of_Application=Max_No_Of_Application
	--, @L_Enc_Percentage_Of_Current_Balance=L_Enc_Percentage_Of_Current_Balance 
	--from T0040_LEAVE_MASTER where Leave_ID=@leave_ID  


	
		Declare @Year as numeric
		Set @Year = YEAR(GETDATE())
		
		IF MONTH(GETDATE())> 3
		BEGIN
			SET @Year = @Year + 1
		END
		
				
		Declare @date as varchar(20)  
		Set @date = '31-Mar-'+ convert(varchar(5),@Year)  
						
		DECLARE @START_YEAR DATETIME;
		DECLARE @END_YEAR DATETIME;
		SET @END_YEAR = CAST(@date AS DATETIME)
		SET @START_YEAR = DATEADD(d, 1,DATEADD(yyyy, -1, @END_YEAR))
		
		
		select @Max_No_Of_Application = t.Max_No_Of_Application
		,@L_Enc_Percentage_Of_Current_Balance = t.L_Enc_Percentage_Of_Current_Balance
		,@Encashment_After_Months = t.Encashment_After_Months 
		,@Leave_Min_Bal = t.Leave_Min_Bal
		,@Leave_Min_Encash = t.Leave_Min_Encash
		,@Leave_Max_Encash = t.Leave_Max_Encash
		,@First_Min_Bal_then_Percent_Curr_Balance = First_Min_Bal_then_Percent_Curr_Balance
		from ((select 
		case when ISNULL(temp.Max_No_Of_Application,0)=0 then lm.Max_No_Of_Application else temp.Max_No_Of_Application end as Max_No_Of_Application
		,case when ISNULL(temp.L_Enc_Percentage_Of_Current_Balance,0)=0 then lm.L_Enc_Percentage_Of_Current_Balance else temp.L_Enc_Percentage_Of_Current_Balance end as L_Enc_Percentage_Of_Current_Balance
		,case when ISNULL(temp.Encash_Appli_After_month,0)=0 then lm.Encashment_After_Months  else temp.Encash_Appli_After_month end as Encashment_After_Months
		,case when ISNULL(temp.Bal_After_Encash,0)=0 then lm.Leave_Min_Bal  else temp.Bal_After_Encash end as Leave_Min_Bal
		,case when ISNULL(temp.Min_Leave_Encash,0)=0 then lm.Leave_Min_Encash   else temp.Min_Leave_Encash end as Leave_Min_Encash
		,case when ISNULL(temp.Max_Leave_Encash,0)=0 then lm.Leave_Max_Encash  else temp.Max_Leave_Encash end as Leave_Max_Encash,
		First_Min_Bal_then_Percent_Curr_Balance
		from T0040_Leave_MASTER LM WITH (NOLOCK) left join 
		(	Select Max_No_Of_Application,L_Enc_Percentage_Of_Current_Balance,Encash_Appli_After_month,
			Bal_After_Encash,Min_Leave_Encash,Max_Leave_Encash,Leave_ID from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID = @Leave_Id 
			and Cmp_ID = @Cmp_ID  and Grd_ID in (Select I.Grd_ID from   dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
			(SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment IM  WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
			WHERE Increment_Effective_date <= @date GROUP BY emp_ID ) Qry ON I.Emp_ID = Qry.Emp_ID 
			AND I.Increment_ID = Qry.Increment_ID INNER JOIN --Changed by Hardik 09/09/2014 for Same Date Increment
			dbo.T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = Qry.Emp_ID 
			where em.Cmp_ID = @Cmp_Id and em.Emp_ID = @Emp_Id)
		) as temp on LM.leave_id = temp.leave_id 
		where LM.Leave_ID = @Leave_Id and Leave_Type = 'Encashable')) as t		
	-- Added by Ali 22042014 -- End
	
	Select @Total_Application = count(Lv_Encash_App_ID) from T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK)
	where Cmp_ID=@Cmp_ID and Emp_ID=@EMP_ID and Leave_ID=@leave_ID and Lv_Encash_Apr_Status='A'
			and Lv_Encash_Apr_Date BETWEEN @START_YEAR AND @END_YEAR
	
	if @Max_No_Of_Application is null
		set @Max_No_Of_Application = 0
		
	if @L_Enc_Percentage_Of_Current_Balance is null
		set @L_Enc_Percentage_Of_Current_Balance = 0 
	

	--Select @Max_No_Of_Application,@Total_Application
	--return
	
	If @Max_No_Of_Application = 0
		Begin			
			--select @For_Date = max(For_Date) From T0140_LEAVE_TRANSACTION  where Emp_ID = @Emp_ID And Leave_ID=@Leave_Id
			--Added by Jaina 21-07-2017
			--Added by Jaina 14-08-2017 start
			 
			If @L_Enc_Percentage_Of_Current_Balance > 0
			begin
					select @For_Date = max(For_Date) From T0140_LEAVE_TRANSACTION  where Emp_ID = @Emp_ID  
							AND FOR_DATE <=IsNull(@Upto_Date,getdate()) and Leave_ID=@Leave_id 
									
					If @First_Min_Bal_then_Percent_Curr_Balance = 0
						Begin
							If exists(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN 
										( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
												WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE And Leave_ID=@Leave_Id
												GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
											LT.FOR_DATE = Q.FOR_DATE left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
										where Leave_Type='Encashable' And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= @Leave_Min_Bal And LT.Leave_ID = @Leave_ID)
										--where Leave_Type='Encashable' And ((LT.Leave_Closing - LT.Leave_Encash_Days ) * @L_Enc_Percentage_Of_Current_Balance)/100 >= @Leave_Min_Bal And LT.Leave_ID = @Leave_ID)
							BEGIN
								SELECT Leave_name,dbo.F_Lower_Round(((LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100),LT.Cmp_ID) as Leave_Closing FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN   --Change by Jaina 10-01-2018 Leave Balance : 25  and Encash Percentage : 50% Encash Leave : 12.5 take 6 encash leave after approve other leave that time Correct 6.5 balace set (Wrong set 3.5)
									( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
								WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE And Leave_ID=@Leave_Id
									GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
								LT.FOR_DATE = Q.FOR_DATE left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
								where Leave_Type='Encashable' And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= @Leave_Min_Bal And LT.Leave_ID = @Leave_ID 							
							End
							Else
								BEGIN
									SELECT Leave_Name, 0 as Leave_Closing From T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID=@Leave_Id
								END
						End
					Else
						Begin
							If exists(SELECT 1
										FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN 
											( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
										WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE And Leave_ID=@Leave_Id
											GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
									LT.FOR_DATE = Q.FOR_DATE 
											left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
									where Leave_Type='Encashable' And LT.Leave_Closing >= @Leave_Min_Bal And LT.Leave_ID = @Leave_ID)
								Begin
										SELECT Leave_name,dbo.F_Lower_Round((((LT.Leave_Closing - @Leave_Min_Bal) * @L_Enc_Percentage_Of_Current_Balance)/100),LT.Cmp_ID) as Leave_Closing 
										FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN 
											( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
										WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE And Leave_ID=@Leave_Id
											GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
											LT.FOR_DATE = Q.FOR_DATE left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
										where Leave_Type='Encashable' And LT.Leave_Closing >= @Leave_Min_Bal And LT.Leave_ID = @Leave_ID							
								End
							Else
								Begin
									SELECT Leave_Name, 0 as Leave_Closing From T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID=@Leave_Id
								End
						End
			end --Added by Jaina 14-08-2017 end
			else
			begin
				select @For_Date = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID = @Emp_ID  
										AND FOR_DATE <= Isnull(@Upto_Date,getdate()) and Leave_ID=@Leave_id 
										
				If EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN 
							( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
							WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE And Leave_ID=@Leave_Id
							GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
						LT.FOR_DATE = Q.FOR_DATE left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID where Leave_Type='Encashable' And LT.Leave_Closing >= @Leave_Min_Bal And LT.Leave_ID = @Leave_ID)
					BEGIN
						
						SELECT Leave_name,dbo.F_Lower_Round((LT.Leave_Closing- @Leave_Min_Bal ),LT.Cmp_ID)as Leave_Closing FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN 
						( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
							WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE And Leave_ID=@Leave_Id
						GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
						LT.FOR_DATE = Q.FOR_DATE left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
						where Leave_Type='Encashable' And LT.Leave_Closing >= @Leave_Min_Bal And LT.Leave_ID = @Leave_ID 
					End
				Else
					BEGIN
						SELECT Leave_Name, 0 as Leave_Closing From T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID=@Leave_Id
					END	
			end
		End
	Else
		Begin
			
			If @Max_No_Of_Application >= ISNULL(@Total_Application,0)	-- CHanged by Divyaraj Kiri on 11/01/2024
				Begin					
				
					If @L_Enc_Percentage_Of_Current_Balance > 0
						Begin
							--select @For_Date = max(For_Date) From T0140_LEAVE_TRANSACTION  where Emp_ID = @Emp_ID And Leave_ID=@Leave_Id					
							--Added by Jaina 21-07-2017
							select @For_Date = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID = @Emp_ID  
									AND FOR_DATE <=IsNull(@Upto_Date,getdate()) and Leave_ID=@Leave_id 
									
							If exists(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN 
										( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
										WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE And Leave_ID=@Leave_Id
										GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
									LT.FOR_DATE = Q.FOR_DATE left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
									where Leave_Type='Encashable' And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= @Leave_Min_Bal And LT.Leave_ID = @Leave_ID)
								BEGIN
									
									SELECT Leave_name,dbo.F_Lower_Round(((LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100),LT.Cmp_ID)  as Leave_Closing  --Change by Jaina 10-01-2018 Leave Balance : 25  and Encash Percentage : 50% Encash Leave : 12.5 take 6 encash leave after approve other leave that time Correct 6.5 balace set (Wrong set 3.5)
									FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN 
									( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
										WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE And Leave_ID=@Leave_Id
									GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
									LT.FOR_DATE = Q.FOR_DATE left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
									where Leave_Type='Encashable' And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= @Leave_Min_Bal And LT.Leave_ID = @Leave_ID 							
								End
							Else
								BEGIN
									SELECT Leave_Name, 0 as Leave_Closing From T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID=@Leave_Id
								END
						End
					Else
						Begin
							--select @For_Date = max(For_Date) From T0140_LEAVE_TRANSACTION  where Emp_ID = @Emp_ID And Leave_ID=@Leave_Id					
							--Added by Jaina 21-07-2017
							select @For_Date = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK)  where Emp_ID = @Emp_ID  
									AND FOR_DATE <=IsNull(@Upto_Date,getdate()) and Leave_ID=@Leave_id 
									

							If exists(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN 
										( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
										WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE And Leave_ID=@Leave_Id
										GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
									LT.FOR_DATE = Q.FOR_DATE left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
									WHERE Leave_Type='Encashable' And LT.Leave_ID = @Leave_ID)
								BEGIN
									SELECT Leave_name,dbo.F_Lower_Round(LT.Leave_Closing,LT.Cmp_ID) AS Leave_Closing--((LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100)as Leave_Closing 
									FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN 
									( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
										WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE And Leave_ID=@Leave_Id
									GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
									LT.FOR_DATE = Q.FOR_DATE left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
									where Leave_Type='Encashable' And LT.Leave_ID = @Leave_ID								
								End
							Else
								BEGIN
									SELECT Leave_Name, 0 as Leave_Closing From T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Leave_ID=@Leave_Id
									
								END 							
							
						End	
				End
			Else
				Begin 
					raiserror('You cant add more than one leave encashment approval as per policy',16,2)
					return -1
				End				
		End
RETURN

