


--exec Emp_Details_Form_B_format1 @Company_Id=119,@From_Date='2021-12-01 00:00:00',@To_Date='2021-12-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='26278',@Report_Type='ESIC'


--exec Emp_Details_Form_B_format1 @Company_Id=119,@From_Date='2020-01-01 00:00:00',@To_Date='2021-01-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='',@Report_Type='ESIC'
CREATE PROCEDURE [dbo].[Emp_Details_Form_B_format1]    
  @Company_Id NUMERIC      
 ,@From_Date  DATETIME    
 ,@To_Date   DATETIME   
 ,@Branch_ID  VarChar     
 ,@Cat_ID   VarChar  
 ,@Grade_ID   VarChar    
 ,@Type_ID   VarChar    
 ,@Dept_ID   VarChar    
 ,@Desig_ID   VarChar    
 ,@Emp_ID   NUMERIC    
 ,@Constraint VARCHAR(MAX)    
 ,@Report_Type varchar(50)  
   
AS 
begin
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
  
  

  IF @Branch_ID = '0' or @Branch_ID = ''
		SET @Branch_ID = NULL

	IF @Cat_ID = '0' or  @Cat_ID = ''
		SET @Cat_ID = NULL
		 
	IF @Type_ID = '0' or @Type_ID = ''
		SET @Type_ID = NULL
	IF @Dept_ID = '0' or @Dept_ID = ''
		SET @Dept_ID = NULL
	IF @Grade_ID = '0' or @Grade_ID = ''
		SET @Grade_ID = NULL

	
	IF @Desig_ID = '0' or @Desig_ID = ''
		SET @Desig_ID = NULL
	
	IF @Branch_ID= '0' OR @Branch_ID=''  --Added By Jaina 21-09-2015
		SET @Branch_ID = NULL
	IF @Constraint= '0' OR @Constraint=''  --Added By Jaina 21-09-2015
		SET @Constraint = NULL
	
	
		
	
		
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)  

	--exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_Id,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,@Segment_Id,@Vertical,@SubVertical,@subBranch,0,0,0,0,0,0 
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_Id,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,0,0,0,0,0,0,0,0,0,0  --Check and verify the above parameter
	
	
	
	IF @Constraint <> ''
		Begin		
			INSERT INTO #Emp_Cons
			SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T  
		End

		--select * from #Emp_Cons where Increment_ID <> 0
		--return

		IF @Constraint <> ''
		begin
		
									--IF OBJECT_ID(N'tempdb..#TmpEmpAllowIntTable') IS NOT NULL
									--	DROP TABLE #TmpEmpAllowIntTable

									--Select distinct AD_NAME ,AD_DEF_ID
									----into #TmpEmpAllowIntTable
									--FROM T0210_MONTHLY_AD_DETAIL AD 
									----inner join  #Emp_Cons EC on EC.Emp_ID  = AD.Emp_ID
									--inner join T0050_AD_MASTER MA on AD.AD_ID = MA.AD_ID 
									--WHERE Ad.Cmp_ID = @Company_Id and For_Date between @From_date and @To_date
									--and M_AD_Flag = 'I'

										IF OBJECT_ID(N'tempdb..#tmpIntSum') IS NOT NULL
										DROP TABLE #tmpIntSum

									Select  I.Emp_ID ,Emp_Full_Name as [Name],sum(MD.M_AD_Amount) as totalAllo_Amt,For_Date ,M_AD_Flag,I.Cmp_ID
									into #tmpIntSum
									from T0080_EMP_MASTER E      
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id        
									inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID      
									inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id 
									inner join (select ms.Emp_id from
									T0080_EMP_MASTER E
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID
									where  Month_St_Date=@From_Date and Month_End_Date=@To_Date)
									Qry on qry.Emp_id=E.emp_id
									--inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID       
									where For_date between cast(@from_date as varchar(50)) 
									and  cast(@To_date as varchar(50))  and M_AD_Flag = 'I' and AD_DEF_ID not in(5,6)
								   group by I.Emp_ID,For_Date,M_AD_Flag,I.Cmp_ID,E.Emp_Full_Name

									
									--select * from #tmpIntSum  --mansi
										IF OBJECT_ID(N'tempdb..#HRAAmt') IS NOT NULL
										DROP TABLE #HRAAmt

									Select  I.Emp_ID ,Emp_Full_Name as [Name],(MD.M_AD_Amount) as  M_AD_Amount,For_Date ,M_AD_Flag,I.Cmp_ID
									into #HRAAmt
									from T0080_EMP_MASTER E      
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id        
									inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID      
									inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id 
									inner join (select ms.Emp_id from
									T0080_EMP_MASTER E
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID
									where  Month_St_Date=@From_Date and Month_End_Date=@To_Date)
									Qry on qry.Emp_id=E.emp_id
									--inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID       
									where For_date between cast(@from_date as varchar(50)) 
									and  cast(@To_date as varchar(50))  and M_AD_Flag = 'I'  and AD_DEF_ID in(17)
									--group by I.Emp_ID,For_Date,M_AD_Flag,I.Cmp_ID,E.Emp_Full_Name

									
									IF OBJECT_ID(N'tempdb..#finalTI') IS NOT NULL
										DROP TABLE #finalTI
									Select distinct I.Emp_ID,Emp_Full_Name as [Name_2],qry.Basic_Salary as [Rate_of_Wages_3],qry.Present_Days as [Number_of_Days_Worked_4],
								    isnull(qry.OT_Hours,0) as [Overtime_hours_worked_5],(MD.M_AD_Amount+qry.Salary_Amount) as [Basic_6+Special_Basic_7+DA_8],
									qry.OT_Amount as [Payments_OverTime_9],hr.M_AD_Amount as [HRA_10],(ti.totalAllo_Amt-(MD.M_AD_Amount+hr.M_AD_Amount))as [Others_11]
									,(qry.Salary_Amount+ti.totalAllo_Amt+qry.OT_Amount) as [Total_(06to11)_12],qry.Salary_Amount,qry.Allow_Amount,MD.For_Date as [For_Date]
									,MD.M_AD_Flag,I.Cmp_ID,Sal_Generate_Date
									into #finalTI 
									from T0080_EMP_MASTER E      
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id        
									inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID      
									inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id 
									inner join  #tmpIntSum TI on ti.Emp_ID =E.Emp_ID
									inner join  #HRAAmt HR on hr.Emp_ID =E.Emp_ID
									inner join (select ms.Emp_id,ms.Salary_Amount,ms.Present_Days,ms.OT_Hours,ms.OT_Amount
									,ms.Allow_Amount,ms.Basic_Salary,ms.Sal_Generate_Date
									from
									T0080_EMP_MASTER E
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID
									where  Month_St_Date=@From_Date and Month_End_Date=@To_Date)
									Qry on qry.Emp_id=E.emp_id
									--inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID       
									where MD.For_date between cast(@from_date as varchar(50)) 
									and  cast(@To_date as varchar(50))  and MD.M_AD_Flag = 'I' and AD_DEF_ID in(11)
									
									--select distinct * from #finalTI

									
									
									
									IF OBJECT_ID(N'tempdb..#tmpDedSum') IS NOT NULL
										DROP TABLE #tmpDedSum

									Select distinct I.Emp_ID ,AD_NAME,(MD.M_AD_Amount) as M_AD_Amount,AD_DEF_ID,For_Date ,M_AD_Flag,I.Cmp_ID
									,qry.M_IT_Tax,qry.Advance_Amount,qry.PT_Amount,qry.Other_Dedu_Amount
									into #tmpDedSum
									from T0080_EMP_MASTER E       
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id        
									inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID      
									inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id    
									inner join (select ms.Emp_id,ms.M_IT_Tax,ms.Advance_Amount,ms.PT_Amount,ms.Other_Dedu_Amount from
									T0080_EMP_MASTER E
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID
									where --e.emp_id=26278 and
									 Month_St_Date=@From_Date and Month_End_Date=@To_Date)
									Qry on qry.Emp_id=E.emp_id
									--inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID       
									where For_date between cast(@from_date as varchar(50)) 
									and  cast(@To_date as varchar(50))  and M_AD_Flag = 'D'
									--group by I.Emp_ID,For_Date,M_AD_Flag,I.Cmp_ID

									--select * from #tmpDedSum--mansi
                                   IF OBJECT_ID(N'tempdb..#finalDedu') IS NOT NULL
										DROP TABLE #finalDedu
								select Emp_ID,[2]as Pf,[3]as ESIC,Cmp_ID,Advance_Amount,PT_Amount,
									  M_IT_Tax,Other_Dedu_Amount into #finalDedu from
									(
									  select Emp_ID,AD_DEF_ID,M_AD_Amount,For_Date,Cmp_ID,Advance_Amount,PT_Amount,
									  M_IT_Tax,Other_Dedu_Amount
									  from  #tmpDedSum

									) d
									pivot
									(
									  max(M_AD_Amount)
                                  for AD_DEF_ID in([2],[3])
                                     ) piv


									 --select * from #finalDedu
									 IF OBJECT_ID(N'tempdb..#otherDedu') IS NOT NULL
										DROP TABLE #otherDedu
									 select distinct Emp_ID,For_Date,isnull(Insurance,0)as Insurance,isnull(Recovery,0)as Recovery,isnull(Others,0)as Others  into #otherDedu from
									(
									  select AD_NAME,Emp_ID,M_AD_Amount,For_Date,Cmp_ID
									  from  #tmpDedSum

									) d
									pivot
									(
									  max(M_AD_Amount)
                                  for ad_name in([Insurance],[Recovery],[Others])
                                     ) piv

									--select Emp_ID,For_Date,Insurance,Recovery,isnull(Others,0)as Others from  #otherDedu
									 	IF OBJECT_ID(N'tempdb..#tmpEmployer') IS NOT NULL
										DROP TABLE #tmpEmployer

									Select distinct I.Emp_ID ,AD_NAME,(MD.M_AD_Amount) as Amount,AD_DEF_ID  ,For_Date ,M_AD_Flag,I.Cmp_ID
									into #tmpEmployer
									from T0080_EMP_MASTER E       
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id        
									inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID      
									inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id    
									inner join (select ms.Emp_id,ms.M_IT_Tax,ms.Advance_Amount,ms.PT_Amount,ms.Other_Dedu_Amount from
									T0080_EMP_MASTER E
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID
									where --e.emp_id=26278 and
									 Month_St_Date=@From_Date and Month_End_Date=@To_Date)
									Qry on qry.Emp_id=E.emp_id
									--inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID       
									where For_date between cast(@from_date as varchar(50)) 
									and  cast(@To_date as varchar(50))  and AD_DEF_ID in(5,6)
									--group by I.Emp_ID,For_Date,M_AD_Flag,I.Cmp_ID



									--select * from #tmpEmployer--mansi
									IF OBJECT_ID(N'tempdb..#finalEmployer') IS NOT NULL
										DROP TABLE #finalEmployer
									
									select Emp_ID,[5]as Employer_Pf,[6]as Employer_ESIC,'' as Welfare_Fund,Cmp_ID,For_Date 
									into #finalEmployer from
									(
									  select Emp_ID,AD_DEF_ID,amount,For_Date,Cmp_ID
									 
									 from  #tmpEmployer
									) d
									pivot
									(
									  max(Amount)
                                  for AD_DEF_ID in([5],[6])
                                     ) piv
									 
									 --select * from #finalEmployer--mansi


									 select distinct cast((ROW_NUMBER() OVER(ORDER BY fti.emp_id))as varchar) AS [SrNo_in_Employee_Register_1],fti.Name_2,fti.Rate_of_Wages_3,fti.Number_of_Days_Worked_4,fti.Overtime_hours_worked_5,
									 fti.[Basic_6+Special_Basic_7+DA_8],fti.Payments_OverTime_9,fti.HRA_10,fti.Others_11,fti.[Total_(06to11)_12],
									 fdu.Pf as PF_13,fdu.ESIC as ESIC_14,fdu.PT_Amount as PT_15,
									 fdu.Advance_Amount as Emp_Adv_16,fdu.M_IT_Tax as Income_Tax_17,ot.Insurance as Insurance_18,
									 ot.Others as Others_19,ot.Recovery as Recovery_20,
									 (fdu.Pf+fdu.ESIC+fdu.PT_Amount+fdu.Advance_Amount+fdu.M_IT_Tax+ot.Insurance+ot.Others+ot.Recovery)as [Total(13To20)_21],
								    (fti.[Total_(06to11)_12]-( (fdu.Pf+fdu.ESIC+fdu.PT_Amount+fdu.Advance_Amount+fdu.M_IT_Tax+ot.Insurance+ot.Others+ot.Recovery)))as [Net_Payment(12-21)_22],
									fe.Employer_Pf as Employer_Pf_23,fe.Employer_ESIC as Employer_ESIC_23,fe.Welfare_Fund as Welfare_Fund_23,'' as [Receipt_by_Employee/Bank_24]
									,Format(Sal_Generate_Date,'dd-MM-yyyy')  as [Date_Of_Payment_25]
									,'' as [Remarks_26] into #finaltbl
									 from  #finalTI FTI
									 inner join #finalDedu fdu on fdu.Emp_ID=fti.Emp_ID
									 inner join #finalEmployer fe on fe.Emp_ID=fti.Emp_ID
									 inner join #otherDedu ot on ot.Emp_ID=fti.Emp_ID
									
									select '' as Sr_No,'' AS SrNo_in_Employee_Register_1,'Grand Total' as Name_2,sum(Rate_of_Wages_3)as Rate_of_Wages_3,
									 sum(Number_of_Days_Worked_4)as Number_of_Days_Worked_4,sum(Overtime_hours_worked_5) as Overtime_hours_worked_5,
									sum([Basic_6+Special_Basic_7+DA_8]) as [Basic_6+Special_Basic_7+DA_8],sum(Payments_OverTime_9) as Payments_OverTime_9,
									sum(HRA_10) as HRA_10,sum(Others_11)as Others_11,sum([Total_(06to11)_12]) as [Total_(06to11)_12],sum(PF_13) as PF_13,
									sum(ESIC_14)as ESIC_14,sum(PT_15)as PT_15,sum(Emp_Adv_16) as Emp_Adv_16,sum(Income_Tax_17)as Income_Tax_17,
									sum(Insurance_18)as Insurance_18,sum(Others_19)as Others_19,sum(Recovery_20)as Recovery_20,
									sum([Total(13To20)_21])as [Total(13To20)_21],sum([Net_Payment(12-21)_22])as [Net_Payment(12-21)_22],
									sum(Employer_Pf_23)as Employer_Pf_23,sum(Employer_ESIC_23) as Employer_ESIC_23,'' as Welfare_Fund_23,--sum(Welfare_Fund_23)as Welfare_Fund_23,
									'' as [Receipt_by_Employee/Bank_24],'' as Date_Of_Payment_25,'' as Remarks_26 into #finaltotal
									from #finaltbl
									
									select * from
									(select 0 as flag,cast((ROW_NUMBER() OVER(ORDER BY [SrNo_in_Employee_Register_1]))as varchar) as Sr_No,* from #finaltbl
									union all 
									select 1 as flag,* from #finaltotal)as t
								

  END    
 ELSE    
  
      BEGIN  
    --select 2
  
			
												IF OBJECT_ID(N'tempdb..#TmpEmpAllowIntTable1') IS NOT NULL
													DROP TABLE #TmpEmpAllowIntTable1


												Select distinct AD_NAME 
												into #TmpEmpAllowIntTable1
												FROM T0210_MONTHLY_AD_DETAIL AD 
												--inner join  #Emp_Cons EC on EC.Emp_ID  = AD.Emp_ID
												inner join T0050_AD_MASTER MA on AD.AD_ID = MA.AD_ID 
												WHERE Ad.Cmp_ID = @Company_Id and For_Date between @From_date and @To_date
												and M_AD_Flag = 'I'

												IF OBJECT_ID(N'tempdb..#TmpEmpAllowDedTable1') IS NOT NULL
													DROP TABLE #TmpEmpAllowDedTable1

												Select distinct AD_NAME 
												into #TmpEmpAllowDedTable1
												FROM T0210_MONTHLY_AD_DETAIL AD 
												--inner join  #Emp_Cons EC on EC.Emp_ID  = AD.Emp_ID
												inner join T0050_AD_MASTER MA on AD.AD_ID = MA.AD_ID 
												WHERE Ad.Cmp_ID = @Company_Id and For_Date between @From_date and @To_date
												and M_AD_Flag = 'D'

												-- select * from #TmpEmpAllowIntTable

												Declare @ColIntVar1 as NVARCHAR(MAX)
												Select @ColIntVar1 = List_Output  --+ ' , ' + '[Total_Int]' 
												from (
												   SELECT STUFF((SELECT ', [' + CAST(AD_NAME AS VARCHAR(100)) + ']'
														FROM #TmpEmpAllowIntTable1
														FOR XML PATH(''), TYPE)
														.value('.','NVARCHAR(MAX)'),1,2,' ') List_Output
												)  as T

												Declare @ColDedVar1 as NVARCHAR(MAX)
												Select @ColDedVar1 = List_Output  --+ ' , ' + '[Total_Int]' 
												from (
												   SELECT STUFF((SELECT ', [' + CAST(AD_NAME AS VARCHAR(100)) + ']'
														FROM #TmpEmpAllowDedTable1
														FOR XML PATH(''), TYPE)
														.value('.','NVARCHAR(MAX)'),1,2,' ') List_Output
												)  as T

												--select @ColIntVar
												IF OBJECT_ID(N'tempdb..#tmpIntSum1') IS NOT NULL
													DROP TABLE #tmpIntSum1

												Select I.Emp_ID ,E.Emp_Full_Name as [Name],Sum(MD.M_AD_Amount) as M_AD_Amount  ,For_Date ,M_AD_Flag,I.Cmp_ID
												into #tmpIntSum1
												from T0080_EMP_MASTER E      
												--inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
												inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id        
												inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID      
												inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id       
												inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID       
												where For_date between cast(@from_date as varchar(50)) 
												and  cast(@To_date as varchar(50))  and M_AD_Flag = 'I'
												group by I.Emp_ID,For_Date,M_AD_Flag,I.Cmp_ID,E.Emp_Full_Name


												IF OBJECT_ID(N'tempdb..#tmpDedSum1') IS NOT NULL
													DROP TABLE #tmpDedSum1

												Select I.Emp_ID ,Sum(MD.M_AD_Amount) as M_AD_Amount  ,For_Date ,M_AD_Flag,I.Cmp_ID
												into #tmpDedSum1
												from T0080_EMP_MASTER E       
												--inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
												inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id        
												inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID      
												inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id       
												inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID       
												where For_date between cast(@from_date as varchar(50)) 
												and  cast(@To_date as varchar(50))  and M_AD_Flag = 'D'
												group by I.Emp_ID,For_Date,M_AD_Flag,I.Cmp_ID

											
												IF OBJECT_ID(N'tempdb..#tmpFinalsum1') IS NOT NULL
													DROP TABLE #tmpFinalsum1

												select ti.Emp_ID,TI.M_AD_Amount as Total_Int ,TD.M_AD_Amount as Total_Ded ,TI.For_Date as For_date_Int , TD.For_Date as For_date_Ded
												,(ti.M_AD_Amount + td.M_AD_Amount) as NetAmount into #tmpFinalsum1
												from  #tmpIntSum1 TI inner join #tmpDedSum1 TD on TI.Emp_ID = TD.Emp_ID

                 

												DROP Table IF EXISTS  tmpInt
												Declare  @Qry_INT1 as varchar(MAX) = ''
												Set @Qry_INT1 = 'SELECT Emp_ID ,Emp_Full_Name, For_Date , '+ @ColIntVar1 +' 
																into tmpInt        
																FROM 
																( 
																				Select NULL as [Sr.No.in_Employee/Workman/Work_Register],I.Emp_ID ,E.Emp_Full_Name,MD.M_AD_Amount , AD.AD_NAME ,For_Date
																				from T0080_EMP_MASTER E 
																				inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id  
																				
																				inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID 
																				inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id 
																				inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID 
																				where For_date between ''' + cast(@from_date as varchar(50)) + ''' and  ''' + cast(@To_date as varchar(50)) + '''
																				and MD.M_AD_Flag = ''I''
																   ) FormBResult    
																   PIVOT (SUM(M_AD_Amount) FOR AD_NAME IN ( '+ @ColIntVar1 +' )) AS PivotTable' 

           

												exec(@Qry_INT1)


												DROP Table IF EXISTS  tmpDed
												Declare  @Qry_Ded1 as varchar(MAX) = ''
												Set @Qry_Ded1 = 'SELECT Emp_ID , For_Date , '+ @ColDedVar1 +' ,Sal_Generate_Date
																into tmpDed       
																FROM 
																( 
																				Select NULL as [Sr.No.in_Employee/Workman/Work_Register],I.Emp_ID ,MD.M_AD_Amount 
																				, AD.AD_NAME ,For_Date,MS.Sal_Generate_Date
																				from T0080_EMP_MASTER E 
																				inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id  
																				
																				inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID 
																				inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id 
																				inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID 
																				where For_date between ''' + cast(@from_date as varchar(50)) + ''' 
																				and  ''' + cast(@To_date as varchar(50)) + '''
																				and MD.M_AD_Flag = ''D''
																   ) FormBResult    
																   PIVOT (SUM(M_AD_Amount) FOR AD_NAME IN ( '+ @ColDedVar1 +' )) AS PivotTable' 

																   exec(@Qry_Ded1)

												Declare @finalQry1 Varchar(MAX) = ''


												Set  @finalQry1 = 'Select TI.* , TFS.Total_Int ,TD.' + @ColDedVar1 + ' ,TFS.Total_Ded,NetAmount,
												--'' as  Employer/Workman/Worker_Share_PF_Welfare_Fund,'' as Receipt_by_Employee/Workman/Worker_Bank_Transaction ID,
												TD.Sal_Generate_Date as Date_of_Payment
												--,TD.Remarks
												--into #tmpFinalTable 
												from tmpInt TI inner join  tmpDed TD on TI.Emp_id	= TD.Emp_id and TI.For_Date = TD.For_date 
												inner join #tmpFinalsum1 TFS on TD.Emp_id = TFS.Emp_ID'

												exec (@finalQry1)
					

END  
end
