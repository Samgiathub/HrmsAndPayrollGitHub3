using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0210EmpSeniorityDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal CalculationAmount { get; set; }

    public decimal Period { get; set; }

    public string Mode { get; set; } = null!;

    public decimal? Amount { get; set; }

    public decimal? NetAmount { get; set; }

    public string? Remarks { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string AdName { get; set; } = null!;

    public decimal? AdNotEffectSalary { get; set; }

    public decimal BranchId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SegmentId { get; set; }

    public string? BranchName { get; set; }

    public decimal? SubBranchId { get; set; }
}
