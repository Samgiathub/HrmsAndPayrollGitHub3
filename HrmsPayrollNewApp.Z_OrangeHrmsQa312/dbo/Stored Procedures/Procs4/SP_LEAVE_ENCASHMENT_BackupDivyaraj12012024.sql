

--Created By Girish 12-FEB-2010  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LEAVE_ENCASHMENT_BackupDivyaraj12012024]  
 @leave_ID numeric(18,0) output,    
 @Cmp_ID  numeric ,    
 @From_Date Datetime,    
 @To_Date Datetime ,    
 @Branch_ID numeric,    
 @Cat_ID  numeric,    
 @Grd_ID  numeric,    
 @Type_ID numeric,    
 @Dept_ID numeric,    
 @Desig_ID numeric,    
 @Emp_Id  numeric ,    
 @Constraint varchar(5000)=''  
 ,@PBranch_ID	varchar(max)= '' --Added By Jaina 01-10-2015
 ,@PVertical_ID	varchar(max)= '' --Added By Jaina 01-10-2015
 ,@PSubVertical_ID	varchar(max)= '' --Added By Jaina 01-10-2015
 ,@PDept_ID varchar(max)=''  --Added By Jaina 01-10-2015
 ,@Upto_Date datetime  --Mukti(13052016)

AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
     
     
 IF @Branch_ID = 0      
  set @Branch_ID = null    
      
 IF @Cat_ID = 0      
  set @Cat_ID = null    
    
 IF @Grd_ID = 0      
  set @Grd_ID = null    
    
 IF @Type_ID = 0      
  set @Type_ID = null    
    
 IF @Dept_ID = 0      
  set @Dept_ID = null    
    
 IF @Desig_ID = 0      
  set @Desig_ID = null    
    
 IF @Emp_ID = 0      
  set @Emp_ID = null    
  
 IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 01-10-2015
	set @PBranch_ID = null   	
	
if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 01-10-2015
	set @PVertical_ID = null

if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 01-10-2015
	set @PsubVertical_ID = null
	
IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 01-10-2015
	set @PDept_ID = NULL	 
		
--Added By Jaina 01-10-2015 Start		
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0';
		else
			set @PVertical_ID = @PVertical_ID + ',0'
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
	Begin
		select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		if @PDept_ID is null
			set @PDept_ID = '0';
		else
			set @PDept_ID = @PDept_ID + ',0'
	End
--Added By Jaina 01-10-2015 End

 Declare @Emp_Leave_Encash Table    
 (    
  Emp_ID numeric  ,  
  Leave_ID numeric,  
  Leave_Name varchar(100),	
  Leave_Balance numeric(18,2),  
  Leave_Closing numeric(18,2)  
 )  
      
 Declare @Emp_Cons Table    
 (    
  Emp_ID numeric    
 )    
     
 if @Constraint <> ''    
  begin    
   Insert Into @Emp_Cons(Emp_ID)    
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')     
  end    
 else    
  begin    
   Insert Into @Emp_Cons(Emp_ID)    
    
   select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join     
     ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)    -- Ankit 05092014 for Same Date Increment
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID     
           
   Where Cmp_ID = @Cmp_ID     
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))    
   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)    
   and Branch_ID = isnull(@Branch_ID ,Branch_ID)
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)    
   --and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) 
   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))    
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))    
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
   and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I.Branch_ID,0))
  and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
  and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
  and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)     
   and I.Emp_ID in (select emp_id from  T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID=@Cmp_ID and Leave_ID=@Leave_ID)  
   and I.Emp_ID in     
    ( select Emp_Id from    
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry    
    where cmp_ID = @Cmp_ID   and      
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )     
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )    
    or Left_date is null and @To_Date >= Join_Date)    
    or @To_Date >= left_date  and  @From_Date <= left_date )     
end    
  
Declare @Max_No_Of_Application numeric(18, 0)
Declare @L_Enc_Percentage_Of_Current_Balance numeric(18, 2)
Declare @Total_Application numeric(18, 0)

	-- Added by Ali 22042014 -- Start
	Declare @Encashment_After_Months numeric(18,2)	
	Declare @Leave_Min_Bal numeric(18,2)
	Declare @Leave_Min_Encash numeric(18,2)
	Declare @Leave_Max_Encash numeric(18,2)
	
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
		
		select @Max_No_Of_Application = t.Max_No_Of_Application
		,@L_Enc_Percentage_Of_Current_Balance = t.L_Enc_Percentage_Of_Current_Balance
		,@Encashment_After_Months = t.Encashment_After_Months 
		,@Leave_Min_Bal = t.Leave_Min_Bal
		,@Leave_Min_Encash = t.Leave_Min_Encash
		,@Leave_Max_Encash = t.Leave_Max_Encash
		from ((select 
		case when ISNULL(temp.Max_No_Of_Application,0)=0 then lm.Max_No_Of_Application else temp.Max_No_Of_Application end as Max_No_Of_Application
		,case when ISNULL(temp.L_Enc_Percentage_Of_Current_Balance,0)=0 then lm.L_Enc_Percentage_Of_Current_Balance else temp.L_Enc_Percentage_Of_Current_Balance end as L_Enc_Percentage_Of_Current_Balance
		,case when ISNULL(temp.Encash_Appli_After_month,0)=0 then lm.Encashment_After_Months  else temp.Encash_Appli_After_month end as Encashment_After_Months
		,case when ISNULL(temp.Bal_After_Encash,0)=0 then lm.Leave_Min_Bal  else temp.Bal_After_Encash end as Leave_Min_Bal
		,case when ISNULL(temp.Min_Leave_Encash,0)=0 then lm.Leave_Min_Encash   else temp.Min_Leave_Encash end as Leave_Min_Encash
		,case when ISNULL(temp.Max_Leave_Encash,0)=0 then lm.Leave_Max_Encash  else temp.Max_Leave_Encash end as Leave_Max_Encash
		from T0040_Leave_MASTER LM WITH (NOLOCK) left join 
		(	Select Max_No_Of_Application,L_Enc_Percentage_Of_Current_Balance,Encash_Appli_After_month,
			Bal_After_Encash,Min_Leave_Encash,Max_Leave_Encash,Leave_ID from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID = @Leave_Id 
			and Cmp_ID = @Cmp_ID  and Grd_ID in (Select I.Grd_ID from   dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
			(SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment IM WITH (NOLOCK)
			WHERE Increment_Effective_date <= @date GROUP BY emp_ID ) Qry ON I.Emp_ID = Qry.Emp_ID 
			AND I.Increment_ID = Qry.Increment_ID INNER JOIN
			dbo.T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = Qry.Emp_ID 
			where em.Cmp_ID = @Cmp_Id and em.Emp_ID = @Emp_Id)
		) as temp on LM.leave_id = temp.leave_id 
		where LM.Leave_ID = @Leave_Id and Leave_Type = 'Encashable')) as t		
	-- Added by Ali 22042014 -- End

if @Max_No_Of_Application is null
	set @Max_No_Of_Application = 0
	
if @L_Enc_Percentage_Of_Current_Balance is null
	set @L_Enc_Percentage_Of_Current_Balance = 0  
  
Declare @L_Emp_ID numeric(18,0)  
Declare @Default_Short_Name as varchar(25)
select  @Default_Short_Name = isnull(Default_Short_Name,'') from T0040_LEave_Master WITH (NOLOCK) where Cmp_ID = @cmp_ID and Leave_ID = @leave_ID
  create table #temp_CompOff
		(
			Leave_opening	decimal(18,2),
			Leave_Used		decimal(18,2),
			Leave_Closing	decimal(18,2),
			Leave_Code		varchar(max),
			Leave_Name		varchar(max),
			Leave_ID		numeric,
			CompOff_String  varchar(max) default null -- Added by Gadriwala 18022015
		)	
Declare curLeaveEncash cursor for select Emp_ID from @Emp_Cons Order by Emp_ID  
open curLeaveEncash  
fetch next from curLeaveEncash into @L_Emp_ID  
while @@fetch_status = 0  
    begin  
       
		Select @Total_Application = count(Lv_Encash_App_ID) from T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@L_Emp_ID and Leave_ID=@leave_ID and Lv_Encash_Apr_Status='A'
		if @Default_Short_Name <> 'COMP'
        begin
			declare @For_Date_Encash as datetime    
		
					If @Max_No_Of_Application = 0
						Begin
							If @L_Enc_Percentage_Of_Current_Balance > 0
								Begin
									select @For_Date_Encash = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID = @L_Emp_ID  
									AND FOR_DATE <=@Upto_Date and Leave_ID=@Leave_id --Mukti(16052016)		
									
									insert into @Emp_Leave_Encash   
									SELECT @L_Emp_ID,@Leave_ID,LM.Leave_Name,LT.Leave_Closing,((LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100)as Leave_Closing 
									FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)     
									--inner JOIN (SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WHERE EMP_ID = @L_Emp_ID AND FOR_DATE <=@Upto_Date  --commented By Mukti(16052016)
									--and Leave_ID=@Leave_id GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE 
									INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
									where Leave_Type='Encashable' And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= @Leave_Min_Bal  and (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100  > 0.25
									 --Mukti(13052016)start
									and LT.Emp_ID=@L_Emp_ID and LT.Leave_ID=@Leave_id and lt.For_Date = @For_Date_Encash  
									And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= isnull(@Leave_Min_Encash,0)
									--Mukti(13052016)end
								End
							Else
								Begin
									--select @For_Date_Encash = max(For_Date) From T0140_LEAVE_TRANSACTION  where Emp_ID = @L_Emp_ID   			
									
									select @For_Date_Encash = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID = @L_Emp_ID  
									AND FOR_DATE <=@Upto_Date and Leave_ID=@Leave_id --Mukti(16052016)
									
									insert into @Emp_Leave_Encash   
									SELECT @L_Emp_ID,@Leave_ID,LM.Leave_Name,LT.Leave_Closing,(LT.Leave_Closing-isnull(@Leave_Min_Bal,0))as Leave_Closing 
									FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
									--inner JOIN (SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WHERE EMP_ID = @L_Emp_ID AND  --commented By Mukti(16052016)
									--FOR_DATE <= @Upto_Date and Leave_ID=@Leave_id GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE 
									INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
									where Leave_Type='Encashable' And LT.Leave_Closing >= isnull(@Leave_Min_Bal,0)
									--Mukti(13052016)start
									and LT.Emp_ID=@L_Emp_ID and LT.Leave_ID=@Leave_id And lt.For_Date = @For_Date_Encash 
									AND LT.Leave_Closing >= isnull(@Leave_Min_Encash,0)
									--Mukti(13052016)end
								End				
						End
					Else
						Begin    
							If @Max_No_Of_Application > ISNULL(@Total_Application,0)
								Begin
									If @L_Enc_Percentage_Of_Current_Balance > 0
										Begin
											--select @For_Date_Encash = max(For_Date) From T0140_LEAVE_TRANSACTION  where Emp_ID = @L_Emp_ID   			
											select @For_Date_Encash = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID = @L_Emp_ID  
											AND FOR_DATE <=@Upto_Date and Leave_ID=@Leave_id --Mukti(16052016)	
											print 46
											insert into @Emp_Leave_Encash   
											SELECT @L_Emp_ID,@Leave_ID,LM.Leave_Name,LT.Leave_Closing,((LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100)as Leave_Closing 
											FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
											--inner JOIN (SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WHERE EMP_ID = @L_Emp_ID AND FOR_DATE <=@Upto_Date  --commented By Mukti(16052016)
											--and Leave_ID=@Leave_id GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE 
											INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
											where Leave_Type='Encashable' And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= @Leave_Min_Bal 
											 --Mukti(13052016)start
											and LT.Emp_ID=@L_Emp_ID and LT.Leave_ID=@Leave_id And lt.For_Date = @For_Date_Encash 
											And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= isnull(@Leave_Min_Encash,0) 
											 --Mukti(13052016)end
										End
									Else
										Begin
											--select @For_Date_Encash = max(For_Date) From T0140_LEAVE_TRANSACTION  where Emp_ID = @L_Emp_ID  
											select @For_Date_Encash = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID = @L_Emp_ID  
											AND FOR_DATE <=@Upto_Date and Leave_ID=@Leave_id --Mukti(16052016)												 			
												
																	
											insert into @Emp_Leave_Encash   
											SELECT @L_Emp_ID,@Leave_ID,LM.Leave_Name,LT.Leave_Closing,(LT.Leave_Closing-isnull(@Leave_Min_Bal,0))as Leave_Closing 
											FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
											--inner JOIN (SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WHERE EMP_ID = @L_Emp_ID AND FOR_DATE <=@Upto_Date  --commented By Mukti(16052016)
											--and Leave_ID=@Leave_id GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE 
											INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
											where Leave_Type='Encashable' And LT.Leave_Closing >= isnull(@Leave_Min_Bal,0)
											 --Mukti(13052016)start
											and LT.Emp_ID=@L_Emp_ID and LT.Leave_ID=@Leave_id AND lt.For_Date = @For_Date_Encash 
											And LT.Leave_Closing >= isnull(@Leave_Min_Encash,0)
											 --Mukti(13052016)end
										End
								End
						End
					End
		else
			begin
					delete from #temp_CompOff
					exec GET_COMPOFF_DETAILS @Upto_Date,@Cmp_ID,@L_Emp_ID,@Leave_ID,0,0,2
				
				If @Max_No_Of_Application = 0
					Begin
						If @L_Enc_Percentage_Of_Current_Balance > 0
							Begin
									Insert into @Emp_Leave_Encash
										select @L_Emp_ID,leave_ID,Leave_Name,Leave_Closing,(((Leave_Closing * @L_Enc_Percentage_Of_Current_Balance)/100) - @Leave_Min_Bal)  
										from #temp_CompOff where (((Leave_Closing * @L_Enc_Percentage_Of_Current_Balance)/100) - @Leave_Min_Bal) > 0.25
													
							end
						else
							begin
										Insert into @Emp_Leave_Encash
											select @L_Emp_ID,leave_ID,Leave_Name,Leave_Closing,(Leave_Closing - @Leave_Min_Bal)  
											from #temp_CompOff where (Leave_Closing - @Leave_Min_Bal) > 0.25
							end
					end
				else
					begin
						If @Max_No_Of_Application > ISNULL(@Total_Application,0)
							Begin
								If @L_Enc_Percentage_Of_Current_Balance > 0
									begin
										Insert into @Emp_Leave_Encash
										select @L_Emp_ID,leave_ID,Leave_Name,Leave_Closing,((Leave_Closing * @L_Enc_Percentage_Of_Current_Balance)/100) - @Leave_Min_Bal  from #temp_CompOff 
										where (((Leave_Closing * @L_Enc_Percentage_Of_Current_Balance)/100) - @Leave_Min_Bal)> 0.25
									end
								else
									begin
										Insert into @Emp_Leave_Encash
										select @L_Emp_ID,leave_ID,Leave_Name,Leave_Closing,(Leave_Closing - @Leave_Min_Bal)  from #temp_CompOff 
										where (Leave_Closing - @Leave_Min_Bal) > 0.25
									end
							end	
					end
				
			end
		fetch next from curLeaveEncash into @L_Emp_ID  
   end   
close curLeaveEncash  
deallocate curLeaveEncash  
    
  select Emp_Full_Name,Emp_Code ,ENE.* , E.Alpha_Emp_Code from @Emp_Leave_Encash ENE 
  inner join t0080_emp_master E WITH (NOLOCK) on ENE.Emp_ID=E.Emp_ID  
  where ENE.Leave_Closing > 0  --Mukti(13052016)
      
RETURN  




