using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpExperienceDetail
{
    public decimal EmpId { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

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

    public string? AttachDoc { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
