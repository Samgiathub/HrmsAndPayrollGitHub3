using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0065EmpExperienceDetailApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int RowId { get; set; }

    public int CmpId { get; set; }

    public string EmployerName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public DateTime StDate { get; set; }

    public DateTime EndDate { get; set; }

    public decimal? CtcAmount { get; set; }

    public decimal? GrossSalary { get; set; }

    public string? ExpRemarks { get; set; }

    public string? EmpBranch { get; set; }

    public string? EmpLocation { get; set; }

    public string? ManagerName { get; set; }

    public string? ContactNumber { get; set; }

    public decimal? EmpExp { get; set; }

    public string? IndustryType { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
