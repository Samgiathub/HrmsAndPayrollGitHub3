

CREATE PROCEDURE [dbo].[Emp_Details_Form_C_Format1]         
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

    
         Select distinct  E.Emp_ID ,ad_name--M_AD_Amount    
         ,Sum(MD.M_AD_Amount) as M_AD_Amount     
         ,For_date    
         ,M_AD_Flag,e.Cmp_ID   
		 ,AD_DEF_ID,ad.ad_id
         into #tmpDedSum    
         from T0080_EMP_MASTER E           
		 inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID  
         inner join T0210_MONTHLY_AD_DETAIL MD on E.Emp_id = MD.Emp_ID 
         inner join T0050_AD_MASTER AD on md.AD_ID = ad.ad_id           
         where For_date between cast(@from_date as date) and  cast(@To_date as date)  and     
         M_AD_Flag = 'D' and Md.M_AD_Amount <> 0.00 and E.Cmp_ID = @Company_Id
         and AD.AD_DEF_ID in (33,34,35)
         group by E.Emp_ID,For_Date,M_AD_Flag,E.Cmp_ID,AD_DEF_ID,ad_name,ad.ad_id

			  IF OBJECT_ID(N'tempdb..#tmpadvance') IS NOT NULL    
				DROP TABLE #tmpadvance    
			   Select distinct  E.Emp_ID ,'Advance' as ad_name,--M_AD_Amount    
           ap.Adv_Amount
         ,For_date    
         ,e.Cmp_ID ,0 as ad_id  
         into #tmpadvance
         from T0080_EMP_MASTER E           
		 --inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID  
         inner join T0100_ADVANCE_PAYMENT ap on E.Emp_id = ap.Emp_ID  and ap.Cmp_ID=E.Cmp_ID --and For_Date between  '2020-12-01 00:00:00' and '2021-12-31 00:00:00'
         where For_date between  @From_Date and @To_Date     and     
		   E.Cmp_ID = @Company_Id
      
		 	
			  IF OBJECT_ID(N'tempdb..#tmploan') IS NOT NULL    
				DROP TABLE #tmploan    
			   Select distinct  E.Emp_ID ,'Loan' as ad_name,--M_AD_Amount    
          lt.Loan_Return
         ,For_date    
         ,e.Cmp_ID ,0 as ad_id    
         into #tmploan
         from T0080_EMP_MASTER E           
		 --inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID  
         left join T0140_LOAN_TRANSACTION LT on lt.Emp_ID=e.Emp_ID and lt.Cmp_ID=e.Cmp_ID  and lt.For_Date = @To_Date  
			  left Outer join T0120_LOAN_APPROVAL LA on la.Emp_ID=E.Emp_ID and la.Cmp_ID=e.Cmp_ID and la.Loan_ID=lt.Loan_ID  
         where For_date between   @From_Date and @To_Date  and     
		   E.Cmp_ID = @Company_Id

    

         IF OBJECT_ID(N'tempdb..#tadmaster') IS NOT NULL    
				DROP TABLE #tadmaster    
		 select Distinct t.Emp_id,t.AD_NAME,t.M_AD_Amount,t.For_Date,t.AD_ID  
		  into #tadmaster
		 from (
		 select td.Emp_id,td.Ad_name,M_AD_Amount,td.AD_ID     
         ,For_date  from #Emp_Cons ec
		 inner join #tmpDedSum td on td.Emp_ID=ec.emp_id
		 union all
		  select tad.Emp_id,tad.Ad_name,Adv_Amount as M_AD_Amount,tad.AD_ID      
         ,For_date  from #Emp_Cons ec
		 inner join #tmpadvance tad on tad.Emp_ID=ec.emp_id
		 union all
		  select tad.Emp_id,tad.Ad_name,Loan_Return as M_AD_Amount,tad.AD_ID      
         ,For_date  from #Emp_Cons ec
		 inner join #tmploan tad on tad.Emp_ID=ec.emp_id
		 )as t


          IF OBJECT_ID(N'tempdb..#tmpfinal') IS NOT NULL    
				DROP TABLE #tmpfinal       
		SELECT
     Emp_id,AD_ID,
     STUFF(
         (SELECT DISTINCT '/' + AD_NAME
          FROM #tadmaster
          WHERE Emp_ID = a.Emp_ID 
          FOR XML PATH (''))
          , 1, 1, '')  AS Ad_name, STUFF(
         (SELECT   '/'+cast(M_AD_Amount as varchar(5000))
          FROM #tadmaster
          WHERE Emp_ID = a.Emp_ID 
          FOR XML PATH (''))
          , 1, 1, '')  AS M_AD_Amount
		  ,  STUFF(
         (SELECT  '/' + convert(varchar,For_Date,105)
          FROM #tadmaster
          WHERE Emp_ID = a.Emp_ID 
          FOR XML PATH (''))
          , 1, 1, '')as For_Date
		   into #tmpfinal
       FROM #tadmaster AS a
       GROUP BY Emp_id,AD_ID
		
		 DROP Table IF EXISTS  tmpInt 
		 Declare  @Qry_INT as varchar(MAX) = ''    
         Set @Qry_INT = 'SELECT Emp_ID ,  '+ @ColDedVar +' ,AD_ID  
			 into tmpInt
             FROM    
             (     
               Select emp_id,M_AD_Amount,AD_DEF_ID,AD_ID  
                 from #tmpDedSum    
                ) FormBResult        
                PIVOT (
					SUM(M_AD_Amount) FOR AD_DEF_ID IN ( '+ @ColDedVar +' )
				) AS PivotTable'     
              
			exec(@Qry_INT)    

	
		
			
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
			 
      
 IF @Constraint <> ''        
   BEGIN        
       if((SELECT Count(*) FROM tmpInt) >0)
		  begin
		  print 1
		  select * from tmpInt
		  select * from #tmpfinal
			  select distinct E.Emp_ID,e.Emp_Full_Name as [Name_2], 
			  tf.Ad_name as [Recovery_Type_3],
			--  isnull(TI.[33],0) as Recovery_Type_Damage,isnull(TI.[34],0) as Recovery_Type_Loss,isnull(TI.[35],0) as Recovery_Type_Fine,
			----  '' as Recovery_Type_Advance,  
			--  isnull(tmad.M_AD_Amount,0)as Recovery_Type_Advance,
			--  lt.Loan_Return as Recovery_Type_Loan
			-- --,(case when end),
			  
			--  ,'0' as Recovery_Type_Absence,
			  '---' as [Particulars_4],
			  --Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Damage
			  --,Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Loss
			  --,Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Fine,
			  ----convert(varchar,adp.Application_Date,105) as Recovery_Type_Date_Advance
			  --'' as Recovery_Type_Date_Advance
			  --,convert(varchar,lt.For_Date,105) as Recovery_Type_Date_Loan
			  --,'' as Recovery_Type_Date_Absence,  
			  tf.For_Date as [Date_5],
			  tf.M_AD_Amount as [Amount_6],
			  --(adp.Approval_Amount+lt.Loan_Return)as Amount,  
			  --lt.Loan_Return as Amount,  
			  '---' as [Whether_Show_Cause_Issued_7],'---' as [Explanation_heard_in_Presence_of_8],  
			  isnull(la.Loan_Apr_No_of_Installment,0) as [Loan_Apr_No_of_Installment_9],
  			  CONVERT(CHAR(4), @From_Date, 100) +'-'+ CONVERT(CHAR(4), @From_Date, 120) as [First_Month/Year_10],
	  		  CONVERT(CHAR(4),@To_Date, 100) +'-'+ CONVERT(CHAR(4), @To_Date, 120) as  [Last_Month/Year_11],
			 -- convert(varchar,@To_Date,105)as Date_of_Complete_Recovery
			  '' as [Date_of_Complete_Recovery_12],'' as [Remarks_13]
			  into #FinalTable
			  from T0080_EMP_MASTER E 
			    inner join #Emp_Cons EC on Ec.Emp_ID=E.Emp_ID
			   inner join #tmpfinal tf on tf.Emp_ID=ec.Emp_ID
			
			  inner join tmpInt TI on Ec.Emp_ID = TI.Emp_id
			    inner join T0210_MONTHLY_AD_DETAIL AD  on e.Emp_ID = ad.Emp_ID and ad.AD_ID =ti.ad_id
			  --added by mansi start
			 
			    --left join #tmpadvance tmad on Ec.Emp_ID = tmad.Emp_id
			  --added by mansi end
			  --Left Outer join T0090_ADVANCE_PAYMENT_APPROVAL  ADP on adp.Emp_ID=E.Emp_ID and adp.Cmp_ID=E.Cmp_ID  and adp.Application_Date = @To_Date
			  left join T0140_LOAN_TRANSACTION LT on lt.Emp_ID=e.Emp_ID and lt.Cmp_ID=e.Cmp_ID  and lt.For_Date = @To_Date
			  left Outer join T0120_LOAN_APPROVAL LA on la.Emp_ID=E.Emp_ID and la.Cmp_ID=e.Cmp_ID and la.Loan_ID=lt.Loan_ID  
			  where cast(ad.For_Date as date) between @From_Date and @To_Date
	
			 select ROW_NUMBER() OVER (ORDER BY emp_id asc)as [Sr.No._1],* from #FinalTable ft
			 
		  end
	   else 
	      begin 
		  --print 2
			select distinct E.Emp_ID,e.Emp_Full_Name as [Name_2], 
			  tf.Ad_name as [Recovery_Type_3],
			--  isnull(TI.[33],0) as Recovery_Type_Damage,isnull(TI.[34],0) as Recovery_Type_Loss,isnull(TI.[35],0) as Recovery_Type_Fine,
			----  '' as Recovery_Type_Advance,  
			--  isnull(tmad.M_AD_Amount,0)as Recovery_Type_Advance,
			--  lt.Loan_Return as Recovery_Type_Loan
			-- --,(case when end),
			  
			--  ,'0' as Recovery_Type_Absence,
			  '---' as [Particulars_4],
			  --Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Damage
			  --,Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Loss
			  --,Convert ( Varchar (50),@To_Date,105) as Recovery_Type_Date_Fine,
			  ----convert(varchar,adp.Application_Date,105) as Recovery_Type_Date_Advance
			  --'' as Recovery_Type_Date_Advance
			  --,convert(varchar,lt.For_Date,105) as Recovery_Type_Date_Loan
			  --,'' as Recovery_Type_Date_Absence,  
			  tf.For_Date as [Date_5],
			  tf.M_AD_Amount as [Amount_6],
			  --(adp.Approval_Amount+lt.Loan_Return)as Amount,  
			  --lt.Loan_Return as Amount,  
			  '---' as [Whether_Show_Cause_Issued_7],'---' as [Explanation_heard_in_Presence_of_8],  
			  isnull(la.Loan_Apr_No_of_Installment,0) as [Loan_Apr_No_of_Installment_9],
  			  CONVERT(CHAR(4), @From_Date, 100) +'-'+ CONVERT(CHAR(4), @From_Date, 120) as [First_Month/Year_10],
	  		  CONVERT(CHAR(4),@To_Date, 100) +'-'+ CONVERT(CHAR(4), @To_Date, 120) as  [Last_Month/Year_11],
			 -- convert(varchar,@To_Date,105)as Date_of_Complete_Recovery
			  '' as [Date_of_Complete_Recovery_12],'' as [Remarks_13]
			  into #FinalTable1
			  from T0080_EMP_MASTER E 
			    inner join #Emp_Cons EC on Ec.Emp_ID=E.Emp_ID
			   inner join #tmpfinal tf on tf.Emp_ID=ec.Emp_ID
			   inner join #tadmaster tad on tad.Emp_ID=ec.Emp_ID
			  --left join T0210_MONTHLY_AD_DETAIL AD  on e.Emp_ID = ad.Emp_ID and AD_ID in (1086,1088,1084)
			  --Left Outer join T0090_ADVANCE_PAYMENT_APPROVAL  ADP on adp.Emp_ID=E.Emp_ID and adp.Cmp_ID=E.Cmp_ID  and adp.Application_Date = @To_Date
			  left join T0140_LOAN_TRANSACTION LT on lt.Emp_ID=e.Emp_ID and lt.Cmp_ID=e.Cmp_ID  and lt.For_Date = @To_Date
			  left Outer join T0120_LOAN_APPROVAL LA on la.Emp_ID=E.Emp_ID and la.Cmp_ID=e.Cmp_ID and la.Loan_ID=lt.Loan_ID  
			  where cast(tad.For_Date as datetime) between @From_Date and @To_Date


		  select ROW_NUMBER() OVER (ORDER BY emp_id asc)as [Sr.No._1],* from #FinalTable1
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



