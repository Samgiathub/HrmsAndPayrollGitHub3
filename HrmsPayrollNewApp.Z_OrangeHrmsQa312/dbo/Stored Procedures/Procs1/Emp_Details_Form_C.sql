





CREATE PROCEDURE [dbo].[Emp_Details_Form_C]         
  @Company_Id NUMERIC            
 ,@From_Date  DATETIME        
 ,@To_Date   DATETIME        
 ,@Branch_ID  VarChar         
 ,@Cat_ID   VarChar      
 ,@Grade_ID   VarChar        
 ,@Type_ID   VarChar        
 ,@Dept_ID   VarChar        
 ,@Desig_ID   VarChar        
 ,@Emp_ID   VarChar        
 ,@Constraint VARCHAR(MAX)        
 ,@Report_Type varchar(50)      
-- ,@is_Column  tinyint = 0        
      
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
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_Id,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,0,0,0,0,0,0,0,0,0,0  --Check and verify the above parameter      
       
--declare @To_date as datetime --=  getdate()      
--declare @Company_id as int --=  119      
IF @Constraint <> ''        
  BEGIN        
   INSERT INTO #Emp_Cons(Emp_ID)        
   SELECT  CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#')         
  END          
  
    Delete from #Emp_Cons where Branch_ID is null
	
	 IF OBJECT_ID(N'tempdb..#TmpEmpAllowDedTable') IS NOT NULL    
          DROP TABLE #TmpEmpAllowDedTable    
    
         Select distinct AD_DEF_ID,ad.ad_id
         into #TmpEmpAllowDedTable    
         FROM T0210_MONTHLY_AD_DETAIL AD     
         inner join  #Emp_Cons EC on EC.Emp_ID  = AD.Emp_ID    
         inner join T0050_AD_MASTER MA on AD.AD_ID = MA.AD_ID     
         WHERE Ad.Cmp_ID = @Company_Id and For_Date between @From_date and @To_date    
         and M_AD_Flag = 'D'  and AD_DEF_ID in (33,34,35)
		

		 Declare @ColDedVar as NVARCHAR(MAX)    
         Select @ColDedVar = List_Output  --+ ' , ' + '[Total_Int]'     
         from (    
            SELECT STUFF((SELECT ', [' + Replace(CAST(AD_DEF_ID AS VARCHAR(100)),' ','_') + ']'    
           FROM #TmpEmpAllowDedTable    
           FOR XML PATH(''), TYPE)    
           .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output    
         )  as T   

		 Declare @ColDedDate as NVARCHAR(MAX)    
         Select @ColDedDate = List_Output  --+ ' , ' + '[Total_Int]'     
         from (    
            SELECT STUFF((SELECT ', [' + Replace(CAST(AD_DEF_ID AS VARCHAR(100)),' ','_') + '_Date]'    
           FROM #TmpEmpAllowDedTable    
           FOR XML PATH(''), TYPE)    
           .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output    
         )  as T   

		 

		  IF OBJECT_ID(N'tempdb..#tmpDedSum') IS NOT NULL    
				DROP TABLE #tmpDedSum    

    
         Select distinct  E.Emp_ID ,ad_name,--M_AD_Amount    
         Sum(MD.M_AD_Amount) as M_AD_Amount     
         ,For_date    
         ,M_AD_Flag,e.Cmp_ID   
		 ,AD_DEF_ID,md.AD_ID
         into #tmpDedSum    
         from T0080_EMP_MASTER E           
		 inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID  
         inner join T0210_MONTHLY_AD_DETAIL MD on E.Emp_id = MD.Emp_ID 
         inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id           
         where For_date between cast(@from_date as date) and  cast(@To_date as date)  and     
         M_AD_Flag = 'D' and Md.M_AD_Amount <> 0.00 and E.Cmp_ID = @Company_Id
         and AD.AD_DEF_ID in (33,34,35)
         group by E.Emp_ID,For_Date,M_AD_Flag,E.Cmp_ID,AD_DEF_ID,md.AD_ID,ad_name
         --,M_AD_Amount   
		 
		--select * from #tmpDedSum

		  --if not exists(SELECT 1  FROM sys.tables WHERE name = 'tmpint')
		  ----IF ((select count(1) as cnt from tmpInt) >0 )
		  --Begin 
		  
				--create table tmpInt (
				--Emp_ID numeric,
				--M_AD_Amount numeric(18,2),
				--For_date Datetime,
				--M_AD_Flag Char(2),
				--Cmp_ID  int,
				--AD_DEF_ID numeric
				--)
			
		  --END
		 
		 DROP Table IF EXISTS  tmpInt 
		 Declare  @Qry_INT as varchar(MAX) = ''    
         Set @Qry_INT = 'SELECT Emp_ID ,  '+ @ColDedVar +' ,AD_ID,For_date
			 into tmpInt
             FROM    
             (     
               Select emp_id,M_AD_Amount,AD_DEF_ID,AD_ID,For_date
                 from #tmpDedSum    
                ) FormBResult        
                PIVOT (
					SUM(M_AD_Amount) FOR AD_DEF_ID IN ( '+ @ColDedVar +' )
				) AS PivotTable'     
              
			exec(@Qry_INT)    

			  IF OBJECT_ID(N'tempdb..#tadmaster') IS NOT NULL    
				DROP TABLE #tadmaster    
		 --select Distinct *
		 -- into #tadmaster
		 --from (
		
		  select *
		  into #tadmaster
		from
		(select td.Emp_id,--td.Ad_name,
		M_AD_Amount,--td.AD_ID ,
		td.AD_DEF_ID    
				 ,For_date 
		  from #Emp_Cons ec
				 inner join #tmpDedSum td on td.Emp_ID=ec.emp_id
		) d
		pivot
		(
		  max(M_AD_Amount)
		  for ad_def_id   in ([33],[34],[35])
		) piv;
			-- DROP Table IF EXISTS  tmpDate

		 --Declare  @Qry_Date as varchar(MAX) = ''    
   --      Set @Qry_Date = 'SELECT Emp_ID ,  '+ @ColDedDate +' 
			--into tmpDate
   --          FROM    
   --          (     
   --            Select emp_id,For_date,AD_DEF_ID
   --              from #tmpDedSum    
   --             ) FormBDate        
   --             PIVOT (
			--		Max(For_Date) FOR AD_DEF_ID IN ([33_Date], [34_Date], [35_Date])
					
			--	) AS PivotTable'     
              
			--  --Max(For_Date) FOR AD_DEF_ID IN ( '''+ @ColDedDate +''' )
			--exec(@Qry_Date)    
		
			--select * from tmpDate
			-- select * from tmpInt
			--select * from #tadmaster
 IF @Constraint <> ''        
   BEGIN        
       if((SELECT Count(*) FROM #TmpEmpAllowDedTable) >0)
		  begin
		  print 123
		  --select * from #tadmaster
		   --select * from #Emp_Cons
		  -- select * from tmpInt
			 select  ROW_NUMBER() OVER (ORDER BY E.emp_id asc)as RowNumber , E.Emp_ID,e.Emp_Full_Name, 
			   isnull(tad.[33],0) as Recovery_Type_Damage,isnull(tad.[34],0) as Recovery_Type_Loss,
			   isnull(tad.[35],0) as Recovery_Type_Fine

			  --(select isnull(tad.M_AD_Amount,0) where AD_DEF_ID =33) as Recovery_Type_Damage,(select isnull(tad.M_AD_Amount,0) where AD_DEF_ID =34) as Recovery_Type_Loss,
			  --(select isnull(tad.M_AD_Amount,0) where AD_DEF_ID =35) as Recovery_Type_Fine
			  ,isnull(ap.Adv_Amount,0) as Recovery_Type_Advance,  
			  lt.Loan_Return as Recovery_Type_Loan
			  ,'0' as Recovery_Type_Absence,
			  '' as Particulars,
			  Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Damage
			  ,Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Loss
			  ,Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Fine,
			  convert(varchar,ap.For_date,105) as Recovery_Type_Date_Advance
			 -- '' as Recovery_Type_Date_Advance
			  ,convert(varchar,lt.For_Date,105) as Recovery_Type_Date_Loan
			  ,'' as Recovery_Type_Date_Absence,  
			  --(adp.Approval_Amount+lt.Loan_Return)as Amount,  
			  (isnull(tad.[33],0)+isnull(tad.[34],0)+isnull(tad.[35],0)+isnull(ap.Adv_Amount,0)+isnull(lt.Loan_Return,0)) as Amount,  
			  'Yes/No' as Whether_Show_Cause_Issued,'' as Explanation_heard_in_Presence_of,  
			  la.Loan_Apr_No_of_Installment as Number_of_Installment,
  			  CONVERT(CHAR(4), @From_Date, 100) +'-'+ CONVERT(CHAR(4), @From_Date, 120) as [First_Month/Year],
	  		  CONVERT(CHAR(4),@To_Date, 100) +'-'+ CONVERT(CHAR(4), @To_Date, 120) as  [Last_Month/Year],
			  convert(varchar,@To_Date,105)as Date_of_Complete_Recovery,'' as Remarks
			-- ,la.Loan_Apr_Date			 -- into #FinalTable
			  from T0080_EMP_MASTER E  
			  --and AD_ID in (1086,1088,1084)
			  inner join #Emp_Cons EC on Ec.Emp_ID=E.Emp_ID
			  left join #tadmaster tad on Ec.Emp_ID = tad.Emp_id
			  left join tmpInt TI on Ec.Emp_ID = TI.Emp_id
			  left join T0210_MONTHLY_AD_DETAIL AD  on e.Emp_ID = ad.Emp_ID and ad.AD_ID=ti.AD_ID
			   left join T0100_ADVANCE_PAYMENT ap on E.Emp_id = ap.Emp_ID  and ap.Cmp_ID=E.Cmp_ID and (ap.For_Date between @From_Date and @To_Date)
			  --Left Outer join T0090_ADVANCE_PAYMENT_APPROVAL  ADP on adp.Emp_ID=E.Emp_ID and adp.Cmp_ID=E.Cmp_ID  and adp.Application_Date = @To_Date
			  left join T0140_LOAN_TRANSACTION LT on lt.Emp_ID=e.Emp_ID and lt.Cmp_ID=e.Cmp_ID  and lt.For_Date = @To_Date
			  left Outer join T0120_LOAN_APPROVAL LA on la.Emp_ID=E.Emp_ID and la.Cmp_ID=e.Cmp_ID and la.Loan_ID=lt.Loan_ID  
			  --where cast(ad.For_Date as date) between @From_Date and @To_Date
	
        
			  -- Select  ROW_NUMBER() over(order by name )as colnumber,* 
			  --into #Tbl1
			  --From  Tempdb.Sys.Columns Where Object_ID = Object_ID('tempdb..#FinalTable')
			  --select *from #Tbl1

    --      		select tab.name, col.name, col.column_id
			 --from sys.columns as col
				--  inner join
				--  sys.tables as tab
				--	  on tab.object_id = col.object_id
				--	  WHERE tab.name = '#FinalTable'
			 --order by tab.name, col.column_id
			-- select ROW_NUMBER() OVER (ORDER BY emp_id asc)as RowNumber,* from #FinalTable ft
			  --  Select  ROW_NUMBER() over(order by name )as colnumber,* 
			  --into #Tbl1
			  --From  Tempdb.Sys.Columns Where Object_ID = Object_ID('tempdb..#FinalTable')
			 
			 
		  end
	   else 
	      begin 
		   print 2
			    select distinct E.Emp_ID,e.Emp_Full_Name,  
			 -- isnull(TI.[33],0) as Recovery_Type_Damage,isnull(TI.[34],0) as Recovery_Type_Loss,isnull(TI.[35],0) as Recovery_Type_Fine
			  '' as Recovery_Type_Damage,'' as Recovery_Type_Loss,'' as Recovery_Type_Fine
			  ,isnull(ap.Adv_Amount,0) as Recovery_Type_Advance, 
			  lt.Loan_Return as Recovery_Type_Loan
			  ,'0' as Recovery_Type_Absence,
			  '' as Particulars,
			  Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Damage
			  ,Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Loss
			  ,Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Fine,
			   convert(varchar,ap.For_date,105) as Recovery_Type_Date_Advance
			  --convert(varchar,adp.Application_Date,105) as Recovery_Type_Date_Advance
			  --'' as Recovery_Type_Date_Advance
			  ,convert(varchar,lt.For_Date,105) as Recovery_Type_Date_Loan
			  ,'' as Recovery_Type_Date_Absence,  
			  --(adp.Approval_Amount+lt.Loan_Return)as Amount,  
			  (isnull(ap.Adv_Amount,0)+isnull(lt.Loan_Return,0)) as Amount,  
			  'Yes/No' as Whether_Show_Cause_Issued,'' as Explanation_heard_in_Presence_of,  
			  la.Loan_Apr_No_of_Installment as Number_of_Installment,
  			  CONVERT(CHAR(4), @From_Date, 100) +'-'+ CONVERT(CHAR(4), @From_Date, 120) as [First_Month/Year],
	  		  CONVERT(CHAR(4),@To_Date, 100) +'-'+ CONVERT(CHAR(4), @To_Date, 120) as  [Last_Month/Year],
			  convert(varchar,@To_Date,105)as Date_of_Complete_Recovery,'' as Remarks
			  into #FinalTable1
			  from T0080_EMP_MASTER E  
			  left join T0210_MONTHLY_AD_DETAIL AD  on e.Emp_ID = ad.Emp_ID and AD_ID in (1086,1088,1084)
			  inner join #Emp_Cons EC on Ec.Emp_ID=E.Emp_ID
			 -- inner join tmpInt TI on Ec.Emp_ID = TI.Emp_id
			 left join T0100_ADVANCE_PAYMENT ap on E.Emp_id = ap.Emp_ID  and ap.Cmp_ID=E.Cmp_ID and (ap.For_Date between @From_Date and @To_Date)
			  --Left Outer join T0090_ADVANCE_PAYMENT_APPROVAL  ADP on adp.Emp_ID=E.Emp_ID and adp.Cmp_ID=E.Cmp_ID  and adp.Application_Date = @To_Date
			  left join T0140_LOAN_TRANSACTION LT on lt.Emp_ID=e.Emp_ID and lt.Cmp_ID=e.Cmp_ID  and lt.For_Date = @To_Date
			  left Outer join T0120_LOAN_APPROVAL LA on la.Emp_ID=E.Emp_ID and la.Cmp_ID=e.Cmp_ID and la.Loan_ID=lt.Loan_ID  
			  --where cast(ad.For_Date as date) between @From_Date and @To_Date


					
		  select ROW_NUMBER() OVER (ORDER BY emp_id asc)as RowNumber,* from #FinalTable1
		  end
	END   
  else  
     begin   
			 select ROW_NUMBER() OVER (ORDER BY E.emp_id asc)as RowNumber,E.Emp_ID,e.Emp_Full_Name,  
			  '' as Recovery_Type_Damage,'' as Recovery_Type_Loss,'' as Recovery_Type_Fine,adp.Approval_Amount as Recovery_Type_Advance,  
			  lt.Loan_Return as Recovery_Type_Loan,'0' as Recovery_Type_Absence,  
    
  
			  '' as Recovery_Type_Date_Damage,'' as Recovery_Type_Date_Loss,'' as Recovery_Type_Date_Fine,
			  convert(varchar,adp.Application_Date,105) as Recovery_Type_Date_Advance,convert(varchar,lt.For_Date,105) as Recovery_Type_Date_Loan,'' as Recovery_Type_Date_Absence,  
			  (adp.Approval_Amount+lt.Loan_Return)as Amount,  
			  '' as Particulars,'Yes/No' as Whether_Show_Cause_Issued,'' as Explanation_heard_in_Presence_of,  
			  la.Loan_Apr_No_of_Installment as Loan_Apr_No_of_Installment,
  				--select convert(varchar, getdate(), 105)
				--concat((DATENAME(mm,@From_Date),3),' ',datepart(yy,@From_Date))as [First_Month/Year],
				 --FORMAT(@From_Date, 'MM-yyyy')as [First_Month/Year],
				  CONVERT(CHAR(4), @From_Date, 100) +'-'+ CONVERT(CHAR(4), @From_Date, 120) as [First_Month/Year],
	  				  CONVERT(CHAR(4),@To_Date, 100) +'-'+ CONVERT(CHAR(4), @To_Date, 120) as  [Last_Month/Year],
			 -- convert(varchar,@From_Date,105)as [First_Month/Year], 
			  --cast(@To_Date as varchar(50))as [Last_Month/Year],
			  convert(varchar,@To_Date,105)as Date_of_Complete_Recovery,'' as Remarks
			  from T0080_EMP_MASTER E  
			  inner join T0090_ADVANCE_PAYMENT_APPROVAL  ADP on adp.Emp_ID=E.Emp_ID and adp.Cmp_ID=E.Cmp_ID  
			  inner join T0140_LOAN_TRANSACTION LT on lt.Emp_ID=e.Emp_ID and lt.Cmp_ID=e.Cmp_ID  
			  inner join T0120_LOAN_APPROVAL LA on la.Emp_ID=E.Emp_ID and la.Cmp_ID=e.Cmp_ID and la.Loan_ID=lt.Loan_ID  
  
     end  
  
 end 
