using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsFinalScore
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public string? TitleName { get; set; }

    public decimal? TotalScore { get; set; }

    public decimal? EvalScore { get; set; }

    public decimal? Percentage { get; set; }

    public decimal? EmpStatus { get; set; }

    public decimal? InspectionStatus { get; set; }

    public decimal? ApprIntId { get; set; }

    public virtual T0090HrmsAppraisalInitiation? ApprInt { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
