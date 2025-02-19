
--exec Emp_Details_Form_B @Company_Id=119,@From_Date='2021-12-01 00:00:00',@To_Date='2021-12-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='26278',@Report_Type='ESIC'

--exec Emp_Details_Form_A @Company_Id=119,@From_Date='2020-01-01 00:00:00',@To_Date='2020-01-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='25514#25515',@Report_Type='ESIC'
--exec Emp_Details_Form_B @Company_Id=119,@From_Date='2020-01-01 00:00:00',@To_Date='2021-01-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='',@Report_Type='ESIC'
CREATE PROCEDURE [dbo].[Emp_Details_Form_B]    
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
		
									IF OBJECT_ID(N'tempdb..#TmpEmpAllowIntTable') IS NOT NULL
										DROP TABLE #TmpEmpAllowIntTable


									Select distinct AD_NAME 
									into #TmpEmpAllowIntTable
									FROM T0210_MONTHLY_AD_DETAIL AD 
									inner join  #Emp_Cons EC on EC.Emp_ID  = AD.Emp_ID
									inner join T0050_AD_MASTER MA on AD.AD_ID = MA.AD_ID 
									WHERE Ad.Cmp_ID = @Company_Id and For_Date between @From_date and @To_date
									and M_AD_Flag = 'I'

									IF OBJECT_ID(N'tempdb..#TmpEmpAllowDedTable') IS NOT NULL
										DROP TABLE #TmpEmpAllowDedTable

								--	select * from #TmpEmpAllowIntTable--mansi

									Select distinct AD_NAME 
									into #TmpEmpAllowDedTable
									FROM T0210_MONTHLY_AD_DETAIL AD 
									inner join  #Emp_Cons EC on EC.Emp_ID  = AD.Emp_ID
									inner join T0050_AD_MASTER MA on AD.AD_ID = MA.AD_ID 
									WHERE Ad.Cmp_ID = @Company_Id and For_Date between @From_date and @To_date
									and M_AD_Flag = 'D'

									-- select * from #TmpEmpAllowIntTable

									Declare @ColIntVar as NVARCHAR(MAX)
									----commented by mansi start 
									--Select @ColIntVar = List_Output  --+ ' , ' + '[Total_Int]' 
									--from (
									--   SELECT STUFF((SELECT ', [' + CAST(AD_NAME AS VARCHAR(100)) + ']'
									--		FROM #TmpEmpAllowIntTable
									--		FOR XML PATH(''), TYPE)
									--		.value('.','NVARCHAR(MAX)'),1,2,' ') List_Output
									--)  as T
									----commented by mansi end 
										--added by mansi start 
										--update #TmpEmpAllowIntTable set AD_NAME='Subsidy Interest'
										-- where AD_NAME='Subsidy interest' 
										Select @ColIntVar = List_Output  --+ ' , ' + '[Total_Int]' 
									from (
									   SELECT STUFF((SELECT ', [' + replace((trim(CAST(AD_NAME AS VARCHAR(100)))),' ','_') + ']'
											FROM #TmpEmpAllowIntTable
											FOR XML PATH(''), TYPE)
											.value('.','NVARCHAR(MAX)'),1,2,' ') List_Output
									)  as T
									--added by mansi end 
									print @ColIntVar
									Declare @ColDedVar as NVARCHAR(MAX)
										----commented by mansi start 
									--Select @ColDedVar = List_Output  --+ ' , ' + '[Total_Int]' 
									--from (
									--   SELECT STUFF((SELECT ', [' + CAST(AD_NAME AS VARCHAR(100)) + ']'
									--		FROM #TmpEmpAllowDedTable
									--		FOR XML PATH(''), TYPE)
									--		.value('.','NVARCHAR(MAX)'),1,2,' ') List_Output
									--)  as T
									----commented by mansi end 
										--added by mansi start 
										Select @ColDedVar = List_Output  --+ ' , ' + '[Total_Int]' 
									from (
									   SELECT STUFF((SELECT ', [' + replace((trim(CAST(AD_NAME AS VARCHAR(100)))),' ','_') + ']'
											FROM #TmpEmpAllowDedTable
											FOR XML PATH(''), TYPE)
											.value('.','NVARCHAR(MAX)'),1,2,' ') List_Output
									)  as T
									--added by mansi end 
									
									--select @ColIntVar
									IF OBJECT_ID(N'tempdb..#tmpIntSum') IS NOT NULL
										DROP TABLE #tmpIntSum

									Select I.Emp_ID ,Emp_Full_Name as [Name],Sum(MD.M_AD_Amount) as M_AD_Amount  ,For_Date ,M_AD_Flag,I.Cmp_ID
									into #tmpIntSum
									from T0080_EMP_MASTER E      
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id        
									inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID      
									inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id       
									inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID       
									where For_date between cast(@from_date as varchar(50)) 
									and  cast(@To_date as varchar(50))  and M_AD_Flag = 'I'
									group by I.Emp_ID,For_Date,M_AD_Flag,I.Cmp_ID,E.Emp_Full_Name


									IF OBJECT_ID(N'tempdb..#tmpDedSum') IS NOT NULL
										DROP TABLE #tmpDedSum

									Select I.Emp_ID ,Sum(MD.M_AD_Amount) as M_AD_Amount  ,For_Date ,M_AD_Flag,I.Cmp_ID
									into #tmpDedSum
									from T0080_EMP_MASTER E       
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id        
									inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID      
									inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id       
									inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID       
									where For_date between cast(@from_date as varchar(50)) 
									and  cast(@To_date as varchar(50))  and M_AD_Flag = 'D'
									group by I.Emp_ID,For_Date,M_AD_Flag,I.Cmp_ID

								
									IF OBJECT_ID(N'tempdb..#tmpFinalsum') IS NOT NULL
										DROP TABLE #tmpFinalsum

									select ti.Emp_ID,TI.M_AD_Amount as Total_Int ,TD.M_AD_Amount as Total_Ded ,TI.For_Date as For_date_Int , TD.For_Date as For_date_Ded
									,(ti.M_AD_Amount + td.M_AD_Amount) as NetAmount into #tmpFinalsum
									from  #tmpIntSum TI inner join #tmpDedSum TD on TI.Emp_ID = TD.Emp_ID

                     
									DROP Table IF EXISTS  tmpInt
									Declare  @Qry_INT as varchar(MAX) = ''
									Set @Qry_INT = 'SELECT Emp_ID ,Emp_Full_Name, For_Date , '+ @ColIntVar +' 
													into tmpInt        
													FROM 
													( 
																	Select NULL as [Sr.No.in_Employee/Workman/Work_Register],I.Emp_ID,E.Emp_Full_Name ,MD.M_AD_Amount , AD.AD_NAME ,For_Date
																	from T0080_EMP_MASTER E 
																	inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id  
																	inner join  #Emp_Cons EC on EC.Emp_ID  = I.Emp_ID
																	inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID 
																	inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id 
																	inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID 
																	where For_date between ''' + cast(@from_date as varchar(50)) + ''' and  ''' + cast(@To_date as varchar(50)) + '''
																	and MD.M_AD_Flag = ''I''
													   ) FormBResult    
													   PIVOT (SUM(M_AD_Amount) FOR AD_NAME IN ( '+ @ColIntVar +' )) AS PivotTable' 

           

									exec(@Qry_INT)


									DROP Table IF EXISTS  tmpDed
									Declare  @Qry_Ded as varchar(MAX) = ''
									Set @Qry_Ded = 'SELECT Emp_ID , For_Date , '+ @ColDedVar +' ,Sal_Generate_Date
													into tmpDed        
													FROM 
													( 
																	Select NULL as [Sr.No.in_Employee/Workman/Work_Register],I.Emp_ID ,MD.M_AD_Amount 
																	, AD.AD_NAME ,For_Date,MS.Sal_Generate_Date
																	from T0080_EMP_MASTER E 
																	inner join T0095_INCREMENT I on I.Emp_ID = E.emp_id  
																	inner join  #Emp_Cons EC on EC.Emp_ID  = I.Emp_ID
																	inner join T0210_MONTHLY_AD_DETAIL MD on I.Emp_id = MD.Emp_ID 
																	inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id 
																	inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID 
																	where For_date between ''' + cast(@from_date as varchar(50)) + ''' 
																	and  ''' + cast(@To_date as varchar(50)) + '''
																	and MD.M_AD_Flag = ''D''
													   ) FormBResult    
													   PIVOT (SUM(M_AD_Amount) FOR AD_NAME IN ( '+ @ColDedVar +' )) AS PivotTable' 

													   exec(@Qry_Ded)

									Declare @finalQry Varchar(MAX) = ''


									Set  @finalQry = 'Select TI.* , TFS.Total_Int ,TD.' + @ColDedVar + ' ,TFS.Total_Ded,NetAmount,TD.Sal_Generate_Date as Date_of_Payment
									--into #tmpFinalTable 
									from tmpInt TI inner join  tmpDed TD on TI.Emp_id	= TD.Emp_id and TI.For_Date = TD.For_date 
									inner join #tmpFinalsum TFS on TD.Emp_id = TFS.Emp_ID'

									exec (@finalQry)
				
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
