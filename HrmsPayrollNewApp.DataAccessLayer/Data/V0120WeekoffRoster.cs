using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120WeekoffRoster
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime ForDate { get; set; }

    public string? Department { get; set; }

    public string? BranchName { get; set; }

    public string IsCancelWo { get; set; } = null!;

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? CatId { get; set; }
}
