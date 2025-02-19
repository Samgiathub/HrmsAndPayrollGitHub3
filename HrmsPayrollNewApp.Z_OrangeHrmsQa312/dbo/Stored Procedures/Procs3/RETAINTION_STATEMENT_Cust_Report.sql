
CREATE Proc [dbo].[RETAINTION_STATEMENT_Cust_Report]
	 @Cmp_ID		numeric
	,@Start_Date	datetime
	,@End_Date		datetime 
	,@Branch_ID		varchar(MAX) = ''   
	,@Grd_ID		varchar(MAX) = ''  
	,@Cat_ID		varchar(MAX) = ''  
	,@Dept_ID		varchar(MAX) = ''           
	,@Type_ID		varchar(MAX) = ''                
	,@Desig_ID		varchar(MAX) = ''     
	,@Emp_ID		varchar(MAX) = 0 
	,@Cons	varchar(MAX) = ''
AS
BEGIN

--Declare @Start_Date Datetime ='2023-06-01'
--Declare @End_Date Datetime	= '2023-07-30'
--Declare @Cons nvarchar(Max) ='121#122'




		if @Branch_ID = '' 
			set @Branch_ID = null
		if @Cat_ID = '' 
			set @Cat_ID = null
		if @Type_ID = '' 
			set @Type_ID = null
		if @Dept_ID = '' 
			set @Dept_ID = null
		if @Grd_ID = ''
			set @Grd_ID = null
		if @Emp_ID = 0
			set @Emp_ID = null
		If @Desig_ID = ''
			set @Desig_ID = null

		CREATE TABLE #EMP_CONS 
		(      
			EMP_ID		 NUMERIC ,     
			BRANCH_ID	 NUMERIC,
			INCREMENT_ID NUMERIC
		)      
	
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN  @Cmp_ID,@Start_Date ,@End_Date ,@Branch_ID ,@Cat_ID ,@Grd_ID ,@Type_ID ,@Dept_ID ,@Desig_ID ,@Emp_ID  ,@Cons ,0 ,0 ,0,0,0,0,0,0,0,0,0,0	
						


--if OBJECT_ID('tempdb..#Emp_Cons') IS NOT NUll
--Drop Table #Emp_Cons
--
--CREATE Table #Emp_Cons
--	(
--		emp_id	NUMERIC(18,0)	
--	)
--
--If @Cons <>''
--Begin 
--
--INSERT Into #Emp_Cons
--Select data from dbo.Split(@Cons,'#') 
--
--End
--else
--Begin 
--
--INSERT Into #Emp_Cons
--select  Emp_Id from T0100_EMP_RETAINTION_STATUS RS where Cmp_Id = @Cmp_ID
--and  RS.[start_date] between @Start_Date and @End_Date
--Group by Emp_Id
--
--End

---------------------------------------------For Retainig Day -----------------------------------------------------------------------------------

DECLARE @Pdaycols AS NVARCHAR(MAX), @query AS NVARCHAR(MAX);
SELECT @Pdaycols = STUFF((SELECT DISTINCT 
                           ',' + QUOTENAME('PDay_' + CAST(MONTH(Month_St_Date) AS VARCHAR(2)))
                    from T0200_MONTHLY_SALARY 
					where emp_id in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS 
									  inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
									  where Cmp_Id = @Cmp_ID
									 and  RS.[start_date] between @Start_Date and @End_Date
									 Group by RS.Emp_Id
					) and Month_St_Date between @Start_Date and @End_Date

                     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

					

-- constructing the dynamic SQL query
SET @query = 'SELECT Emp_Id, ' + @Pdaycols + ',PDay_Total  into ##Ret_Month_Data FROM
             (
                SELECT MS.Emp_Id, Retain_Days, ''PDay_'' + CAST(MONTH(Month_St_Date) AS VARCHAR(2)) AS month_column
				,SUM(Retain_Days) OVER (PARTITION BY  MS.Emp_Id) AS PDay_Total
				from T0200_MONTHLY_SALARY MS
					where emp_id in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS 
					inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
					where Cmp_Id = '+cast(@Cmp_ID as varchar(5))+'
				    and  RS.[start_date] between'''+cast(@Start_Date AS VARCHAR(20))+''' and '''+ cast (@End_Date as varchar(20)) +'''
					Group by RS.Emp_Id
					) and Month_St_Date between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''

             ) src
             PIVOT
             (
                MAX(Retain_Days)
                FOR month_column IN (' + @Pdaycols + ')
             ) pvt;';

EXEC (@query);
set @Pdaycols=@Pdaycols+',[PDay_Total]'

---------------------------------------------End For Retainig Day -----------------------------------------------------------------------------------

--------------------------------------------------------Rate Cal on -----------------------------------------------------------------------------
DECLARE @Ratcols AS NVARCHAR(MAX), @Ratquery AS NVARCHAR(MAX);
SELECT @Ratcols = STUFF((SELECT DISTINCT 
                           ',' + QUOTENAME('Rate_' + CAST(MONTH(For_Date) AS VARCHAR(2)))
						from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = @Cmp_ID
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id = @Cmp_ID
						 and  RS.[start_date] between @Start_Date and @End_Date
							Group by RS.Emp_Id
							) and For_Date between @Start_Date and @End_Date
							and AM.AD_DEF_ID = 36
                     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

					 --select Emp_ID,M_AD_Amount,M_AD_Calculated_Amount,For_Date 
-- constructing the dynamic SQL query
SET @Ratquery = 'SELECT Emp_Id, ' + @Ratcols + ',Rate_Total  into ##Ret_Rate_Month_Data FROM
             (
                SELECT MAD.Emp_Id, M_AD_Calculated_Amount, ''Rate_'' + CAST(MONTH(For_Date) AS VARCHAR(2)) AS month_column
				,SUM(M_AD_Calculated_Amount) OVER (PARTITION BY  MAD.Emp_Id) AS Rate_Total
				from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = '+cast(@Cmp_ID as varchar(5))+'
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS 
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id ='+cast(@Cmp_ID as varchar(5))+'
						 and  RS.[start_date] between '''+cast(@Start_Date AS VARCHAR(20))+''' and '''+ cast (@End_Date as varchar(20)) +'''
							Group by RS.Emp_Id
							) and For_Date between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''
							and AM.AD_DEF_ID = 36
							
             ) src
             PIVOT
             (
                MAX(M_AD_Calculated_Amount)
                FOR month_column IN (' + @Ratcols + ')
             ) pvt;';

EXEC (@Ratquery);
set @Ratcols=@Ratcols+',[Rate_Total]'

--------------------------------------------------------End Rate Cal on -----------------------------------------------------------------------------

--------------------------------------------------------Retaintion Amount -----------------------------------------------------------------------------
DECLARE @Amtcols AS NVARCHAR(MAX), @Amtquery AS NVARCHAR(MAX);
SELECT @Amtcols = STUFF((SELECT DISTINCT 
                           ',' + QUOTENAME('RetAmt_' + CAST(MONTH(For_Date) AS VARCHAR(2)))
						from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = @Cmp_ID
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id = @Cmp_ID
						 and  RS.[start_date] between @Start_Date and @End_Date
							Group by RS.Emp_Id
							) and For_Date between @Start_Date and @End_Date
							and AM.AD_DEF_ID = 36
                     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

SET @Amtquery = 'SELECT Emp_Id, ' + @Amtcols + ',RetAmt_Total  into ##Ret_AMT_Month_Data FROM
             (
                SELECT MAD.Emp_Id, M_AD_Amount, ''RetAmt_'' + CAST(MONTH(For_Date) AS VARCHAR(2)) AS month_column
				,SUM(M_AD_Amount) OVER (PARTITION BY  MAD.Emp_Id) AS RetAmt_Total
				from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = '+cast(@Cmp_ID as varchar(5))+'
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS 
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id ='+cast(@Cmp_ID as varchar(5))+'
						 and  RS.[start_date] between '''+cast(@Start_Date AS VARCHAR(20))+''' and '''+ cast (@End_Date as varchar(20)) +'''
							Group by RS.Emp_Id
							) and For_Date between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''
							and AM.AD_DEF_ID = 36
							
             ) src
             PIVOT
             (
                MAX(M_AD_Amount)
                FOR month_column IN (' + @Amtcols + ')
             ) pvt;';

EXEC (@Amtquery);
set @Amtcols=@Amtcols+',[RetAmt_Total]'


--------------------------------------------------------End Retaintion Amount-----------------------------------------------------------------------------


--------------------------------------------------------Retaintion Loan -----------------------------------------------------------------------------
DECLARE @RLoanFcols AS NVARCHAR(MAX), @RLoanquery AS NVARCHAR(MAX);
SELECT @RLoanFcols = STUFF((SELECT DISTINCT 
                           ',' + QUOTENAME('RetLoan_' + CAST(MONTH(For_Date) AS VARCHAR(2)))
						from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = @Cmp_ID
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id = @Cmp_ID
						 and  RS.[start_date] between @Start_Date and @End_Date
							Group by RS.Emp_Id
							) and For_Date between @Start_Date and @End_Date
								and AM.AD_SORT_NAME = 'RetLoan'
                     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

SET @RLoanquery = 'SELECT Emp_Id, ' + @RLoanFcols + ' ,RetLoan_Total into ##Ret_Loan_Month_Data FROM
             (
                SELECT MAD.Emp_Id, M_AD_Amount, ''RetLoan_'' + CAST(MONTH(For_Date) AS VARCHAR(2)) AS month_column
				,SUM(M_AD_Amount) OVER (PARTITION BY  MAD.Emp_Id) AS RetLoan_Total
				from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = '+cast(@Cmp_ID as varchar(5))+'
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id ='+cast(@Cmp_ID as varchar(5))+'
						 and  RS.[start_date] between '''+cast(@Start_Date AS VARCHAR(20))+''' and '''+ cast (@End_Date as varchar(20)) +'''
							Group by RS.Emp_Id
							) and For_Date between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''
								and AM.AD_SORT_NAME = ''RetLoan''
							
             ) src
             PIVOT
             (
                MAX(M_AD_Amount)
                FOR month_column IN (' + @RLoanFcols + ')
             ) pvt;';

EXEC (@RLoanquery);
set @RLoanFcols=@RLoanFcols+',[RetLoan_Total]'

--------------------------------------------------------End Retaintion Loan-----------------------------------------------------------------------------


--------------------------------------------------------Retaintion Loan Intrest -----------------------------------------------------------------------------
DECLARE @RLoanIntFcols AS NVARCHAR(MAX), @RLoanIntquery AS NVARCHAR(MAX);
SELECT @RLoanIntFcols = STUFF((SELECT DISTINCT 
                           ',' + QUOTENAME('RetLoanInt_' + CAST(MONTH(For_Date) AS VARCHAR(2)))
						from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = @Cmp_ID
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id = @Cmp_ID
						 and  RS.[start_date] between @Start_Date and @End_Date
							Group by RS.Emp_Id
							) and For_Date between @Start_Date and @End_Date
								and AM.AD_SORT_NAME = 'RetLoanInt'
                     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

SET @RLoanIntquery = 'SELECT Emp_Id, ' + @RLoanIntFcols + ',RetLoanInt_Total  into ##Ret_Loan_Int_Month_Data FROM
             (
                SELECT MAD.Emp_Id, M_AD_Amount, ''RetLoanInt_'' + CAST(MONTH(For_Date) AS VARCHAR(2)) AS month_column
				,SUM(M_AD_Amount) OVER (PARTITION BY  MAD.Emp_Id) AS RetLoanInt_Total
				from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = '+cast(@Cmp_ID as varchar(5))+'
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id ='+cast(@Cmp_ID as varchar(5))+'
						 and  RS.[start_date] between '''+cast(@Start_Date AS VARCHAR(20))+''' and '''+ cast (@End_Date as varchar(20)) +'''
							Group by RS.Emp_Id
							) and For_Date between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''
								and AM.AD_SORT_NAME = ''RetLoanInt''
							
             ) src
             PIVOT
             (
                MAX(M_AD_Amount)
                FOR month_column IN (' + @RLoanIntFcols + ')
             ) pvt;';

EXEC (@RLoanIntquery);
set @RLoanIntFcols=@RLoanIntFcols+',[RetLoanInt_Total]'


--------------------------------------------------------End Retaintion Loan Intrest -----------------------------------------------------------------------------




--------------------------------------------------------Retaintion RetVPF -----------------------------------------------------------------------------
DECLARE @RetVPFcols AS NVARCHAR(MAX), @RetVPFquery AS NVARCHAR(MAX);
SELECT @RetVPFcols = STUFF((SELECT DISTINCT 
                           ',' + QUOTENAME('RetVPF_' + CAST(MONTH(For_Date) AS VARCHAR(2)))
						from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = @Cmp_ID
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS 
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id = @Cmp_ID
						 and  RS.[start_date] between @Start_Date and @End_Date
							Group by RS.Emp_Id
							) and For_Date between @Start_Date and @End_Date
								and AM.AD_SORT_NAME = 'RetVPF'
                     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

SET @RetVPFquery = 'SELECT Emp_Id, ' + @RetVPFcols + ' ,RetVPF_Total into ##Ret_VPF_Month_Data FROM
             (
                SELECT MAD.Emp_Id, M_AD_Amount, ''RetVPF_'' + CAST(MONTH(For_Date) AS VARCHAR(2)) AS month_column
				,SUM(M_AD_Amount) OVER (PARTITION BY  MAD.Emp_Id) AS RetVPF_Total
				from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = '+cast(@Cmp_ID as varchar(5))+'
						and MAD.Emp_Id in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS 
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id ='+cast(@Cmp_ID as varchar(5))+'
						 and  RS.[start_date] between '''+cast(@Start_Date AS VARCHAR(20))+''' and '''+ cast (@End_Date as varchar(20)) +'''
							Group by RS.Emp_Id
							) and For_Date between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''
								and AM.AD_SORT_NAME = ''RetVPF''
							
             ) src
             PIVOT
             (
                MAX(M_AD_Amount)
                FOR month_column IN (' + @RetVPFcols + ')
             ) pvt;';

EXEC (@RetVPFquery);
set @RetVPFcols=@RetVPFcols+',[RetVPF_Total]'

--------------------------------------------------------End Retaintion RetVPF -----------------------------------------------------------------------------



--------------------------------------------------------Retaintion Net Pay -----------------------------------------------------------------------------
DECLARE @RNetPcols AS NVARCHAR(MAX), @NetPquery AS NVARCHAR(MAX);
SELECT @RNetPcols = STUFF((SELECT DISTINCT 
                           ',' + QUOTENAME('RetNetPay_' + CAST(MONTH(For_Date) AS VARCHAR(2)))
						from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = @Cmp_ID
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id = @Cmp_ID
						 and  RS.[start_date] between @Start_Date and @End_Date
							Group by RS.Emp_Id
							) and For_Date between @Start_Date and @End_Date
								and AM.AD_SORT_NAME = 'RetNetPay'
                     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

SET @NetPquery = 'SELECT Emp_Id, ' + @RNetPcols + ',RetNetPay_Total  into ##Ret_NetPay_Month_Data FROM
             (
                SELECT MAD.Emp_Id, M_AD_Amount, ''RetNetPay_'' + CAST(MONTH(For_Date) AS VARCHAR(2)) AS month_column
				,SUM(M_AD_Amount) OVER (PARTITION BY  MAD.Emp_Id) AS RetNetPay_Total
				from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = '+cast(@Cmp_ID as varchar(5))+'
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id ='+cast(@Cmp_ID as varchar(5))+'
						 and  RS.[start_date] between '''+cast(@Start_Date AS VARCHAR(20))+''' and '''+ cast (@End_Date as varchar(20)) +'''
							Group by RS.Emp_Id
							) and For_Date between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''
								and AM.AD_SORT_NAME = ''RetNetPay''
							
             ) src
             PIVOT
             (
                MAX(M_AD_Amount)
                FOR month_column IN (' + @RNetPcols + ')
             ) pvt;';

EXEC (@NetPquery);
set @RNetPcols=@RNetPcols+',[RetNetPay_Total]'
--------------------------------------------------------End Retaintion Net Pay -----------------------------------------------------------------------------


--------------------------------------------------------Retaintion Bonus -----------------------------------------------------------------------------
DECLARE @RBoncols AS NVARCHAR(MAX), @RBonquery AS NVARCHAR(MAX);
SELECT @RBoncols = STUFF((SELECT DISTINCT 
                           ',' + QUOTENAME('RetBonus_' + CAST(MONTH(For_Date) AS VARCHAR(2)))
						from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = @Cmp_ID
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id = @Cmp_ID
						 and  RS.[start_date] between @Start_Date and @End_Date
							Group by RS.Emp_Id
							) and For_Date between @Start_Date and @End_Date
								and AM.AD_SORT_NAME = 'RetBonus'
                     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

SET @RBonquery = 'SELECT Emp_Id, ' + @RBoncols + ',RetBonus_Total  into ##Ret_Bonus_Month_Data FROM
             (
                SELECT MAD.Emp_Id, M_AD_Amount, ''RetBonus_'' + CAST(MONTH(For_Date) AS VARCHAR(2)) AS month_column
				,SUM(M_AD_Amount) OVER (PARTITION BY  MAD.Emp_Id) AS RetBonus_Total
				from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = '+cast(@Cmp_ID as varchar(5))+'
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS 
							inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id ='+cast(@Cmp_ID as varchar(5))+'
						 and  RS.[start_date] between '''+cast(@Start_Date AS VARCHAR(20))+''' and '''+ cast (@End_Date as varchar(20)) +'''
							Group by RS.Emp_Id
							) and For_Date between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''
								and AM.AD_SORT_NAME = ''RetBonus''
							
             ) src
             PIVOT
             (
                MAX(M_AD_Amount)
                FOR month_column IN (' + @RBoncols + ')
             ) pvt;';

EXEC (@RBonquery);
set @RBoncols=@RBoncols+',[RetBonus_Total]'


--------------------------------------------------------End Retaintion Bonus -----------------------------------------------------------------------------

--------------------------------------------------------Retaintion CPF -----------------------------------------------------------------------------
DECLARE @RCPFcols AS NVARCHAR(MAX), @RCPFquery AS NVARCHAR(MAX);
SELECT @RCPFcols = STUFF((SELECT DISTINCT 
                           ',' + QUOTENAME('RetCPF_' + CAST(MONTH(For_Date) AS VARCHAR(2)))
						from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = @Cmp_ID
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS 
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id = @Cmp_ID
						 and  RS.[start_date] between @Start_Date and @End_Date
							Group by RS.Emp_Id
							) and For_Date between @Start_Date and @End_Date
								and AM.AD_SORT_NAME = 'RetCPF'
                     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

SET @RCPFquery = 'SELECT Emp_Id, ' + @RCPFcols + ',RetCPF_Total  into ##Ret_CPF_Month_Data FROM
             (
                SELECT MAD.Emp_Id, M_AD_Amount, ''RetCPF_'' + CAST(MONTH(For_Date) AS VARCHAR(2)) AS month_column
				,SUM(M_AD_Amount) OVER (PARTITION BY  MAD.Emp_Id) AS RetCPF_Total
				from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = '+cast(@Cmp_ID as varchar(5))+'
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS 
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id ='+cast(@Cmp_ID as varchar(5))+'
						 and  RS.[start_date] between '''+cast(@Start_Date AS VARCHAR(20))+''' and '''+ cast (@End_Date as varchar(20)) +'''
							Group by RS.Emp_Id
							) and For_Date between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''
								and AM.AD_SORT_NAME = ''RetCPF''
							
             ) src
             PIVOT
             (
                MAX(M_AD_Amount)
                FOR month_column IN (' + @RCPFcols + ')
             ) pvt;';

EXEC (@RCPFquery);
set @RCPFcols=@RCPFcols+',[RetCPF_Total]'

--------------------------------------------------------End Retaintion CPF-----------------------------------------------------------------------------


--------------------------------------------------------Retaintion PF -----------------------------------------------------------------------------
DECLARE @RPFcols AS NVARCHAR(MAX), @RPFquery AS NVARCHAR(MAX);
SELECT @RPFcols = STUFF((SELECT DISTINCT 
                           ',' + QUOTENAME('RetPF_' + CAST(MONTH(For_Date) AS VARCHAR(2)))
						from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = @Cmp_ID
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id = @Cmp_ID
						 and  RS.[start_date] between @Start_Date and @End_Date
							Group by RS.Emp_Id
							) and For_Date between @Start_Date and @End_Date
								and AM.AD_SORT_NAME = 'RetPF'
                     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

SET @RPFquery = 'SELECT Emp_Id, ' + @RPFcols + ',RetPF_Total  into ##Ret_PF_Month_Data FROM
             (
                SELECT MAD.Emp_Id, M_AD_Amount, ''RetPF_'' + CAST(MONTH(For_Date) AS VARCHAR(2)) AS month_column
				,SUM(M_AD_Amount) OVER (PARTITION BY  MAD.Emp_Id) AS RetPF_Total
				from T0210_MONTHLY_AD_DETAIL MAD
						inner join T0050_AD_MASTER AM on AM.AD_ID = MAD.AD_ID
						where MAD.Cmp_ID = '+cast(@Cmp_ID as varchar(5))+'
						and Emp_ID in ( select  RS.Emp_Id  from T0100_EMP_RETAINTION_STATUS RS 
						inner join #Emp_Cons EC on EC.emp_id = RS.Emp_Id
						where Cmp_Id ='+cast(@Cmp_ID as varchar(5))+'
						 and  RS.[start_date] between '''+cast(@Start_Date AS VARCHAR(20))+''' and '''+ cast (@End_Date as varchar(20)) +'''
							Group by RS.Emp_Id
							) and For_Date between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''
								and AM.AD_SORT_NAME = ''RetPF''
							
             ) src
             PIVOT
             (
                MAX(M_AD_Amount)
                FOR month_column IN (' + @RPFcols + ')
             ) pvt;';

EXEC (@RPFquery);
set @RPFcols=@RPFcols+',[RetPF_Total]'


--------------------------------------------------------End Retaintion PF-----------------------------------------------------------------------------




Declare @FinalQuery nvarchar(max)
set  @FinalQuery =	
	'select E.Emp_ID,Alpha_Emp_Code,Mobile_No,concat( Initial,'' '', Emp_First_Name ,'' '' ,Emp_Second_Name, '' '',Emp_Last_Name) as Emp_Full_Name ,DM.Desig_Name,GM.Grd_Name,
	'+@Pdaycols+','+@Ratcols+','+@Amtcols+','+@RLoanFcols+','+@RLoanIntFcols+','+@RetVPFcols+','+@RNetPcols+','+@RBoncols+','+@RCPFcols+','+@RPFcols+'
	from T0080_EMP_MASTER E
	inner join T0095_INCREMENT I on I.emp_id = E.emp_id and I.Increment_ID = E.Increment_ID
	inner join T0040_DESIGNATION_MASTER DM on DM. Desig_ID = I.Desig_Id 
	inner join T0040_GRADE_MASTER GM on GM.Grd_ID = I.Grd_ID
	inner join ##Ret_Month_Data PDay on Pday.emp_id = E.Emp_ID
	inner join ##Ret_Rate_Month_Data Rate on Rate.emp_id = E.Emp_ID
	inner join ##Ret_AMT_Month_Data AMT on AMT.emp_id = E.Emp_ID
	inner join ##Ret_CPF_Month_Data CPF on CPF.emp_id = E.Emp_ID
	inner join ##Ret_PF_Month_Data PF on PF.emp_id = E.Emp_ID
	inner join ##Ret_Loan_Month_Data Loan on Loan.emp_id = E.Emp_ID
	inner join ##Ret_Loan_Int_Month_Data Loanint on Loanint.emp_id = E.Emp_ID
	inner join ##Ret_NetPay_Month_Data NetPay on NetPay.emp_id = E.Emp_ID
	inner join ##Ret_Bonus_Month_Data RetBon on RetBon.emp_id = E.Emp_ID
	inner join ##Ret_VPF_Month_Data VPF on VPF.emp_id = E.Emp_ID
	where E.Emp_ID in (
	 select  Emp_Id  from T0100_EMP_RETAINTION_STATUS RS where Cmp_Id = '+cast(@Cmp_ID as varchar(5))+'
 and  RS.[start_date] between '''+ cast(@Start_Date AS VARCHAR(20)) +''' and '''+ cast (@End_Date as varchar(20))+'''
	Group by Emp_Id
	)'

EXEC (@FinalQuery);

	Drop Table ##Ret_Month_Data
	Drop Table ##Ret_Rate_Month_Data
	Drop Table ##Ret_AMT_Month_Data
	Drop Table ##Ret_CPF_Month_Data
	Drop Table ##Ret_PF_Month_Data
	Drop Table ##Ret_Loan_Month_Data
	Drop Table ##Ret_Loan_Int_Month_Data
	Drop Table ##Ret_NetPay_Month_Data
	Drop Table ##Ret_Bonus_Month_Data
	Drop Table ##Ret_VPF_Month_Data


End
