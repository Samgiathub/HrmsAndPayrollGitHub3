using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100IncrementSlabwise
{
    public decimal? GrossSalary { get; set; }

    public decimal? WagesCalculateOn { get; set; }

    public decimal? WagesAmount { get; set; }

    public decimal? EligibleDay { get; set; }

    public decimal? IncrementAmount { get; set; }

    public decimal? TotalIncrement { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? AdditionalIncrement { get; set; }

    public decimal? WorkingDays { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal TranId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? SubBranchId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }
}
