using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120EmpRetaintionStatus
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? ForDate { get; set; }

    public string? StartDate { get; set; }

    public string? EndDate { get; set; }

    public DateTime? SystemDateStart { get; set; }

    public DateTime? SystemDateEnd { get; set; }

    public string? Department { get; set; }

    public string? DesigName { get; set; }

    public decimal? DesigId { get; set; }

    public string? VerticalName { get; set; }

    public string? SubverticalName { get; set; }

    public string? BranchName { get; set; }

    public string IsRetainOn { get; set; } = null!;

    public byte Flag { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? CatId { get; set; }

    public string? SubBranchName { get; set; }

    public string? GrdName { get; set; }

    public string? SegmentName { get; set; }

    public string? TypeName { get; set; }

    public string? CatName { get; set; }
}
