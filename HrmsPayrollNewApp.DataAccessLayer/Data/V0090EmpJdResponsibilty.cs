using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpJdResponsibilty
{
    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal JdcodeId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public string JobCode { get; set; } = null!;

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal CmpId { get; set; }
}
