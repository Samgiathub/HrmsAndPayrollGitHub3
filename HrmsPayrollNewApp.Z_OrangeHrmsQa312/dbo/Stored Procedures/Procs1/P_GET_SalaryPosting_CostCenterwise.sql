-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 08/01/2025
-- Description:	For Getting the Cost Center wise Total Amount
-- =============================================
CREATE PROCEDURE  [dbo].[P_GET_SalaryPosting_CostCenterwise]
	 @Salary_Parameter nvarchar(max)
	,@is_Manual tinyint = 0
	,@cmp_id numeric(18)
	,@from_date datetime
	,@to_date datetime
	,@ID varchar(100) = ''
	,@BackEnd_Salary TINYINT = 0
AS
BEGIN
	CREATE TABLE #Pre_Salary_Data
	(
		Type nvarchar(50)
		,M_Sal_Tran_ID nvarchar(50) 
		,Emp_Id   Numeric      
		,Cmp_ID   Numeric      
		,Sal_Generate_Date nvarchar(50) 
		,Month_St_Date  nvarchar(50)
		,Month_End_Date nvarchar(50)
		,ErrRaise   Varchar(100) 
		--,Is_Negetive  Varchar(1)  
		--,User_Id numeric(18,0) 	
		--,IP_Address varchar(30) 
		,Process_type varchar(30) 
	)
	declare @Sal_Param as nvarchar(max)
				 
	  
	declare curPreSalar cursor for                    
		SELECT part from dbo.SplitString2(@Salary_Parameter,'$')
	open curPreSalar                      
	fetch next from curPreSalar into @Sal_Param
	WHILE @@fetch_status = 0                    
		BEGIN
				
				insert into #Pre_Salary_Data
					SELECT  'Manual' as Cnt , [1],[2],[3],[4],[5],[6],[7],[8]
					 from 
					 (
					 SELECT ID, part from  
					 dbo.SplitString2(@Sal_Param,'#') 
					 ) as Table1
					 PIVOT
					 (
					 MAX(Part)
					 FOR ID in ([1],[2],[3],[4],[5],[6],[7],[8])
					 ) as PIVOTData

			fetch next from curPreSalar into @Sal_Param		
		END
	close curPreSalar        
	Deallocate curPreSalar  

	
	Declare @Basic_Ad_ID int
	Declare @Net_Ad_ID int
	select top 1 @Basic_Ad_ID = Ad_id from T9999_Ax_Mapping where Cmp_id = @cmp_id  and Head_Name = 'Basic Salary'
	select top 1 @Net_Ad_ID = Ad_id from T9999_Ax_Mapping where Cmp_id = @cmp_id  and Head_Name = 'Net Salary'
	--select * from T9999_Ax_Mapping where Cmp_id = @cmp_id and Ad_id = 2003
	DECLARE @Pos_Req_ID INT = 0
	DECLARE @Pos_Req_M_ID INT = 0
	Declare @login_ID INT
	Declare @Process_Type NVARCHAR(20)
	select Top 1 @login_ID = ErrRaise from #Pre_Salary_Data
	
	select @Pos_Req_ID = ISNULL(MAX(POst_req_ID),0) + 1  from T0210_MONTHLY_Sal_POS_DETAIL
	
	select top 1 @Process_Type = PT.Payment_Process_name from #Pre_Salary_Data PSD
	LEFT JOIN T0301_Payment_Process_Type PT ON PT.tran_id = (PSD.Process_type-9000)

	Declare @Empstr as nvarchar(MAx)
	declare @dynamiccap as varchar(50)
	Declare @strErr as nvarchar(100)

	select PSD.Emp_Id,Q_I.Center_ID,Q_I.Segment_ID INTO #EMp_Center from #Pre_Salary_Data PSD
	LEFT JOIN
		( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID,I.Center_ID,I.Segment_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							WHERE Increment_Effective_date <= @To_Date
							AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON PSD.EMP_ID = Q_I.EMP_ID

						IF EXISTs(Select 1  from #EMp_Center where Center_ID IS NULL)
						BEGIN
							Select @Empstr = coalesce(@Empstr + ' , ', '') +  convert(varchar(15),Emp_Id)  from #EMp_Center where Center_ID IS NULL group by Emp_Id
							
							SET @strErr = '@@Please Add Cost Center for Employees ' + @Empstr + '@@';
							Raiserror(@strErr,18,2)
							return -1
						END
						IF EXISTs(Select 1  from #EMp_Center where Segment_ID IS NULL)
						BEGIN
							Select @Empstr = coalesce(@Empstr + ' , ', '') +  convert(varchar(15),Emp_Id)  from #EMp_Center where Segment_ID IS NULL group by Emp_Id
							select @dynamiccap = Alias from T0040_CAPTION_SETTING where Cmp_Id = 1 and caption in ('Business Segment')	
							SET @strErr = '@@Please Add ' + @dynamiccap +' for Employees' + @Empstr + ' in Emp_Increment@@';
							Raiserror(@strErr,16,1)
							return -1
						END

							
							select * INTO #EMp_AD_ID from (
							select PSD.Emp_Id,@Basic_Ad_ID as 'Ad_id','Basic Salary' as 'Ad_Name' from #Pre_Salary_Data PSD
							UNION ALL
							select PSD.Emp_Id,@Net_Ad_ID as 'Ad_id','Net Salary' as 'Ad_Name' from #Pre_Salary_Data PSD
							UNION ALL
							select PSD.Emp_Id,AX.Ad_id,ADM.AD_NAME 'Ad_Name' from 
							T0200_MONTHLY_SALARY M with (NOLOCK) 
							INNER JOIN
							#Pre_Salary_Data PSD ON PSD.Emp_Id = M.Emp_ID AND M.Month_St_Date  = convert(DATETIME, PSD.Month_St_Date,103)  AND M.Month_End_Date = convert(DATETIME, PSD.Month_End_Date,103)
							INNER JOIN
							T0080_EMP_MASTER E WITH (NOLOCK) ON M.EMP_ID =E.EMP_ID  
							INNER JOIN
							( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID,I.Center_ID,I.Segment_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
											( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
												WHERE Increment_Effective_date <= @To_Date
												AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON
											I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON PSD.EMP_ID = Q_I.EMP_ID
							INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON MAD.Emp_ID = PSD.Emp_Id and MAD.Sal_Tran_ID = M.Sal_Tran_ID 
							LEFT JOIN T9999_Ax_Mapping  AX ON AX.Ad_id = MAD.AD_ID AND AX.Segment_ID = Q_I.Segment_ID AND AX.Cmp_id = @cmp_id
							INNER JOIN T0050_AD_MASTER ADM ON ADM.CMP_ID = @cmp_id AND ADM.AD_ID = MAD.AD_ID
							 ) T ORDER BY T.Emp_Id
							
								
							--select Ad_Name from #EMp_AD_ID  where Ad_id IS NULL group by Ad_Name
							IF EXISTs(Select 1  from #EMp_AD_ID where Ad_id IS  NULL)
						BEGIN
							select @Empstr = coalesce(@Empstr + ' , ', '') +  convert(varchar(15),Ad_Name) from #EMp_AD_ID where Ad_id IS NULL group by Ad_Name
							SET @strErr = '@@Ax Mapping Not Created (' + @Empstr + ' )@@';
							--Select Emp_Id  from #EMp_AD_ID where Ad_id IS NULL 
							Raiserror(@strErr,18,2)
							Return -1
						END

						select PSD.Emp_Id,AX.Ad_id,ADM.AD_NAME 'Ad_Name',AX.Account  INTO #tmp_Account from 
							T0200_MONTHLY_SALARY M with (NOLOCK) 
							INNER JOIN
							#Pre_Salary_Data PSD ON PSD.Emp_Id = M.Emp_ID AND M.Month_St_Date  = convert(DATETIME, PSD.Month_St_Date,103)  AND M.Month_End_Date = convert(DATETIME, PSD.Month_End_Date,103)
							INNER JOIN
							T0080_EMP_MASTER E WITH (NOLOCK) ON M.EMP_ID =E.EMP_ID  
							INNER JOIN
							( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID,I.Center_ID,I.Segment_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
											( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
												WHERE Increment_Effective_date <= @To_Date
												AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON
											I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON PSD.EMP_ID = Q_I.EMP_ID
							INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON MAD.Emp_ID = PSD.Emp_Id and MAD.Sal_Tran_ID = M.Sal_Tran_ID 
							LEFT JOIN T9999_Ax_Mapping  AX ON AX.Ad_id = MAD.AD_ID AND AX.Segment_ID = Q_I.Segment_ID AND AX.Cmp_id = @cmp_id
							INNER JOIN T0050_AD_MASTER ADM ON ADM.CMP_ID = @cmp_id AND ADM.AD_ID = MAD.AD_ID
							WHERE (AX.Account = '' OR AX.Account IS NULL)

							IF EXISTs(Select 1  from #tmp_Account where (Account IS  NULL OR Account = ''))
						BEGIN
							select @Empstr = coalesce(@Empstr + ' , ', '') +  convert(varchar(15),Ad_Name) from #tmp_Account where (Account IS  NULL OR Account = '') group by Ad_Name
							SET @strErr = '@@Account NO NOt Added For (' + @Empstr + ' )@@';
							--Select Emp_Id  from #EMp_AD_ID where Ad_id IS NULL 
							Raiserror(@strErr,18,2)
							Return -1
						END
						return

		INSERT INTO T0210_MONTHLY_Sal_POS_DETAIL (EMP_ID,AD_ID,Account,Center_Code , Segment_ID,Ammount,POst_req_ID,Post__Date,Branch,Allowance_Name)
	select *   from (						

	SELECT M.Emp_ID,
		@Basic_Ad_ID as  AD_ID
		,AX.Account
        ,CC.Center_Code  
		,Q_I.Segment_ID
		,(M.Salary_Amount) AS [Total_Amount]
		,@Pos_Req_ID as 'POst_req_ID'
		,M.Month_St_Date 
		,BM.Branch_Name
		,'Basic Salary' AD_NAME
    FROM 
        T0200_MONTHLY_SALARY M with (NOLOCK) 
		INNER JOIN
		#Pre_Salary_Data PSD ON PSD.Emp_Id = M.Emp_ID AND M.Month_St_Date  = convert(DATETIME, PSD.Month_St_Date,103)  AND M.Month_End_Date = convert(DATETIME, PSD.Month_End_Date,103)
		INNER JOIN
		T0080_EMP_MASTER E WITH (NOLOCK) ON M.EMP_ID =E.EMP_ID  
		INNER JOIN
		( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID,I.Center_ID,I.Segment_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							WHERE Increment_Effective_date <= @To_Date
							AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON PSD.EMP_ID = Q_I.EMP_ID
		INNER JOIN T0030_BRANCH_MASTER BM ON BM.Cmp_ID = @cmp_id AND BM.Branch_ID = Q_I.Branch_ID
		INNER JOIN T0040_COST_CENTER_MASTER CC WITH (NOLOCK) ON Q_I.Center_ID = CC.Center_ID
		INNER JOIN T9999_Ax_Mapping  AX ON AX.Ad_id = @Basic_Ad_ID AND AX.Segment_ID = Q_I.Segment_ID AND AX.Cmp_id = @cmp_id
		--INNER JOIN T0050_AD_MASTER AM ON AM.CMP_ID= @cmp_id AND AM.AD_ID = AX.Ad_id
		--INNER JOIN T0301_Payment_Process_Type PT WITH (NOLOCK) ON AX.Type = PT.Payment_Process_name

	UNION ALL

	SELECT M.Emp_ID,
		@Net_Ad_ID as  AD_ID
		,AX.Account
        ,CC.Center_Code  
		,Q_I.Segment_ID
		,(M.Net_Amount) AS [Total_Amount]
		,@Pos_Req_ID as 'POst_req_ID'
		,M.Month_St_Date 
		,BM.Branch_Name
		,'Net Salary' as AD_NAME
    FROM 
        T0200_MONTHLY_SALARY M with (NOLOCK) 
		INNER JOIN
		#Pre_Salary_Data PSD ON PSD.Emp_Id = M.Emp_ID AND M.Month_St_Date  = convert(DATETIME, PSD.Month_St_Date,103)  AND M.Month_End_Date = convert(DATETIME, PSD.Month_End_Date,103)
		INNER JOIN
		T0080_EMP_MASTER E WITH (NOLOCK) ON M.EMP_ID =E.EMP_ID  
		INNER JOIN
		( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID,I.Center_ID,I.Segment_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							WHERE Increment_Effective_date <= @To_Date
							AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON PSD.EMP_ID = Q_I.EMP_ID
		INNER JOIN T0030_BRANCH_MASTER BM ON BM.Cmp_ID = @cmp_id AND BM.Branch_ID = Q_I.Branch_ID
		INNER JOIN T0040_COST_CENTER_MASTER CC WITH (NOLOCK) ON Q_I.Center_ID = CC.Center_ID
		INNER JOIN T9999_Ax_Mapping  AX ON AX.Ad_id = @Net_Ad_ID AND AX.Segment_ID = Q_I.Segment_ID AND AX.Cmp_id = @cmp_id
		--INNER JOIN T0050_AD_MASTER AM ON AM.CMP_ID= @cmp_id AND AM.AD_ID = AX.Ad_id
		--INNER JOIN T0301_Payment_Process_Type PT WITH (NOLOCK) ON AX.Type = PT.Payment_Process_name

	UNION ALL

	SELECT M.Emp_ID,
		MAD.AD_ID
		,AX.Account
        ,CC.Center_Code
		,Q_I.Segment_ID
		,(MAD.M_AD_Amount) AS [Total_Amount]
		,@Pos_Req_ID as 'POst_req_ID'
		,M.Month_St_Date  
		,BM.Branch_Name
		,AM.AD_NAME
    FROM 
        T0200_MONTHLY_SALARY M with (NOLOCK) 
		INNER JOIN
		#Pre_Salary_Data PSD ON PSD.Emp_Id = M.Emp_ID AND M.Month_St_Date  = convert(DATETIME, PSD.Month_St_Date,103)  AND M.Month_End_Date = convert(DATETIME, PSD.Month_End_Date,103)
		INNER JOIN
		T0080_EMP_MASTER E WITH (NOLOCK) ON M.EMP_ID =E.EMP_ID  
		INNER JOIN
		( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID,I.Center_ID,I.Segment_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							WHERE Increment_Effective_date <= @To_Date
							AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON PSD.EMP_ID = Q_I.EMP_ID
		INNER JOIN T0030_BRANCH_MASTER BM ON BM.Cmp_ID = @cmp_id AND BM.Branch_ID = Q_I.Branch_ID
		INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON MAD.Emp_ID = PSD.Emp_Id and MAD.Sal_Tran_ID = M.Sal_Tran_ID 
		INNER JOIN T0040_COST_CENTER_MASTER CC WITH (NOLOCK) ON Q_I.Center_ID = CC.Center_ID
		INNER JOIN T9999_Ax_Mapping  AX ON AX.Ad_id = MAD.AD_ID AND AX.Segment_ID = Q_I.Segment_ID AND AX.Cmp_id = @cmp_id
		INNER JOIN T0050_AD_MASTER AM ON AM.CMP_ID= @cmp_id AND AM.AD_ID = AX.Ad_id
		) OT 
		WHERE OT.Total_Amount > 0
		
	select Account,Center_Code,SUM(Ammount)Ammount,MAX(AD_ID)AD_ID INTO #temp_data from T0210_MONTHLY_Sal_POS_DETAIL Group BY Account,Center_Code --order BY EMP_ID

		

		INSERT INTO T0200_Salary_Posting_Master (Cmp_ID,Doc_No,Doc_Date,Doc_Type,Com_Code,Pos_Date,Currency_Type,Req_Status_M,Login_ID,System_Date,Process_type,Post_Req_ID,Emp_Cnt) --OUTPUT Inserted.Sal_Pos_MID
		select @cmp_id,''as 'Doc_NO',@to_date,'JV',cmp_code,GETDATE(),'INR','0',@login_ID,GETDATE(),@Process_Type,@Pos_Req_ID,(select count(1) from #Pre_Salary_Data) 
		from T0010_COMPANY_CODE 
		where cmp_id= @cmp_id
		
		SELECT @Pos_Req_M_ID = SCOPE_IDENTITY()
		--select @Pos_Req_M_ID 

		
		INSERT INTO T0200_Salary_Posting_Detail (Sal_Pos_MID,Cmp_ID,Pos_Key,GL_AccNo,GL_Name,Asset_Name,Total_Amount,Tax_Code,Cost_Center,Profit_Center,Plant_Name,Req_Status_D,Login_ID,System_Date)
		select @Pos_Req_M_ID,@cmp_id,CASE WHEN AM.AD_ID IS NOT NULL THEN CASE WHEN AM.AD_FLAG = 'I' THEN '40' ELSE '50'END ELSE CASE WHEN TM.AD_ID = 2003 THEN '40' WHEN TM.AD_ID = 1003 THEN '50' END END
		,TM.Account,'','',Tm.Ammount,'',TM.Center_Code,'',CM.CMp_Code,'0',@login_ID,GETDATE()
		from #temp_data TM
		INNER JOIN T0010_COMPANY_CODE CM ON CM.cmp_ID = @cmp_id
		LEFT JOIN T0050_AD_MASTER AM ON AM.CMP_ID = @cmp_id AND AM.AD_ID = TM.AD_ID
		where TM.Ammount > 0

		update T0200_Salary_Posting_Master set GL_Ac_Cnt = (select Count(1) from (select GL_AccNo from T0200_Salary_Posting_Detail where Sal_Pos_MID = @Pos_Req_M_ID group by GL_AccNo )T ) where Sal_Pos_MID = @Pos_Req_M_ID

		update T0200_Salary_Posting_Master set Cost_Center_CNt = (select Count(1) from (select Cost_Center from T0200_Salary_Posting_Detail where Sal_Pos_MID = @Pos_Req_M_ID group by Cost_Center )T ) where Sal_Pos_MID = @Pos_Req_M_ID


		select @Pos_Req_M_ID as 'Post_Id'
		--select * from T0200_Salary_Posting_Master
		--select * from T0200_Salary_Posting_Detail
END
