using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050EmpMonthlyShiftRotation
{
    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BranchId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal RotationId { get; set; }

    public string RotationName { get; set; } = null!;

    public DateTime EffectiveDate { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public string EmpFirstName { get; set; } = null!;
}
