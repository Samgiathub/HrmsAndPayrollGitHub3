CREATE PROCEDURE [dbo].[kpms_Menu_Details]        
(    
@Emp_ID INT,
@loginID INT
)    
AS        
BEGIN        
 SET NOCOUNT ON;        
 SET ARITHABORT ON;        
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;        
        
	Declare @data varchar(max)=''

	
  if(@loginID!=0 and @Emp_ID=0)--Master Admin
  begin
	select * into #tblEmpRightsData from      
	(select distinct (M.Module_Id), M.Module_Name,P.Page_Name,0 as Page_Id,0 as Is_Save,0 as Is_Edit,0 as Is_Delete,1 as Is_View ,0 as SrNo     
	 from  KPMS_T0120_Page_Master p
	Inner Join KPMS_T0110_Module_Master as m On m.Module_Id = p.Module_Id     
	) as Qry 
  end 
  else if (@Emp_ID!=0 and @loginID!=0) --who has rights to view
  begin
	select * into #tblEmpRightsData2 from      
	( select distinct (M.Module_Id), M.Module_Name,P.Page_Name,A.*,0 as Page_Id,0 as Is_Save,0 as Is_Edit,0 as Is_Delete,Is_View ,0 as SrNo      
	from KPMS_T0100_Emp_Role_Assign as A Inner Join KPMS_T0125_Page_Rights AS B       
	On  A.Role_Id = B.Emp_Role_Id      
	Inner join KPMS_T0120_Page_Master as P On P.Page_Id = B.Page_Id       
	Inner Join KPMS_T0110_Module_Master as m On m.Module_Id = B.Module_Id           
	Where Is_View = 1 and Emp_ID = @Emp_ID) as Qry      
  end
  else
  begin
  select * into #tblEmpRightsData3 from  -- not having access    
	( select 0 as Module_Id, '' as Module_Name,0 as Page_Id,0 as Is_Save,0 as Is_Edit,0 as Is_Delete,Is_View ,0 as SrNo      
	from KPMS_T0100_Emp_Role_Assign as A Inner Join KPMS_T0125_Page_Rights AS B       
	On  A.Role_Id = B.Emp_Role_Id      
	Inner join KPMS_T0120_Page_Master as P On P.Page_Id = B.Page_Id       
	Inner Join KPMS_T0110_Module_Master as m On m.Module_Id = B.Module_Id) as Qry      
  end
  DECLARE @lResult VARCHAR(MAX) = ''    

  if(@loginID!=0 and @Emp_ID=0)
   begin      
	select  @lResult = @lResult+      
	 '<li class="nav-item" id="liMaster">  
						<a href="#" class="nav-link" id="lnk_Master" attrmenuid="' + CONVERT(varchar,ms.Module_Id) + '">      
                              <i class="nav-icon far fas fa-bullseye"></i>    
                                  <p> '+ Module_Name +'<i class="right fas fa-angle-left">
							  </i> </p>                                
                            </a>      
      <ul class="nav nav-treeview">'+dbo.fnc_SubMenuDetails(ms.Module_Id) +'</ul>    
    </li>'    from #tblEmpRightsData ms group by Module_Id,Module_Name
      
   end
  else if (@Emp_ID!=0 and @loginID!=0)
  begin
			select  @lResult = @lResult+      
			 '<li class="nav-item" id="liMaster">  
								<a href="#" class="nav-link" id="lnk_Master" attrmenuid="' + CONVERT(varchar,ms.Module_Id) + '">      
									  <i class="nav-icon far fas fa-bullseye"></i>    
										  <p> '+ Module_Name +'<i class="right fas fa-angle-left"> </i></p>                                
									</a>      
			  <ul class="nav nav-treeview">'+dbo.fnc_SubMenuDetails(ms.Module_Id) +'</ul>    
			</li>'  
			from #tblEmpRightsData2 ms group by Module_Id,Module_Name
   end
   else
   begin
					select  @lResult = @lResult+      
	 '<li class="nav-item" id="liMaster">  
						<a href="#" class="nav-link" id="lnk_Master" attrmenuid="' + CONVERT(varchar,ms.Module_Id) + '">      
                              <i class="nav-icon far fas fa-bullseye"></i>    
                                  <p> '+ Module_Name +'<i class="right fas fa-angle-left">
							  </i> </p>                                
                            </a>      
      <ul class="nav nav-treeview">'+dbo.fnc_SubMenuDetails(ms.Module_Id) +'</ul>    
    </li>'    from #tblEmpRightsData3 ms group by Module_Id,Module_Name
   end  

   			select  @lResult as Result        
END 


--if(@loginID!=0 and @Emp_ID=0)--Master Admin
--  begin
--	select * into #tblEmpRightsData from      
--	( select distinct (M.Module_Id), M.Module_Name,P.Page_Name,A.*,0 as Page_Id,0 as Is_Save,0 as Is_Edit,0 as Is_Delete,Is_View ,0 as SrNo      
--	from KPMS_T0100_Emp_Role_Assign as A Inner Join KPMS_T0125_Page_Rights AS B       
--	On  A.Role_Id = B.Emp_Role_Id      
--	Inner join KPMS_T0120_Page_Master as P On P.Page_Id = B.Page_Id       
--	Inner Join KPMS_T0110_Module_Master as m On m.Module_Id = B.Module_Id      
--	) as Qry 
--  end 
